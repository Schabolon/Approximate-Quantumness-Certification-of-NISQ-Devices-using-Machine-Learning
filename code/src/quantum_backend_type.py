import dataclasses
from enum import Enum


# Todo is this class a mixin?
@dataclasses.dataclass
class QuantumBackendTypeData:
    label: int
    folder_name: str


class QuantumBackendType(QuantumBackendTypeData, Enum):
    QUANTUM_COMPUTER = 0, "quantum_computer"
    SIMULATOR = 1, "simulator"
