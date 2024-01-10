from qiskit import QuantumCircuit
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class Ramsey(ImplementedQuantumCircuit):

    def __init__(self, first_step: int = 1, steps: int = 10):
        super().__init__(first_step, steps)

    @staticmethod
    def get_circuit_at(step: int):
        """
             ┌───┐ ░ ┌───┐┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐┌───┐ ░ ┌───┐ ░ ┌─┐
          q: ┤ H ├─░─┤ S ├┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ X ├┤ S ├─░─┤ H ├─░─┤M├
             └───┘ ░ └───┘└───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘└───┘ ░ └───┘ ░ └╥┘
        c: 1/════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╩═
                                                                                                                                                                     0

        Circuit taken from https://github.com/trianam/learningQuantumNoiseFingerprint/blob/main/createCircuit.py
        """
        circ = QuantumCircuit(1, 1)
        circ.h(0)
        circ.barrier(0)
        circ.s(0)
        for i in range(step):
            circ.x(0)
            circ.s(0)
            circ.barrier(0)
        circ.h(0)
        circ.barrier(0)

        circ.measure(0, 0)
        return circ

    @staticmethod
    def get_name() -> str:
        return "ramsey"
