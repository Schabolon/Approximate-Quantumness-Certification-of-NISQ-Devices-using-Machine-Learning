import pickle
import os

from qiskit_aer import AerSimulator
from qiskit import transpile

from data_sources import simulators
from quantum_circuits import circuits
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


def save_quantum_circuit_simulation(implemented_circuit: ImplementedQuantumCircuit, simulator: AerSimulator,
                                    number_of_runs: int):
    print("Simulating circuit ...")
    simulator_name = simulators.get_simulator_name(simulator)
    print(f"Using {simulator_name} on circuit {implemented_circuit.get_name()}")

    base_path = os.path.join("../data/simulator", implemented_circuit.get_name())
    if not os.path.exists(base_path):
        os.makedirs(base_path)

    for i in range(1, number_of_runs + 1):
        filename = os.path.join(base_path, f"{simulator_name}-{i:06d}.p")
        if os.path.exists(filename):
            print(f"Data for {simulator_name} on circuit {implemented_circuit.get_name()} already exists.")
            print("Skipping ...")
            return

        print(f"Simulating circuit run {i}/{number_of_runs}.")
        # transpiles the circuit into supported gates.
        # TODO is transpilation ok? (does it alter the gates)
        transpiled_circuits = transpile(implemented_circuit.get_circuits(), simulator)

        result = simulator.run(transpiled_circuits, memory=True, shots=8000).result()

        pickle.dump(result.to_dict(), open(filename, 'wb'))

    print("Finished simulating.")


if __name__ == "__main__":
    for implemented_circuit in circuits.circuits:
        for simulator in simulators.simulators:
            save_quantum_circuit_simulation(implemented_circuit, simulator, 250)
