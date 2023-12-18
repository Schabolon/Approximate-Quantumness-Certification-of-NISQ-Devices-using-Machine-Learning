import pickle
import os
from qiskit import QuantumCircuit
from qiskit import transpile
from qiskit_aer import Aer
from qiskit_aer.backends.qasm_simulator import AerBackend


def walker(steps):
    circ = QuantumCircuit(4, 4)
    for step in range(steps):
        if step % 3 == 0:
            circ.h(0)
            circ.h(1)
            circ.cx(0, 2)

            circ.barrier(0, 1, 2, 3)
        elif step % 3 == 1:
            circ.cx(1, 3)
            circ.x(0)

            circ.barrier(0, 1, 2, 3)
        else:
            circ.x(1)
            circ.ccx(0, 1, 2)

            circ.barrier(0, 1, 2, 3)
    circ.measure(2, 0)
    circ.measure(3, 1)

    return circ


def save_quantum_circuit_simulation(circuits: list[QuantumCircuit], simulator: AerBackend, simulator_method: str,
                                    number_of_runs: int, circuit_name: str):
    print("Simulating circuit ...")
    print("Using {}.".format(simulator.__class__.__name__))

    for i in range(1, number_of_runs + 1):
        print("Simulating circuit run {}.".format(i))
        circs_with_simulator = transpile(circuits, simulator)

        result = simulator.run(circs_with_simulator, memory=True, shots=8000).result()

        base_path = os.path.join("../data/simulated", circuit_name)
        simulator_name = simulator.__class__.__name__.lower()
        filename = os.path.join(base_path, "{}_{}-{:06d}.p".format(simulator_name, simulator_method, i))
        pickle.dump(result.to_dict(), open(filename, 'wb'))

    print("Finished simulating.")


if __name__ == "__main__":
    circuits = []
    for step in range(9):
        circuit = walker(step)
        circuits.append(circuit)

    print("Using AerSimulator with Density Matrix.")
    simulator = Aer.get_backend('aer_simulator_density_matrix')

    save_quantum_circuit_simulation(circuits, simulator, "density_matrix", 250, "walker")
