import pickle
import os
import logging

from qiskit_aer import AerSimulator
from qiskit import transpile

from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


def save_quantum_circuit_simulation(implemented_circuit: ImplementedQuantumCircuit, simulator_name: str,
                                    number_of_runs=250, shots=8000) -> list[str]:
    """
    Simulates a quantum circuit with a simulator for `number_of_runs` times and saves the results to the hard drive.

    :param implemented_circuit: the circuit to simulate.
    :param simulator_name: the name of simulator to use.
    :param number_of_runs: number of times the circuit is simulated.
    :param shots: number of shots for each run.
    :return: list of absolute paths to the files containing the simulation results.
    """
    logging.info("Simulating circuit ...")
    logging.debug(f"Using {simulator_name} on circuit {implemented_circuit.get_name()}")

    base_path = os.path.join("../data/simulator", implemented_circuit.get_name())
    os.makedirs(base_path, exist_ok=True)

    output_file_paths = []

    simulator = AerSimulator.from_backend(simulator_name)

    for i in range(1, number_of_runs + 1):
        filename = os.path.join(base_path, f"{simulator_name}-{i:06d}.p")
        if os.path.exists(filename):
            logging.info(f"Data for {simulator_name} on circuit {implemented_circuit.get_name()} already exists.")
            output_file_paths.append(filename)
            continue

        logging.info(f"Simulating circuit run {i}/{number_of_runs}.")
        # transpiles the circuit into supported gates.
        transpiled_circuits = transpile(implemented_circuit.get_circuits(), simulator)

        result = simulator.run(transpiled_circuits, memory=True, shots=shots).result()

        pickle.dump(result.to_dict(), open(filename, 'wb'))
        output_file_paths.append(os.path.abspath(filename))

    logging.info("Finished simulating.")
    return output_file_paths
