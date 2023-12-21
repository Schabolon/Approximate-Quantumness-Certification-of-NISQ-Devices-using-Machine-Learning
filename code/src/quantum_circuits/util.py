"""
Provides utility functions for quantum circuits.
"""
from matplotlib import pyplot as plt
from qiskit import QuantumCircuit
from quantum_circuits import walker, ramsey, walkerSimple, walkerSingleMeasures


def save_circuits_to_image(circs: list[QuantumCircuit], circuit_name: str):
    for i in range(len(circs)):
        circs[i].draw(output='mpl')
        plt.savefig("../../circuit_images/{}-step-{}.svg".format(circuit_name, i + 1))
        plt.close()


if __name__ == "__main__":
    save_circuits_to_image(walker.get_default_circuits(), "walker")
    save_circuits_to_image(walkerSimple.get_default_circuits(), "walker-simple")
    save_circuits_to_image(walkerSingleMeasures.get_default_circuits(), "walker-single-measures")
    save_circuits_to_image(ramsey.get_default_circuits(), "ramsey")
