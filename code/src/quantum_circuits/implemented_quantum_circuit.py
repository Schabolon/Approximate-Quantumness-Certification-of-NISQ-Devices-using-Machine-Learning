from abc import abstractmethod, ABC
from qiskit import QuantumCircuit


class ImplementedQuantumCircuit(ABC):

    @staticmethod
    @abstractmethod
    def get_default_circuits() -> list[QuantumCircuit]:
        pass

    @staticmethod
    @abstractmethod
    def get_name() -> str:
        pass
