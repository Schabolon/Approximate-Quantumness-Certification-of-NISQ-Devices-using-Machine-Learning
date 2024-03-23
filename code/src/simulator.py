import pickle
import os
import logging

from qiskit_aer import AerSimulator, Aer
from qiskit import transpile

from quantum_backend_type import QuantumBackendType
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


def save_quantum_circuit_simulation(implemented_circuit: ImplementedQuantumCircuit, simulator_info: QuantumBackends,
                                    number_of_runs=250, shots=8000) -> list[str]:
    """
    Simulates a quantum circuit with a simulator_backend for `number_of_runs` times and saves the results to the hard drive.

    :param implemented_circuit: the circuit to simulate.
    :param simulator_info: information about the simulator_backend to use.
    :param number_of_runs: number of times the circuit is simulated.
    :param shots: number of shots for each run.
    :return: list of absolute paths to the files containing the simulation results.
    """
    assert simulator_info.backend_type == QuantumBackendType.SIMULATOR
    logging.info("Simulating circuit ...")
    logging.debug(f"Using {simulator_info.backend_name} on circuit {implemented_circuit.get_name()}")

    base_path = os.path.join("../data/simulator", implemented_circuit.get_name())
    os.makedirs(base_path, exist_ok=True)

    output_file_paths = []

    if simulator_info.noisy_backend is None:
        simulator_backend = Aer.get_backend(simulator_info.backend_name)
    else:
        simulator_backend = AerSimulator.from_backend(simulator_info.noisy_backend)

    for i in range(1, number_of_runs + 1):
        filename = os.path.join(base_path, f"{simulator_info.backend_name}-{i:06d}.p")
        if os.path.exists(filename):
            logging.info(
                f"Data for {simulator_info.backend_name} on circuit {implemented_circuit.get_name()} already exists.")
            output_file_paths.append(filename)
            continue

        logging.info(f"Simulating circuit run {i}/{number_of_runs}.")
        # transpiles the circuits into supported gates.
        transpiled_circuits = transpile(implemented_circuit.get_circuits(), simulator_backend)

        result = simulator_backend.run(transpiled_circuits, memory=True, shots=shots).result()

        pickle.dump(result.to_dict(), open(filename, 'wb'))
        output_file_paths.append(os.path.abspath(filename))

    logging.info("Finished simulating.")
    return output_file_paths
