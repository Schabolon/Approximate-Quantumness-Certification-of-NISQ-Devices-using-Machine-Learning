import csv
import logging
import os
from typing import List

import visualization.visualize_histogram
from circuit_run_data import CircuitRunData
from dataset import CustomDataset, NormalizationTechnique
from model import run_svm, run_neural_net, neural_net_tuner, run_cnn
from model.ml_wrapper import MLWrapper
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker


def create_quantum_computers_vs_simulators_stats_csv(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper, window_size=0):
    logging.info("Creating stats CSV ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{circuit.get_name()}_{ml_model.get_name()}_quantum_vs_simulator_window_size_{window_size}.csv", 'w', newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        first_row = ['quantum computer name / simulator name']
        first_row.extend(QuantumBackends.get_simulator_backends())
        csv_writer.writerow(first_row)

        for qc in QuantumBackends.get_quantum_computer_backends():
            qc_data = CircuitRunData(circuit, qc)
            results = []
            for simulator in QuantumBackends.get_simulator_backends():
                qc_data_2 = CircuitRunData(circuit, simulator)

                data = [qc_data, qc_data_2]
                custom_dataset = CustomDataset(data, [0], window_size=window_size)
                acc = ml_model.train_and_evaluate(custom_dataset)
                # store float as string with 3 decimal places
                results.append("%.3f" % acc)
            results.insert(0, qc.backend_name)
            csv_writer.writerow(results)
    logging.info("Finished creating stats CSV ...")


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

        csv_writer.writerow(['window size/step ranges', '[1]', '[1 ... 2]', '[1 ... 3]', '[1 ... 4]', '[1 ... 5]', '[1 ... 6]', '[1 ... 7]', '[1 ... 8]', '[1 ... 9]'])
        for window_size in [50, 80, 100, 200, 400, 800, 1000, 2000, 4000, 8000]:  # removed: 5, 8, 10, 40
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


def course_of_accuracy_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper, quantum_backend: QuantumBackends, quantum_backend_2: QuantumBackends, window_size=1000):
    logging.info("Creating course of accuracy with different steps ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{circuit.get_name()}_{ml_model.get_name()}_variable_steps_{quantum_backend.backend_name}_vs_{quantum_backend_2.backend_name}_window_size_{window_size}.csv", 'w',
               newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(['step k', 'single step accuracy k', 'step range accuracy 1 to k'])
        steps = []
        data = [CircuitRunData(circuit, quantum_backend), CircuitRunData(circuit, quantum_backend_2)]
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


def exclude_quantum_computer_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper, window_size=2000):
    logging.info("Creating table with excluded quantum computer vs step ranges for all other backends combined ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{ml_model.get_name()}_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv", 'w',
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
                additional_test_dataset = CustomDataset([CircuitRunData(circuit, qc_to_exclude)], steps, window_size=window_size)
                acc = ml_model.train_and_evaluate(custom_dataset, additional_test_dataset=additional_test_dataset)
                # store float as string with 3 decimal places
                row_results.append("%.3f" % acc)
            csv_writer.writerow(row_results)
        logging.info("Finished chart creation.")


def accuracy_quantum_computers_vs_simulators_different_steps(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper, window_size=1000):
    logging.info("Creating accuracy with different steps for combination of quantum computers vs all simulators ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{circuit.get_name()}_{ml_model.get_name()}_quantum_computers_vs_simulators_window_size_{window_size}.csv", 'w',
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


def basic_usage():
    circuit = Walker()
    qc = QuantumBackends.IBMQ_CASABLANCA
    simulator = QuantumBackends.AER_SIMULATOR

    qc_data = CircuitRunData(circuit, qc)
    simulator_data = CircuitRunData(circuit, simulator)

    data = [qc_data, simulator_data]

    custom_dataset = CustomDataset(data, list(range(0, 1)), 1000, NormalizationTechnique.NONE)

    # Execute different learning algorithms
    # SVM
    #svm_acc = run_svm.RunSVM.train_and_evaluate(custom_dataset)

    # Neural Model
    neural_net_acc = run_neural_net.RunNeuralNet.train_and_evaluate(custom_dataset)

    # Tuning Neural Model
    #tuned_neural_net_acc = neural_net_tuner.tune_and_evaluate_model(custom_dataset)

    # CNN
    cnn_acc = run_cnn.RunCNN.train_and_evaluate(custom_dataset)


if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

    #window_sizes_vs_step_ranges_all_backends(Walker(), run_neural_net.RunNeuralNet())
    #window_sizes_vs_step_ranges_all_backends(Walker(), run_cnn.RunCNN())
    #window_sizes_vs_step_ranges_all_backends(Walker(), run_svm.RunSVM())

    exclude_quantum_computer_different_steps(Walker(), run_cnn.RunCNN())
    exclude_quantum_computer_different_steps(Walker(), run_svm.RunSVM())
    exclude_quantum_computer_different_steps(Walker(), run_neural_net.RunNeuralNet())

    #visualization.visualize_histogram.plot_overview_histogram(Walker(), 1)
    #accuracy_quantum_computers_vs_simulators_different_steps(Walker(), run_neural_net.RunNeuralNet(), window_size=1000)
    #basic_usage()
    #create_quantum_computers_vs_simulators_stats_csv(Walker(), run_svm.RunSVM(), window_size=1000)
    #course_of_accuracy_different_steps(Walker(), run_svm.RunSVM(), QuantumBackends.IBMQ_LIMA, QuantumBackends.FAKE_VIGO_V2, window_size=1000)
    #steps = []
    #for step in range(0, 9):
    #    steps.append(step)
    #    chart_probability_windows(Walker(), run_svm.RunSVM(), QuantumBackends.IBMQ_QUITO, QuantumBackends.FAKE_VIGO_V2, steps)
