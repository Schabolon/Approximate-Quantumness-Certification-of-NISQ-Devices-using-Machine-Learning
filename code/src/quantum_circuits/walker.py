from qiskit import QuantumCircuit


def get_default_circuits():
    first_step = 1
    steps = 9
    circs = []
    for step in range(first_step, first_step + steps):
        circs.append(__walker_circuit(step))

    return circs


def __walker_circuit(step: int):
    """
    The circuit with 9 steps: (each step is separated by lines with ░)
         ┌───┐      ░ ┌───┐ ░            ░ ┌───┐      ░ ┌───┐ ░            ░ ┌───┐      ░ ┌───┐ ░            ░
    q_0: ┤ H ├──■───░─┤ X ├─░────────■───░─┤ H ├──■───░─┤ X ├─░────────■───░─┤ H ├──■───░─┤ X ├─░────────■───░───────
         ├───┤  │   ░ └───┘ ░ ┌───┐  │   ░ ├───┤  │   ░ └───┘ ░ ┌───┐  │   ░ ├───┤  │   ░ └───┘ ░ ┌───┐  │   ░
    q_1: ┤ H ├──┼───░───■───░─┤ X ├──■───░─┤ H ├──┼───░───■───░─┤ X ├──■───░─┤ H ├──┼───░───■───░─┤ X ├──■───░───────
         └───┘┌─┴─┐ ░   │   ░ └───┘┌─┴─┐ ░ └───┘┌─┴─┐ ░   │   ░ └───┘┌─┴─┐ ░ └───┘┌─┴─┐ ░   │   ░ └───┘┌─┴─┐ ░ ┌─┐
    q_2: ─────┤ X ├─░───┼───░──────┤ X ├─░──────┤ X ├─░───┼───░──────┤ X ├─░──────┤ X ├─░───┼───░──────┤ X ├─░─┤M├───
              └───┘ ░ ┌─┴─┐ ░      └───┘ ░      └───┘ ░ ┌─┴─┐ ░      └───┘ ░      └───┘ ░ ┌─┴─┐ ░      └───┘ ░ └╥┘┌─┐
    q_3: ───────────░─┤ X ├─░────────────░────────────░─┤ X ├─░────────────░────────────░─┤ X ├─░────────────░──╫─┤M├
                    ░ └───┘ ░            ░            ░ └───┘ ░            ░            ░ └───┘ ░            ░  ║ └╥┘
    c: 4/═══════════════════════════════════════════════════════════════════════════════════════════════════════╩══╩═
                                                                                                                0  1

    Circuit taken from https://github.com/trianam/learningQuantumNoiseFingerprint/blob/main/createCircuit.py
    """
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
