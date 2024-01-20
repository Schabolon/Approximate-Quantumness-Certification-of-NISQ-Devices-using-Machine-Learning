"""
Ideal usage: data.qc.aer_simulator.get_data_filenames()
"""
import glob
import os

from data_sources import simulators
from data_sources import quantum_computers
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker
from pathlib import Path


def get_source_type_name_from_data_source_name(data_source_name: str) -> str:
    if data_source_name in simulators.get_all_simulator_names():
        return "simulator"
    elif data_source_name in quantum_computers.quantum_computer_names:
        return "quantum_computer"


def get_data_filenames(circuit: ImplementedQuantumCircuit, data_source_name: str) -> list[str]:
    # Get the absolute path of the script
    script_path = os.path.abspath(__file__)

    # Get the directory of the script
    script_dir = os.path.dirname(script_path)

    # Change the working directory to the script's directory
    os.chdir(script_dir)

    source_type_name = get_source_type_name_from_data_source_name(data_source_name)
    absolute_path_pattern = (f"../../data/{source_type_name}/{circuit.get_name()}"
                             f"/{data_source_name}-{('[0-9]' * 6)}.p")
    filenames = sorted(glob.glob(absolute_path_pattern))
    if len(filenames) == 0:
        print(f"WARNING: Could not find any files for pattern {absolute_path_pattern}")
    return filenames


if __name__ == "__main__":
    files = get_data_filenames(Walker(), "ibmq_athens")
    print(files)