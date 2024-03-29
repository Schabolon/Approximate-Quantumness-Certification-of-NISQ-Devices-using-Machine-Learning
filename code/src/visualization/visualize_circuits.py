from matplotlib import pyplot as plt
from qiskit import QuantumCircuit

from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.ramsey import Ramsey
from quantum_circuits.walker import Walker
from quantum_circuits.walker_simple import WalkerSimple
from quantum_circuits.walker_single_measures import WalkerSingleMeasures


def get_all_circuits() -> list[ImplementedQuantumCircuit]:
    return [Walker(), WalkerSimple(), WalkerSingleMeasures(), Ramsey()]


def save_circuits_to_image(circs: list[QuantumCircuit], circuit_name: str):
    for i in range(len(circs)):
        circs[i].draw(output='mpl')
        plt.savefig(f"../../visualization/circuit_images/{circuit_name}-step-{i + 1}.svg")
        plt.close()


def save_images_for_all_circuits():
    for circuit in get_all_circuits():
        save_circuits_to_image(circuit.get_circuits(), circuit.get_name())


def display_all_circuits_as_text():
    for circuit in get_all_circuits():
        print(f"{circuit.get_name()} Circuit:")
        print(circuit.get_circuits()[-1])
        print("")


if __name__ == "__main__":
    #display_all_circuits_as_text()
    save_circuits_to_image(Walker().get_circuits(), "walker")
