from qiskit import QuantumCircuit


def get_default_circuits():
    first_step = 1
    steps = 10
    circs = []
    for step in range(first_step, first_step + steps):
        circs.append(__walker_simple(step))

    return circs


def __walker_simple(step: int):
    """
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