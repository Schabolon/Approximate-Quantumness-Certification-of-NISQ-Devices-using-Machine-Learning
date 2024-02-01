import glob
import os
import pickle
from collections import Counter

from qiskit.visualization import plot_distribution

from quantum_circuits.walker import Walker


def plot_probabilities(circuit, simulator_name, qc_name, step_to_compare):
    simulator_counts = {}
    for filename in data_sources.data.get_data_filenames(circuit, simulator_name):
        content = pickle.load(open(filename, 'rb'))
        simulator_counts = dict(
            Counter(simulator_counts) + Counter(content["results"][step_to_compare]["data"]["counts"]))

    qc_counts = {}
    for filename in data_sources.data.get_data_filenames(circuit, qc_name):
        content = pickle.load(open(filename, 'rb'))
        qc_counts = dict(Counter(qc_counts) + Counter(content["results"][step_to_compare]["data"]["counts"]))

    hist = plot_distribution([simulator_counts, qc_counts], title="Simulator vs Quantum Computer",
                             legend=[simulator_name, qc_name], figsize=(13, 7))
    hist.savefig(f'../../data/visualization/hist_{qc_name}_vs_{simulator_name}_step_{step_to_compare}.svg')


if __name__ == "__main__":
    for i in range(8):
        plot_probabilities(Walker(),
                           data_sources.data.simulators.get_all_simulator_names()[0],
                           data_sources.data.quantum_computers.quantum_computer_names[0],
                           i)
    exit(0)
