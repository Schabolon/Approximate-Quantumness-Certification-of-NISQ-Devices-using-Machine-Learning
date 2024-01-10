from qiskit import QuantumCircuit
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class WalkerSingleMeasures(ImplementedQuantumCircuit):

    # TODO what value has been used for `steps`.
    def __init__(self, first_step: int = 5, steps: int = 1):
        super().__init__(first_step, steps)

    @staticmethod
    def get_circuit_at(step: int):
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

    @staticmethod
    def get_name() -> str:
        return "walkerSingleMeasures"
