import numpy as np
from qiskit.visualization import plot_distribution

from circuit_run_data import CircuitRunData
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker


def plot_histogram_simulator_vs_qc(circuit: ImplementedQuantumCircuit, simulator: QuantumBackends, qc: QuantumBackends,
                                   step_to_compare):
    cr_simulator = CircuitRunData(circuit, simulator)
    cr_qc = CircuitRunData(circuit, qc)
    hist = plot_distribution([
        cr_simulator.get_histogram_counts(step_to_compare),
        cr_qc.get_histogram_counts(step_to_compare)],
        title="Simulator vs Quantum Computer",
        legend=[simulator.backend_name, qc.backend_name], figsize=(17, 7))
    hist.savefig(
        f'../../data/visualization/histogram/hist_circuit_{circuit.get_name()}_{qc.backend_name}_vs_{simulator.backend_name}_step_{step_to_compare}.svg')


def __generate_color_gradient(base_color, num_colors, offset=0.4):
    colors = []
    for i in np.linspace(offset, 1, num_colors):
        colors.append((base_color[0]*i, base_color[1]*i, base_color[2]*i))
    return colors


def plot_overview_histogram(circuit: ImplementedQuantumCircuit, step_to_compare: int):
    simulator_base_color = (1, 0, 0)  # Red
    quantum_computer_base_color = (0, 1, 0)  # Green
    simulator_colors = __generate_color_gradient(simulator_base_color, len(QuantumBackends.get_simulator_backends()))
    quantum_computer_colors = __generate_color_gradient(quantum_computer_base_color, len(QuantumBackends.get_quantum_computer_backends()))
    colors = simulator_colors + quantum_computer_colors

    data = []
    legend_names = []
    for simulator in QuantumBackends.get_simulator_backends():
        cr_simulator = CircuitRunData(circuit, simulator)
        data.append(cr_simulator.get_histogram_counts(step_to_compare))
        legend_names.append(simulator.backend_name)

    for i, qc in enumerate(QuantumBackends.get_quantum_computer_backends()):
        cr_qc = CircuitRunData(circuit, qc)
        data.append(cr_qc.get_histogram_counts(step_to_compare))
        legend_names.append(qc.backend_name)

    hist = plot_distribution(data, title="Simulators vs Quantum Computers", legend=legend_names, color=colors, figsize=(37, 7))
    hist.savefig(
        f'../data/visualization/hist_{circuit.get_name()}_simulators_vs_quantum_computers_step_{step_to_compare}.svg')


if __name__ == "__main__":
    plot_overview_histogram(Walker(), 1)
    #for i in range(8):
    #    plot_histogram_simulator_vs_qc(Walker(), QuantumBackends.AER_SIMULATOR, QuantumBackends.IBMQ_QUITO, i)
