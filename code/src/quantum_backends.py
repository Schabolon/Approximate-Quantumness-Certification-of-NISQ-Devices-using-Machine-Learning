from enum import Enum

from dataclasses import dataclass
from quantum_backend_type import QuantumBackendType


# Todo is this class a mixin?
@dataclass
class QuantumBackend:
    backend_name: str
    backend_type: QuantumBackendType


# todo use flag instead of enum?
class QuantumBackends(QuantumBackend, Enum):
    # Quantum Computers
    IBMQ_ATHENS = "ibmq_athens", QuantumBackendType.QUANTUM_COMPUTER
    IMBQ_SANTIAGO = "ibmq_santiago", QuantumBackendType.QUANTUM_COMPUTER
    IBMQ_CASABLANCA = "ibmq_casablanca", QuantumBackendType.QUANTUM_COMPUTER
    IBMQ_CASABLANCA_BIS = "ibmq_casablanca-bis", QuantumBackendType.QUANTUM_COMPUTER
    IBMQ_5_YORKTOWN = "ibmq_5_yorktown", QuantumBackendType.QUANTUM_COMPUTER
    IBMQ_BOGOTA = "ibmg_bogota", QuantumBackendType.QUANTUM_COMPUTER
    IBMQ_QUITO = "ibmq_quito", QuantumBackendType.QUANTUM_COMPUTER
    # ROME is only used for circuit "Ramsey"
    IBMQ_ROME = "ibmq_rome", QuantumBackendType.QUANTUM_COMPUTER

    # Quantum Computer split data:
    # 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A',
    # 'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D',
    # 'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G',
    # 'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J',

    # Simulators
    # Simulators without error models
    AER_SIMULATOR = "aer_simulator", QuantumBackendType.SIMULATOR
    AER_SIMULATOR_DENSITY_MATRIX = "aer_simulator_density_matrix", QuantumBackendType.SIMULATOR
    AER_SIMULATOR_STATEVECTOR = "aer_simulator_statevector", QuantumBackendType.SIMULATOR
    AER_SIMULATOR_MATRIX_PRODUCT_STATE = "aer_simulator_matrix_product_state", QuantumBackendType.SIMULATOR
    STATEVECTOR_SIMULATOR = "statevector_simulator", QuantumBackendType.SIMULATOR

    # Simulators with error models
    QUASM_SIMULATOR = "qasm_simulator", QuantumBackendType.SIMULATOR

    # Other backends with problems:
    # `Aer.get_backend('aer_simulator_stabilizer')`: results in an error.
    # `Aer.get_backend('unitary_simulator')`: results in an error.
    # `Aer.get_backend('aer_simulator_unitary')`: seems like it can't measure.
    # `Aer.get_backend('aer_simulator_superop')`: seems like it can't measure.
    # `Aer.get_backend('aer_simulator_extended_stabilizer')`: takes very long.

    @staticmethod
    def get_all_backends():
        return [b for b in QuantumBackends]

    @staticmethod
    def get_quantum_computer_backends():
        return [b for b in QuantumBackends if b.backend_type == QuantumBackendType.QUANTUM_COMPUTER]

    @staticmethod
    def get_simulator_backends():
        return [b for b in QuantumBackends if b.backend_type == QuantumBackendType.QUANTUM_COMPUTER]

    def __str__(self):
        return self.backend_name
