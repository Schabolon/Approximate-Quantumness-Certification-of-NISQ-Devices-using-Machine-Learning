"""
Provides utility functions for quantum circuits.
"""
from matplotlib import pyplot as plt
from qiskit import QuantumCircuit
from quantum_circuits import walker


def save_circuit_to_image(circ: QuantumCircuit, filename):
    circ.draw(output='mpl')
    plt.savefig(filename)


if __name__ == "__main__":
    print(walker.__walker_circuit(9))
