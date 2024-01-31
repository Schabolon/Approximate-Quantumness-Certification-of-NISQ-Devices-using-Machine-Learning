from qiskit import QuantumCircuit
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class WalkerSimple(ImplementedQuantumCircuit):

    def __init__(self, first_step: int = 1, steps: int = 10):
        super().__init__(first_step, steps, "walkerSimple")

    @staticmethod
    def get_circuit_at(step: int):
        """
        The WalkerSimple circuit with 10 steps: (each step is separated by lines with ░)
             ┌───┐      ░            ░ ┌───┐      ░            ░ ┌───┐      ░            ░ ┌───┐      ░            ░ ┌───┐      ░            ░ ┌─┐
        q_0: ┤ H ├──■───░────────────░─┤ H ├──■───░────────────░─┤ H ├──■───░────────────░─┤ H ├──■───░────────────░─┤ H ├──■───░────────────░─┤M├─────────
             └───┘  │   ░ ┌───┐      ░ └───┘  │   ░ ┌───┐      ░ └───┘  │   ░ ┌───┐      ░ └───┘  │   ░ ┌───┐      ░ └───┘  │   ░ ┌───┐      ░ └╥┘┌─┐
        q_1: ───────┼───░─┤ H ├──■───░────────┼───░─┤ H ├──■───░────────┼───░─┤ H ├──■───░────────┼───░─┤ H ├──■───░────────┼───░─┤ H ├──■───░──╫─┤M├──────
                  ┌─┴─┐ ░ └───┘  │   ░      ┌─┴─┐ ░ └───┘  │   ░      ┌─┴─┐ ░ └───┘  │   ░      ┌─┴─┐ ░ └───┘  │   ░      ┌─┴─┐ ░ └───┘  │   ░  ║ └╥┘┌─┐
        q_2: ─────┤ X ├─░────────┼───░──────┤ X ├─░────────┼───░──────┤ X ├─░────────┼───░──────┤ X ├─░────────┼───░──────┤ X ├─░────────┼───░──╫──╫─┤M├───
                  └───┘ ░      ┌─┴─┐ ░      └───┘ ░      ┌─┴─┐ ░      └───┘ ░      ┌─┴─┐ ░      └───┘ ░      ┌─┴─┐ ░      └───┘ ░      ┌─┴─┐ ░  ║  ║ └╥┘┌─┐
        q_3: ───────────░──────┤ X ├─░────────────░──────┤ X ├─░────────────░──────┤ X ├─░────────────░──────┤ X ├─░────────────░──────┤ X ├─░──╫──╫──╫─┤M├
                        ░      └───┘ ░            ░      └───┘ ░            ░      └───┘ ░            ░      └───┘ ░            ░      └───┘ ░  ║  ║  ║ └╥┘
        c: 4/═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╩══╩══╩══╩═
                                                                                                                                                0  1  2  3

        Circuit taken from https://github.com/trianam/learningQuantumNoiseFingerprint/blob/main/createCircuit.py
        """
        circ = QuantumCircuit(4, 4)
        for i in range(step):
            if i % 2 == 0:
                circ.h(0)
                circ.cx(0, 2)
                circ.barrier(0, 1, 2, 3)
            else:
                circ.h(1)
                circ.cx(1, 3)
                circ.barrier(0, 1, 2, 3)

        for q in range(len(circ.qubits)):
            circ.measure(q, q)

        return circ
