import logging

from circuit_runs import CircuitRuns
from dataset import CustomDataset
from model import svm, neural_net, neural_net_tuner, cnn, lstm
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
    #lstm_acc = lstm.evaluate_model(custom_dataset)
