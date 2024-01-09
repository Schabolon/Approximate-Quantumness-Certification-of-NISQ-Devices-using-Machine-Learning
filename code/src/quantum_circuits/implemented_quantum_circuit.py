from abc import abstractmethod, ABC
from qiskit import QuantumCircuit


class ImplementedQuantumCircuit(ABC):

    @abstractmethod
    def get_default_circuits(self) -> list[QuantumCircuit]:
        pass

    @staticmethod
    @abstractmethod
    def get_name() -> str:
        pass
