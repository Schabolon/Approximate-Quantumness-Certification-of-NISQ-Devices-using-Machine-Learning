import glob
import os
import pickle
import numpy as np

from quantum_circuits import util


def calculate_probabilities(executions, window_size: int, source_type: str, circuit_name: str, source_name: str):
    if executions.shape[0] % window_size > 0:
        raise (Exception("Not divisible"))

    print(f"Calculate probabilities with window_size={window_size}")
    # shape[0]: Zeilen, shape[1]: Spalten
    probabilities = np.zeros((int(executions.shape[0] / window_size), executions.shape[1], len(np.unique(executions))),
                             dtype='float32')
    for n in range(executions.shape[0]):
        i = int(n / window_size)
        for t in range(executions.shape[1]):
            probabilities[i, t, executions[n, t]] += 1

    probabilities = probabilities / window_size
    path = f"../data/probabilities/{source_type}/{circuit_name}"
    os.makedirs(path, exist_ok=True)
    save_file = os.path.join(path, f"probabilities-{window_size}-{source_name}.npy")
    print(f"Saving probabilities in {save_file} with shape {probabilities.shape}")
    np.save(save_file, probabilities)


def extract_executions(source_type: str, circuit_name: str, source_name: str):
    executions = []
    print(f"Extracting executions from {source_name} for circuit {circuit_name}")
    for filename in sorted(glob.glob(
            os.path.join(f"../data/{source_type}/{circuit_name}", f"{source_name}-" + ('[0-9]' * 6) + '.p'))):
        circuit_results = pickle.load(open(filename, 'rb'))
        for n in range(len(circuit_results['results'][0]['data']['memory'])):
            current_execution = []
            for t in range(len(circuit_results['results'])):
                execution = int(circuit_results['results'][t]['data']['memory'][n], 0)
                current_execution.append(execution)
            executions.append(current_execution)

    executions = np.array(executions)
    path = f"../data/extracted_executions/{source_type}/{circuit_name}"
    os.makedirs(path, exist_ok=True)
    save_file = os.path.join(path, f"executions-{source_name}.csv")
    print(f"Saving executions in {save_file} with shape {executions.shape}")
    np.savetxt(save_file, executions, delimiter=',')
    return executions


if __name__ == "__main__":
    for circuit in util.get_all_circuits():
        for quantum_computer_name in config.quantum_computer_names:
            source_type: str = "quantum_computer"
            extracted_executions = extract_executions(source_type, circuit.get_name(), quantum_computer_name)
            calculate_probabilities(extracted_executions, 1000, source_type, circuit.get_name(), quantum_computer_name)

        for simulator_name in config.get_all_simulator_names():
            source_type: str = "simulated"
            extracted_executions = extract_executions(source_type, circuit.get_name(), simulator_name)
            calculate_probabilities(extracted_executions, 1000, source_type, circuit.get_name(), simulator_name)
