import csv
import logging
import os
from itertools import combinations

from circuit_run_data import CircuitRunData
from dataset import CustomDataset
from model import run_svm, run_neural_net, run_cnn
from model.cnn_tuner import CNNTuner
from model.ml_wrapper import MLWrapper
from model.neural_net_tuner import NeuralNetTuner
from model.run_neural_net import RunNeuralNet
from model.run_svm import RunSVM
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker


def window_sizes_vs_step_ranges_all_backends(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper):
    logging.info("Creating table with window sizes vs step ranges for all backends combined ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{ml_model.get_name()}_window_sizes_vs_step_ranges_all_backends_combined.csv", 'w',
               newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)

        data = []
        for qc in QuantumBackends.get_quantum_computer_backends():
            data.append(CircuitRunData(circuit, qc))
        for s in QuantumBackends.get_simulator_backends():
            data.append(CircuitRunData(circuit, s))

        csv_writer.writerow(
            ['window size/step ranges', '[1]', '[1 ... 2]', '[1 ... 3]', '[1 ... 4]', '[1 ... 5]', '[1 ... 6]',
             '[1 ... 7]', '[1 ... 8]', '[1 ... 9]'])
        if ml_model.get_name() is RunSVM().get_name():
            # SVM takes too long for small window sizes. They are therefore excluded.
            window_sizes = [50, 80, 100, 200, 400, 800, 1000, 2000, 4000, 8000]
        else:
            window_sizes = [5, 8, 10, 40, 50, 80, 100, 200, 400, 800, 1000, 2000, 4000, 8000]
        for window_size in window_sizes:
            logging.debug(f"Calculating with window size {window_size}.")

            steps = []
            row_results = [window_size]
            for step in range(0, 9):
                steps.append(step)
                logging.debug(f"Calculating for steps {steps}")
                custom_dataset = CustomDataset(data, steps, window_size=window_size)
                acc = ml_model.train_and_evaluate(custom_dataset)
                # store float as string with 3 decimal places
                row_results.append("%.3f" % acc)
            csv_writer.writerow(row_results)
    logging.info("Finished chart creation.")


def __generate_permutations_with_num_removed_elements(lst, num_to_remove):
    all_lists = []
    for comb in combinations(lst, num_to_remove):
        new_list = [item for item in lst if item not in comb]
        all_lists.append(new_list)
    return all_lists


def exclude_multiple_quantum_computer_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper,
                                                      window_size=2000):
    logging.info(
        "Creating table with multiple excluded quantum computer vs step ranges for all other backends combined ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(
            f"{path}/{ml_model.get_name()}_exclude_multiple_quantum_computer_vs_step_ranges_all_other_backends_combined.csv",
            'w',
            newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',', quoting=csv.QUOTE_MINIMAL)

        csv_writer.writerow(
            ['# of excluded QCs', '[1]', '[1 ... 2]', '[1 ... 3]', '[1 ... 4]', '[1 ... 5]', '[1 ... 6]', '[1 ... 7]',
             '[1 ... 8]', '[1 ... 9]'])
        for num_to_exclude in range(2, 5):
            lists_with_qcs_excluded = __generate_permutations_with_num_removed_elements(
                QuantumBackends.get_quantum_computer_backends(), num_to_exclude)
            row_results = [num_to_exclude.__str__()]
            steps = []
            for step in range(0, 9):
                accumulated_acc = 0.0
                steps.append(step)
                logging.debug(f"Calculating for steps {steps}")
                for qc_data_single_run in lists_with_qcs_excluded:
                    logging.debug(f"Calculating with excluded #{num_to_exclude}.")

                    data = []
                    for qc in qc_data_single_run:
                        data.append(CircuitRunData(circuit, qc))
                    for s in QuantumBackends.get_simulator_backends():
                        data.append(CircuitRunData(circuit, s))

                    excluded_qcs = []
                    for qc in QuantumBackends.get_quantum_computer_backends():
                        if qc not in qc_data_single_run:
                            excluded_qcs.append(CircuitRunData(circuit, qc))

                    additional_test_dataset = CustomDataset(excluded_qcs, steps, window_size=window_size)
                    custom_dataset = CustomDataset(data, steps, window_size=window_size)
                    acc = ml_model.train_and_evaluate(custom_dataset, additional_test_dataset=additional_test_dataset)
                    accumulated_acc = accumulated_acc + acc

                # store float as string with 3 decimal places
                row_results.append("%.3f" % (accumulated_acc / len(lists_with_qcs_excluded)))

            csv_writer.writerow(row_results)
        logging.info("Finished chart creation.")


def exclude_single_quantum_computer_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper,
                                                    window_size=2000):
    logging.info("Creating table with excluded quantum computer vs step ranges for all other backends combined ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{ml_model.get_name()}_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv",
               'w',
               newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)

        csv_writer.writerow(
            ['excluded QC', '[1]', '[1 ... 2]', '[1 ... 3]', '[1 ... 4]', '[1 ... 5]', '[1 ... 6]',
             '[1 ... 7]', '[1 ... 8]', '[1 ... 9]'])
        for qc_to_exclude in QuantumBackends.get_quantum_computer_backends():
            logging.debug(f"Calculating with excluded {qc_to_exclude}.")

            data = []
            for qc in QuantumBackends.get_quantum_computer_backends():
                if qc != qc_to_exclude:
                    data.append(CircuitRunData(circuit, qc))
            for s in QuantumBackends.get_simulator_backends():
                data.append(CircuitRunData(circuit, s))

            steps = []
            row_results = [qc_to_exclude]
            for step in range(0, 9):
                steps.append(step)
                logging.debug(f"Calculating for steps {steps}")
                custom_dataset = CustomDataset(data, steps, window_size=window_size)
                additional_test_dataset = CustomDataset([CircuitRunData(circuit, qc_to_exclude)], steps,
                                                        window_size=window_size)
                acc = ml_model.train_and_evaluate(custom_dataset, additional_test_dataset=additional_test_dataset)
                # store float as string with 3 decimal places
                row_results.append("%.3f" % acc)
            csv_writer.writerow(row_results)
        logging.info("Finished chart creation.")


def accuracy_quantum_computers_vs_simulators_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper,
                                                             window_size=1000):
    logging.info("Creating accuracy with different steps for combination of quantum computers vs all simulators ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(
            f"{path}/{circuit.get_name()}_{ml_model.get_name()}_quantum_computers_vs_simulators_window_size_{window_size}.csv",
            'w',
            newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(['step k', 'single step accuracy k', 'step range accuracy 1 to k'])
        steps = []
        data = []
        for qc in QuantumBackends.get_quantum_computer_backends():
            data.append(CircuitRunData(circuit, qc))
        for s in QuantumBackends.get_simulator_backends():
            data.append(CircuitRunData(circuit, s))
        for step in range(0, 9):
            steps.append(step)
            logging.debug(f"Calculating accuracy for steps {steps}.")
            results = [step + 1]

            # single step
            custom_dataset = CustomDataset(data, [step], window_size=window_size)
            single_step_acc = ml_model.train_and_evaluate(custom_dataset)
            # store float as string with 3 decimal places
            results.append("%.3f" % single_step_acc)

            custom_dataset = CustomDataset(data, steps, window_size=window_size)
            acc = ml_model.train_and_evaluate(custom_dataset)
            # store float as string with 3 decimal places
            results.append("%.3f" % acc)
            csv_writer.writerow(results)
    logging.info("Finished chart creation.")


def save_neural_net(circuit: ImplementedQuantumCircuit):
    data = []
    for qc in QuantumBackends.get_quantum_computer_backends():
        data.append(CircuitRunData(circuit, qc))
    for s in QuantumBackends.get_simulator_backends():
        data.append(CircuitRunData(circuit, s))

    custom_dataset = CustomDataset(data, list(range(0, 9)), window_size=2000)
    RunNeuralNet.save_model_after_training(custom_dataset)


def run_neural_net_tuner():
    data = []
    for qc in QuantumBackends.get_quantum_computer_backends():
        data.append(CircuitRunData(Walker(), qc))
    for s in QuantumBackends.get_simulator_backends():
        data.append(CircuitRunData(Walker(), s))

    custom_dataset = CustomDataset(data, list(range(0, 2)), window_size=2000)

    n = NeuralNetTuner(custom_dataset)
    n.tune_and_evaluate_model()



def run_cnn_tuner():
    data = []
    for qc in QuantumBackends.get_quantum_computer_backends():
        data.append(CircuitRunData(Walker(), qc))
    for s in QuantumBackends.get_simulator_backends():
        data.append(CircuitRunData(Walker(), s))

    custom_dataset = CustomDataset(data, list(range(0, 2)), window_size=2000)

    n = CNNTuner(custom_dataset)
    n.tune_and_evaluate_model()


if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

    for ml_approach in [run_neural_net.RunNeuralNet(), run_cnn.RunCNN(), run_svm.RunSVM()]:
        window_sizes_vs_step_ranges_all_backends(Walker(), ml_approach)
        exclude_single_quantum_computer_different_steps(Walker(), ml_approach)
        exclude_multiple_quantum_computer_different_steps(Walker(), ml_approach)
