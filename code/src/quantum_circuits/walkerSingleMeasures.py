from qiskit import QuantumCircuit


def get_default_circuits():
    first_step = 5  # TODO: flexibel? (als Funktions-Variable angeben?)
    steps = 1
    circs = []
    for step in range(first_step, first_step + steps):
        circs.append(__walker_single_measures(step))

    return circs


def __walker_single_measures(step: int):
    """
    Circuit taken from https://github.com/trianam/learningQuantumNoiseFingerprint/blob/main/createCircuit.py
    """
    num_cubits = 4
    circ = QuantumCircuit(num_cubits, step * num_cubits * 2)
    for i in range(step):
        circ.h(0)
        circ.cx(0, 2)

        circ.barrier(range(num_cubits))
        for q in range(num_cubits):
            circ.measure(q, (i * num_cubits * 2) + q)
        circ.barrier(range(num_cubits))

        circ.h(1)
        circ.cx(1, 3)

        circ.barrier(range(num_cubits))
        for q in range(num_cubits):
            circ.measure(q, (i * num_cubits * 2) + num_cubits + q)
        circ.barrier(range(num_cubits))

    return circ
