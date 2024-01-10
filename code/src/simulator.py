import pickle
import os
from typing import Type

from qiskit import QuantumCircuit
from qiskit import transpile
from qiskit_aer import Aer
from qiskit_aer.backends.qasm_simulator import AerBackend
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker
from quantum_circuits.walker_simple import WalkerSimple
from quantum_circuits.walker_single_measures import WalkerSingleMeasures


# TODO check if files already exist (ask if they should be re-generated).
def save_quantum_circuit_simulation(circuits: list[QuantumCircuit], simulator: AerBackend, simulator_method: str,
                                    number_of_runs: int, circuit_name: str):
    print("Simulating circuit ...")
    print(f"Using {simulator.__class__.__name__} with {simulator_method}")

    for i in range(1, number_of_runs + 1):
        print(f"Simulating circuit run {i}.")
        # `transpile` transpiles the circuit into supported gates.
        # TODO is transpilation ok? (does it alter the gates)
        circs_with_simulator = transpile(circuits, simulator)

        result = simulator.run(circs_with_simulator, memory=True, shots=8000).result()

        base_path = os.path.join("../data/simulated", circuit_name)
        if not os.path.exists(base_path):
            os.makedirs(base_path)
        simulator_name = simulator.__class__.__name__.lower()
        filename = os.path.join(base_path, f"{simulator_name}_{simulator_method}-{i:06d}.p")
        pickle.dump(result.to_dict(), open(filename, 'wb'))

    print("Finished simulating.")


if __name__ == "__main__":
    circuit: ImplementedQuantumCircuit = WalkerSimple()

    # `(Aer.get_backend('aer_simulator_stabilizer'), "stabilizer")` results in an error.
    # `(Aer.get_backend('aer_simulator_unitary'), 'unitary')`: seems like it can't measure.
    # `(Aer.get_backend('aer_simulator_superop'), 'superop')`: seems like it can't measure.
    # `(Aer.get_backend('unitary_simulator'), "default")`: results in " contains invalid instructions {"instructions": {save_unitary}} for "statevector" method."
    simulator_with_method_name = [(Aer.get_backend('aer_simulator'), "default"),
                                  (Aer.get_backend('aer_simulator_density_matrix'), "density_matrix"),
                                  (Aer.get_backend('aer_simulator_statevector'), "statevector"),
                                  (Aer.get_backend('aer_simulator_matrix_product_state'), "matrix_product_state"),
                                  (Aer.get_backend('qasm_simulator'), "default"),
                                  (Aer.get_backend('statevector_simulator'), "default"),
                                  # takes very long: (Aer.get_backend('aer_simulator_extended_stabilizer'), 'extended_stabilizer'),
                                  ]

    for simulator, method_name in simulator_with_method_name:
        save_quantum_circuit_simulation(circuit.get_circuits(), simulator, method_name, 250, circuit.get_name())
