import logging
import csv

from circuit_runs import CircuitRuns
from dataset import CustomDataset
from model import svm, neural_net, neural_net_tuner, cnn, lstm
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker


def create_stats_csv(circuit: ImplementedQuantumCircuit):
    with (open(f"../results/{circuit.get_name()}_svm_quantum_vs_simulator.csv", 'w', newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        first_row = ['quantum computer name / quantum computer name']
        first_row.extend(QuantumBackends.get_quantum_computer_backends())
        csv_writer.writerow(first_row)

        for row_num, qc in enumerate(QuantumBackends.get_quantum_computer_backends()):
            if row_num == 0:
                # skip the first row
                continue
            qc_data = CircuitRuns(circuit, qc)
            results = []
            for column_num, simulator in enumerate(QuantumBackends.get_simulator_backends()):
                if row_num == column_num:
                    results.append(0.0)
                    continue

                # remove "duplicates" (order doesn't matter)
                if column_num > row_num:
                    results.append(0.0)
                    continue

                qc_data_2 = CircuitRuns(circuit, simulator)

                data = [qc_data, qc_data_2]
                custom_dataset = CustomDataset(data)
                svm_acc = svm.evaluate_svm(custom_dataset)
                results.append(svm_acc)
            results.insert(0, qc.backend_name)
            csv_writer.writerow(results)


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
    svm_acc = svm.evaluate_svm(custom_dataset)

    # Neural Model
    neural_net_acc = neural_net.evaluate_neural_net(custom_dataset)

    # Tuning Neural Model
    tuned_neural_net_acc = neural_net_tuner.tune_and_evaluate_model(custom_dataset)

    # CNN
    cnn_acc = cnn.evaluate_model(custom_dataset)

    # LSTM
    # todo WIP
    # lstm_acc = lstm.evaluate_model(custom_dataset)


if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)
    create_stats_csv(Walker())
