import csv
import os
import pickle
from typing import List

import numpy as np
import tensorflow as tf
from qiskit.visualization import plot_distribution

from circuit_run_data import CircuitRunData
from dataset import CustomDataset
from model.run_neural_net import RunNeuralNet
from quantum_backend_type import QuantumBackendType
from quantum_backends import QuantumBackends
from quantum_circuits.walker import Walker


def create_adversarial_pattern(input_feature, input_label, trained_model):
    loss_object = tf.keras.losses.BinaryCrossentropy()
    input_feature = tf.convert_to_tensor(input_feature)
    input_label = tf.convert_to_tensor(input_label)
    with tf.GradientTape() as tape:
        tape.watch(input_feature)
        prediction = trained_model(input_feature)
        loss = loss_object(input_label, prediction)

    # Get the gradients of the loss w.r.t to the input feature
    gradient = tape.gradient(loss, input_feature)
    # Get the sign of the gradients to create the perturbation
    signed_grad = tf.sign(gradient)
    return signed_grad


def normalize_every_pair_of_four(tensor):
    original_shape = tensor.shape

    # Reshape the tensor to have its last dimension of size 4
    reshaped_tensor = tf.reshape(tensor, (-1, 4))

    # Calculate the sum of each group of four values
    sums = tf.reduce_sum(reshaped_tensor, axis=1, keepdims=True)

    # Normalize each group of four so that they sum up to 1
    normalized_tensor = reshaped_tensor / sums

    # Restore the tensor to its original shape
    normalized_tensor_with_restored_shape = tf.reshape(normalized_tensor, original_shape)

    return normalized_tensor_with_restored_shape


def get_measurements_at_step(measurements: List[float], step: int) -> List[float]:
    return measurements[step * 4: step * 4 + 4]


if __name__ == '__main__':
    window_size = 2000

    # 1. Load Data
    data = []
    for qc in QuantumBackends.get_quantum_computer_backends():
        data.append(CircuitRunData(Walker(), qc))
    for s in QuantumBackends.get_simulator_backends():
        data.append(CircuitRunData(Walker(), s))

    custom_dataset = CustomDataset(data, list(range(0, 9)), window_size=window_size)

    # 2. Train neural net Model
    trained_model = RunNeuralNet.get_model_after_training(custom_dataset)

    # 3. Adversarial attack
    # 3.1 Convert simulator samples to be classified as quantum samples
    simulator_data = []
    for s in QuantumBackends.get_simulator_backends():
        simulator_data.append(CircuitRunData(Walker(), s))
    simulator_dataset = CustomDataset(simulator_data, list(range(0, 9)), window_size=window_size)
    _, _, test_features, test_labels = simulator_dataset.get_test_train_split()

    epsilon_with_num_of_correct_predictions = {}
    altered_input_values = {}
    epsilons = np.arange(0.00, 0.07, 0.005)
    for epsilon in epsilons:
        epsilon_with_num_of_correct_predictions.update({epsilon: 0})
        altered_input_values.update({epsilon: []})
    print(f"Iterating over {len(test_features)} features ...")
    for feature, label in zip(test_features, test_labels):
        input_feature = [feature]
        input_label = [[label]]
        perturbations = create_adversarial_pattern(input_feature, input_label, trained_model)
        for eps in epsilons:
            adv_x = input_feature + eps * perturbations
            adv_x = tf.clip_by_value(adv_x, 0, 1)  # only allow values between 0 and 1
            adv_x = normalize_every_pair_of_four(adv_x)  # normalize probabilities (packs of 4 have to sum up to 1)
            prediction = trained_model.predict(adv_x)
            altered_input_values[eps].append(adv_x)
            if prediction[0][0] >= 0.5:
                predicted_label = QuantumBackendType.SIMULATOR.label
            else:  # equivalent to prediction[0][0] < 0.5
                predicted_label = QuantumBackendType.QUANTUM_COMPUTER.label

            if predicted_label == label:  # only update values if prediction is correct
                epsilon_with_num_of_correct_predictions[eps] = epsilon_with_num_of_correct_predictions[eps] + 1

    csv_path = "../results"
    os.makedirs(csv_path, exist_ok=True)
    with (open(f"{csv_path}/{Walker().get_name()}_adversarial_attack_simulator_to_quantum.csv", 'w',
               newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',')
        csv_writer.writerow(['epsilon', 'accuracy'])
        for eps in epsilons:
            normalized_accuracy = epsilon_with_num_of_correct_predictions[eps] / len(test_features)
            csv_writer.writerow([f"{eps}", "%.4f" % normalized_accuracy])

    # save adversarial attack results
    visualization_path = "../visualization/adversarial"
    os.makedirs(visualization_path, exist_ok=True)
    pickle.dump(altered_input_values, open(f"{visualization_path}/adversarial_data.pickle", 'wb'))

    # visualize adjusted values in histogram
    qc_data = []
    for qc in QuantumBackends.get_quantum_computer_backends():
        qc_data.append(CircuitRunData(Walker(), qc))
    qc_dataset = CustomDataset(qc_data, list(range(0, 9)), window_size=window_size)
    _, _, qc_test_features, qc_test_labels = qc_dataset.get_test_train_split()

    plotting_epsilons = [0.00, 0.03, 0.06]
    qubit_results = ["00", "01", "10", "11"]
    legend = ["epsilon 0.00", "epsilon 0.03", "epsilon 0.06", "quantum computers"]
    for measurement_step in range(0, 9):
        data_for_plotting = []

        # adversarial example data
        for epsilon in plotting_epsilons:
            data_for_plotting_single_epsilon = dict.fromkeys(qubit_results, 0.0)
            for measurements in altered_input_values[epsilon]:
                for i, measurement in enumerate(get_measurements_at_step(measurements[0], measurement_step)):
                    data_for_plotting_single_epsilon[qubit_results[i]] += measurement
            data_for_plotting.append(data_for_plotting_single_epsilon)

        # data from a qc as comparison
        data_for_plotting_single_epsilon_qc = dict.fromkeys(qubit_results, 0.0)
        for qc_run_data in qc_test_features:
            for i, measurement in enumerate(get_measurements_at_step(qc_run_data, measurement_step)):
                data_for_plotting_single_epsilon_qc[qubit_results[i]] += measurement
        data_for_plotting.append(data_for_plotting_single_epsilon_qc)

        hist = plot_distribution(data_for_plotting, legend=legend, figsize=(14, 6))
        hist.savefig(
            f"{visualization_path}/hist_{Walker().get_name()}_step_{measurement_step}_adversarial.svg")