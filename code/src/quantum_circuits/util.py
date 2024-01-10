"""
Provides utility functions for quantum circuits.
"""
from matplotlib import pyplot as plt
from qiskit import QuantumCircuit
from quantum_circuits.ramsey import Ramsey
from quantum_circuits.walker import Walker
from quantum_circuits.walker_simple import WalkerSimple
from quantum_circuits.walker_single_measures import WalkerSingleMeasures


def save_circuits_to_image(circs: list[QuantumCircuit], circuit_name: str):
    for i in range(len(circs)):
        circs[i].draw(output='mpl')
        plt.savefig("../../circuit_images/{}-step-{}.svg".format(circuit_name, i + 1))
        plt.close()


def save_images_for_all_circuits():
    circuits = [Walker(), WalkerSimple(), WalkerSingleMeasures(), Ramsey()]
    for circuit in circuits:
        save_circuits_to_image(circuit.get_circuits(), circuit.get_name())


def display_all_circuits_as_text():
    circuits = [Walker(), WalkerSimple(), WalkerSingleMeasures(), Ramsey()]
    for circuit in circuits:
        print(f"{circuit.get_name()} Circuit:")
        print(circuit.get_circuits()[-1])
        print("")


if __name__ == "__main__":
    display_all_circuits_as_text()
