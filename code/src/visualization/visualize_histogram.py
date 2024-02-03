from qiskit.visualization import plot_distribution

from circuit_runs import CircuitRuns
from quantum_backends import QuantumBackends
from quantum_circuits.walker import Walker


def plot_probabilities(circuit, simulator, qc, step_to_compare):
    cr_simulator = CircuitRuns(circuit, simulator)
    cr_qc = CircuitRuns(circuit, qc)
    hist = plot_distribution([
        cr_simulator.get_histogram_counts(step_to_compare),
        cr_qc.get_histogram_counts(step_to_compare)],
        title="Simulator vs Quantum Computer",
        legend=[simulator, qc], figsize=(13, 7))
    hist.savefig(f'../../data/visualization/histogram/hist_{qc}_vs_{simulator}_step_{step_to_compare}.svg')


if __name__ == "__main__":
    for i in range(8):
        plot_probabilities(Walker(), QuantumBackends.AER_SIMULATOR, QuantumBackends.IBMQ_QUITO, i)
