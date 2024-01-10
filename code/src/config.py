from qiskit_aer import Aer, AerProvider, AerSimulator

from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.ramsey import Ramsey
from quantum_circuits.walker import Walker
from quantum_circuits.walker_simple import WalkerSimple
from quantum_circuits.walker_single_measures import WalkerSingleMeasures

circuits: list[ImplementedQuantumCircuit] = [Walker(), WalkerSimple(), WalkerSingleMeasures(), Ramsey()]
"""
List quantum circuits for which quantum-computer data exists.
"""

# `Aer.get_backend('aer_simulator_stabilizer')` results in an error.
# `Aer.get_backend('aer_simulator_unitary')`: seems like it can't measure.
# `Aer.get_backend('aer_simulator_superop')`: seems like it can't measure.
# `Aer.get_backend('unitary_simulator')`: results in " contains invalid instructions {"instructions": {save_unitary}} for "statevector" method."
# takes very long:(Aer.get_backend('aer_simulator_extended_stabilizer'),
simulators: list[AerSimulator] = [Aer.get_backend('aer_simulator'),
                                  Aer.get_backend('aer_simulator_density_matrix'),
                                  Aer.get_backend('aer_simulator_statevector'),
                                  Aer.get_backend('aer_simulator_matrix_product_state'),
                                  Aer.get_backend('qasm_simulator'),
                                  Aer.get_backend('statevector_simulator')]

quantum_computer_names = ['ibmq_athens', 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A',
                          'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D',
                          'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G',
                          'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J',
                          'ibmq_santiago', 'ibmq_casablanca', 'ibmq_casablanca-bis', 'ibmq_5_yorktown',
                          'ibmq_bogota', 'ibmq_lima', 'ibmq_quito']


def get_simulator_name(simulator: AerSimulator) -> str:
    return simulator.configuration().backend_name


def get_all_simulator_names() -> list[str]:
    names = []
    for simulator in simulators:
        names.append(get_simulator_name(simulator))
    return names
