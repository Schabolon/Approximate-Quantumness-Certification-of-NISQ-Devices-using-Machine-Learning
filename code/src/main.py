import logging

from circuit_runs import CircuitRuns
from dataset import CustomDataset
from model import svm
from quantum_backends import QuantumBackends
from quantum_circuits.walker import Walker

if __name__ == '__main__':
    logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

    circuit = Walker()
    qc = QuantumBackends.IBMQ_CASABLANCA
    simulator = QuantumBackends.AER_SIMULATOR

    qc_data = CircuitRuns(circuit, qc)
    simulator_data = CircuitRuns(circuit, simulator)

    data = [qc_data, simulator_data]

    custom_dataset = CustomDataset(data)

    custom_dataset.print_overview()

    # Execute different learning algorithms
    # SVM
    svm.evaluate_svm(custom_dataset)

    # Neural Model

    # Tuning Neural Model

    # TODO CNN
    # TODO LSTM