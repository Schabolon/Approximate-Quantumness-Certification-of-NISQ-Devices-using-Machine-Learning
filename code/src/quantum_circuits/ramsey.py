from qiskit import QuantumCircuit


def get_default_circuits():
    first_step = 1
    steps = 10
    circs = []
    for step in range(first_step, first_step + steps):
        circs.append(__ramsey(step))

    return circs


def __ramsey(step: int):
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
