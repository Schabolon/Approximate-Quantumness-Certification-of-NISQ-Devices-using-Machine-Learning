from qiskit import QuantumCircuit
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class WalkerSimple(ImplementedQuantumCircuit):

    def get_default_circuits(self) -> list[QuantumCircuit]:
        first_step = 1
        steps = 10
        circs = []
        for step in range(first_step, first_step + steps):
            circs.append(self.__walker_simple(step))

        return circs

    @staticmethod
    def __walker_simple(step: int):
        """
        The circuit with 10 steps: (each step is separated by lines with ░)
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

    @staticmethod
    def get_name() -> str:
        return "walkerSimple"
