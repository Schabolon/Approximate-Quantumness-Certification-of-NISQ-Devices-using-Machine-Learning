import logging
import csv
import os

from circuit_runs import CircuitRuns
from dataset import CustomDataset
from model import run_svm, run_neural_net, neural_net_tuner, cnn, lstm
from model.ml_wrapper import MLWrapper
from quantum_backends import QuantumBackends, QuantumBackend
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
            qc_data = CircuitRuns(circuit, qc)
            results = []
            for simulator in QuantumBackends.get_simulator_backends():
                qc_data_2 = CircuitRuns(circuit, simulator)

                data = [qc_data, qc_data_2]
                custom_dataset = CustomDataset(data, [0], window_size=window_size)
                acc = ml_model.train_and_evaluate(custom_dataset)
                # store float as string with 2 decimal places
                results.append("%.3f" % acc)
            results.insert(0, qc.backend_name)
            csv_writer.writerow(results)
    logging.info("Finished creating stats CSV ...")


# chart of different window sizes
def chart_probability_windows(circuit: ImplementedQuantumCircuit, ml_model: MLWrapper, quantum_backend: QuantumBackends, quantum_backend_2: QuantumBackends):
    logging.info("Creating chart for probability with different windows ...")
    path = "../results"
    os.makedirs(path, exist_ok=True)
    with (open(f"{path}/{circuit.get_name()}_{ml_model.get_name()}_different_probabilities_{quantum_backend.backend_name}_vs_{quantum_backend_2.backend_name}.csv", 'w',
               newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(['window size', 'accuracy'])
        for window_size in [0, 1, 5, 8, 10, 40, 50, 80, 100, 200, 400, 800, 1000, 2000, 4000, 8000]:
            logging.debug(f"Calculating accuracy with window size {window_size}.")
            results = [window_size]
            # todo can I put data outside of the loop?
            data = [CircuitRuns(circuit, quantum_backend), CircuitRuns(circuit, quantum_backend_2)]
            custom_dataset = CustomDataset(data, window_size)
            acc = ml_model.train_and_evaluate(custom_dataset)
            # store float as string with 2 decimal places
            results.append("%.3f" % acc)
            csv_writer.writerow(results)
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
        data = [CircuitRuns(circuit, quantum_backend), CircuitRuns(circuit, quantum_backend_2)]
        for step in range(0, 9):
            steps.append(step)
            logging.debug(f"Calculating accuracy for steps {steps}.")
            results = [step + 1]

            # single step
            custom_dataset = CustomDataset(data, [step], window_size=window_size)
            single_step_acc = ml_model.train_and_evaluate(custom_dataset)
            # store float as string with 2 decimal places
            results.append("%.3f" % single_step_acc)

            custom_dataset = CustomDataset(data, steps, window_size=window_size)
            acc = ml_model.train_and_evaluate(custom_dataset)
            # store float as string with 2 decimal places
            results.append("%.3f" % acc)
            csv_writer.writerow(results)
    logging.info("Finished chart creation.")


def basic_usage():
    circuit = Walker()
    qc = QuantumBackends.IBMQ_CASABLANCA
    simulator = QuantumBackends.AER_SIMULATOR

    qc_data = CircuitRuns(circuit, qc)
    simulator_data = CircuitRuns(circuit, simulator)

    data = [qc_data, simulator_data]

    custom_dataset = CustomDataset(data)

    # Execute different learning algorithms
    # SVM
    svm_acc = run_svm.RunSVM.train_and_evaluate(custom_dataset)

    # Neural Model
    neural_net_acc = run_neural_net.RunNeuralNet.train_and_evaluate(custom_dataset)

    # Tuning Neural Model
    tuned_neural_net_acc = neural_net_tuner.tune_and_evaluate_model(custom_dataset)

    # CNN
    cnn_acc = cnn.evaluate_model(custom_dataset)

    # LSTM
    # todo WIP
    # lstm_acc = lstm.evaluate_model(custom_dataset)


if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)
    #create_quantum_computers_vs_simulators_stats_csv(Walker(), svm.SupportVectorMachine(), window_size=1000)
    course_of_accuracy_different_steps(Walker(), run_neural_net.RunNeuralNet(), QuantumBackends.IBMQ_LIMA, QuantumBackends.QUASM_SIMULATOR, window_size=1000)
    #chart_probability_windows(Walker(), svm.SupportVectorMachine(), QuantumBackends.IBMQ_QUITO, QuantumBackends.AER_SIMULATOR)
