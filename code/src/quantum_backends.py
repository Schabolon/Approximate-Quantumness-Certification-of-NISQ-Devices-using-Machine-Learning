from enum import Enum

from dataclasses import dataclass
from typing import Optional

import qiskit

from qiskit_ibm_runtime.fake_provider import FakeVigoV2, FakeAthensV2, FakeSantiagoV2, FakeLimaV2

from quantum_backend_type import QuantumBackendType


@dataclass
class _QuantumBackend:
    backend_name: str
    backend_type: QuantumBackendType
    noisy_backend: Optional[qiskit.providers.backend.BackendV2]


class QuantumBackends(_QuantumBackend, Enum):
    # Quantum Computers
    IBMQ_ATHENS = "ibmq_athens", QuantumBackendType.QUANTUM_COMPUTER, None
    IMBQ_SANTIAGO = "ibmq_santiago", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_CASABLANCA = "ibmq_casablanca", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_CASABLANCA_BIS = "ibmq_casablanca-bis", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_5_YORKTOWN = "ibmq_5_yorktown", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_BOGOTA = "ibmq_bogota", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_QUITO = "ibmq_quito", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_LIMA = "ibmq_lima", QuantumBackendType.QUANTUM_COMPUTER, None
    # ROME is only used for circuit "Ramsey"
    # IBMQ_ROME = "ibmq_rome", QuantumBackendType.QUANTUM_COMPUTER

    # Quantum Computer split data:
    # 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A',
    # 'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D',
    # 'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G',
    # 'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J',

    # Simulators
    # Simulators *without* noise models
    AER_SIMULATOR = "aer_simulator", QuantumBackendType.SIMULATOR, None
    AER_SIMULATOR_DENSITY_MATRIX = "aer_simulator_density_matrix", QuantumBackendType.SIMULATOR, None
    AER_SIMULATOR_STATEVECTOR = "aer_simulator_statevector", QuantumBackendType.SIMULATOR, None
    AER_SIMULATOR_MATRIX_PRODUCT_STATE = "aer_simulator_matrix_product_state", QuantumBackendType.SIMULATOR, None
    STATEVECTOR_SIMULATOR = "statevector_simulator", QuantumBackendType.SIMULATOR, None
    QUASM_SIMULATOR = "qasm_simulator", QuantumBackendType.SIMULATOR, None

    # Simulators *with* noise models (use FakeProvider V2 Backends)
    # see https://docs.quantum.ibm.com/api/qiskit/qiskit.providers.fake_provider.FakeProviderForBackendV2
    FAKE_VIGO_V2 = "fake_vigo_v2", QuantumBackendType.SIMULATOR, FakeVigoV2()
    FAKE_ATHENS_V2 = "fake_athens_v2", QuantumBackendType.SIMULATOR, FakeAthensV2()
    FAKE_SANTIAGO_V2 = "fake_santiago_v2", QuantumBackendType.SIMULATOR, FakeSantiagoV2()
    FAKE_LIMA_V2 = "fake_lima_v2", QuantumBackendType.SIMULATOR, FakeLimaV2()

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
        return [b for b in QuantumBackends if b.backend_type == QuantumBackendType.SIMULATOR]

    @staticmethod
    def get_simulator_backends_with_noise_model():
        return [b for b in QuantumBackends if
                b.backend_type == QuantumBackendType.SIMULATOR and b.noisy_backend is not None]

    def __str__(self):
        return self.backend_name
