from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.ramsey import Ramsey
from quantum_circuits.walker import Walker
from quantum_circuits.walker_simple import WalkerSimple
from quantum_circuits.walker_single_measures import WalkerSingleMeasures

circuits: list[ImplementedQuantumCircuit] = [Walker(), WalkerSimple(), WalkerSingleMeasures(), Ramsey()]
"""
List quantum circuits for which quantum-computer data exists.
"""
