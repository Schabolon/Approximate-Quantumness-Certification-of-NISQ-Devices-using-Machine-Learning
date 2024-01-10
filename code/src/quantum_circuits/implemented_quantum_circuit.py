from abc import abstractmethod, ABC
from qiskit import QuantumCircuit


class ImplementedQuantumCircuit(ABC):
    first_step: int
    steps: int

    def __init__(self, first_step: int, steps: int):
        self.first_step = first_step
        self.steps = steps

    def get_circuits(self) -> list[QuantumCircuit]:
        circs = []
        for step in range(self.first_step, self.first_step + self.steps):
            circs.append(self.get_circuit_at(step))

        return circs

    @staticmethod
    @abstractmethod
    def get_circuit_at(step: int) -> QuantumCircuit:
        pass

    @staticmethod
    @abstractmethod
    def get_name() -> str:
        pass
