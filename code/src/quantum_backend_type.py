import dataclasses
from enum import Enum


@dataclasses.dataclass
class _QuantumBackendTypeDataMixin:
    label: int
    folder_name: str


class QuantumBackendType(_QuantumBackendTypeDataMixin, Enum):
    QUANTUM_COMPUTER = 0, "quantum_computer"
    SIMULATOR = 1, "simulator"
