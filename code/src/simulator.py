import pickle
from qiskit import QuantumCircuit
from qiskit import transpile
from qiskit_aer import QasmSimulator
from qiskit_aer.backends.qasm_simulator import AerBackend


def walker(step):
    circ = QuantumCircuit(4, 4)
    for i in range(step):
        if i % 3 == 0:
            circ.h(0)
            circ.h(1)
            circ.cx(0, 2)

            circ.barrier(0, 1, 2, 3)
        elif i % 3 == 1:
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

def save_quantum_circuit_simulation(circuits: list[QuantumCircuit], simulator: AerBackend, number_of_runs: int, filename: str):
    print("Simulating circuit ...")
    print("Using {}.".format(simulator.__class__.__name__))

    for i in range(1, number_of_runs + 1):
        print("Simulating circuit run {}.".format(i))
        circs_with_simulator = transpile(circuits, simulator)

        result = simulator.run(circs_with_simulator, memory=True, shots=8000).result()

        dict = result.to_dict()
        #TODO better saving
        pickle.dump(dict, open("../data/simulated/walker/{}_{}.p".format(filename, i), 'wb'))

    print("Finished simulating.")


if __name__ == "__main__":
    circs = []
    for step in range(9):
        circ = walker(step)
        circs.append(circ)

    print("Using QuasmSimulator with Density Matrix.")
    simulator = QasmSimulator(method='density_matrix')

    save_quantum_circuit_simulation(circs, simulator, 250, "quasm_simulator_density_matrix")

