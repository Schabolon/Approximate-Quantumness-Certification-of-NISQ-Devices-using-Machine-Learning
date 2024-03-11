import numpy as np
import tensorflow as tf

from circuit_run_data import CircuitRunData
from quantum_backends import QuantumBackends
from quantum_circuits.walker import Walker

trained_model = tf.keras.models.load_model('../neural_net.keras')
loss_object = tf.keras.losses.BinaryCrossentropy()


def create_adversarial_pattern(input_feature, input_label):
    input_feature = tf.convert_to_tensor(input_feature)
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


if __name__ == '__main__':
    simulator_data = CircuitRunData(Walker(), QuantumBackends.get_simulator_backends()[0])
    simulator_probability_data = simulator_data.get_probabilities(window_size=2000)
    simulator_probability_data = simulator_probability_data.reshape(len(simulator_probability_data), 36)

    qc_data = CircuitRunData(Walker(), QuantumBackends.get_quantum_computer_backends()[0])
    qc_probability_data = qc_data.get_probabilities(window_size=2000)
    qc_probability_data = qc_probability_data.reshape(len(qc_probability_data), 36)

    single_simulator_value = simulator_probability_data[0:1, :]

    print(f"Original input: {single_simulator_value}")
    print(f"Original result: {trained_model.predict(single_simulator_value)}")

    perturbations = create_adversarial_pattern(single_simulator_value, np.array([1]).reshape(-1, 1))
    epsilons = [0, 0.01, 0.1, 0.15]
    for i, eps in enumerate(epsilons):
        adv_x = single_simulator_value + eps * perturbations
        adv_x = tf.clip_by_value(adv_x, 0, 1)  # only allow values between 0 and 1
        adv_x = normalize_every_pair_of_four(adv_x)
        print(f"Adversarial Input for epsilon {eps}: {adv_x}")
        print(f"Adversarial result (epsilon: {eps}) : {trained_model.predict(adv_x)}")
