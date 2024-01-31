import logging

from circuit_runs import CircuitRuns
from dataset import CustomDataset
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

    dataset = CustomDataset(data).get_dataset()

    # 4. Execute different learning algorithms
    # 4.1 SVM

    # 4.2 Neuronal Model

    # 4.3 Tuning Neuronal Model

    # TODO CNN
    # TODO LSTM