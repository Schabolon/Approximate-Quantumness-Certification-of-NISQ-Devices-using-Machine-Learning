from qiskit import QuantumCircuit
from qiskit.visualization import circuit_drawer
from matplotlib import pyplot as plt



if __name__ == "__main__":
    output_folder = "../../data/visualization/gates/"

    # Hadamard-Gate
    hadamard = QuantumCircuit(1)
    hadamard.h(0)
    hadamard.draw(output='mpl', filename=f"{output_folder}/hadamard.svg")

    # Pauli-X-Gate
    pauli_x = QuantumCircuit(1)
    pauli_x.x(0)
    pauli_x.draw(output='mpl', filename=f"{output_folder}/pauli-x.svg")

    # Cnot
    cnot = QuantumCircuit(2)
    cnot.cnot(0, 1)
    cnot.draw(output='mpl', filename=f"{output_folder}/cnot.svg")

    # Ccx
    ccx = QuantumCircuit(3)
    ccx.ccx(0, 1, 2)
    ccx.draw(output='mpl', filename=f"{output_folder}/ccx.svg")
