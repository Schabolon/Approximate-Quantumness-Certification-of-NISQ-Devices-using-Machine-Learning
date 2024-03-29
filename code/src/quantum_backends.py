from dataclasses import dataclass
from enum import Enum
from typing import Optional

import qiskit
from qiskit_ibm_runtime.fake_provider import FakeVigoV2, FakeAthensV2, FakeSantiagoV2, FakeLimaV2, FakeBelemV2, \
    FakeCairoV2

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
    IBMQ_5_YORKTOWN = "ibmq_5_yorktown", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_BOGOTA = "ibmq_bogota", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_QUITO = "ibmq_quito", QuantumBackendType.QUANTUM_COMPUTER, None
    IBMQ_LIMA = "ibmq_lima", QuantumBackendType.QUANTUM_COMPUTER, None

    # Simulators
    # Simulators *without* noise models
    AER_SIMULATOR = "aer_simulator", QuantumBackendType.SIMULATOR, None
    # Use only one simulator without noise (with noise is much more interesting)

    # Simulators *with* noise models (use FakeProvider V2 Backends)
    # see https://docs.quantum.ibm.com/api/qiskit/qiskit.providers.fake_provider.FakeProviderForBackendV2
    FAKE_VIGO_V2 = "fake_vigo_v2", QuantumBackendType.SIMULATOR, FakeVigoV2()
    FAKE_ATHENS_V2 = "fake_athens_v2", QuantumBackendType.SIMULATOR, FakeAthensV2()
    FAKE_SANTIAGO_V2 = "fake_santiago_v2", QuantumBackendType.SIMULATOR, FakeSantiagoV2()
    FAKE_LIMA_V2 = "fake_lima_v2", QuantumBackendType.SIMULATOR, FakeLimaV2()
    FAKE_BELEM_V2 = "fake_belem_v2", QuantumBackendType.SIMULATOR, FakeBelemV2()
    FAKE_CAIRO_V2 = "fake_cairo_v2", QuantumBackendType.SIMULATOR, FakeCairoV2()

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
