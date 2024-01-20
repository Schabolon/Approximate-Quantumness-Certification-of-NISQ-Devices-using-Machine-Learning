import pickle
import tensorflow as tf

from enum import Enum

import data_sources.data
from data_sources import quantum_computers, simulators
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit
from quantum_circuits.walker import Walker


class LabelTypes(Enum):
    """
    The two possible data sources.
    """
    QUANTUM_COMPUTER = 0
    SIMULATED = 1


def create_mixed_dataset(circuit: ImplementedQuantumCircuit):
    data_pairs = []
    # Add quantum computer runs
    print("Processing quantum computer data ...")
    for quantum_computer_name in quantum_computers.quantum_computer_names:
        data_pairs.extend(__get_memory_data_as_int(circuit, quantum_computer_name, LabelTypes.QUANTUM_COMPUTER))

    # Add simulated runs
    print("Processing simulated data ...")
    for simulator_name in simulators.get_all_simulator_names():
        data_pairs.extend(__get_memory_data_as_int(circuit, simulator_name, LabelTypes.SIMULATED))

    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.int32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save(f"../data/datasets/mixed_datasets/{circuit.get_name()}_dataset")


# creates a dataset for a quantum_computer vs a simulator
def create_vs_dataset(quantum_computer_name: str, simulator_name: str, circuit: ImplementedQuantumCircuit):
    print(f"Creating a dataset for {quantum_computer_name} vs {simulator_name} ...")
    data_pairs = []
    data_pairs.extend(__get_memory_data_as_int(circuit, quantum_computer_name, LabelTypes.QUANTUM_COMPUTER))
    data_pairs.extend(__get_memory_data_as_int(circuit, simulator_name, LabelTypes.SIMULATED))
    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.float32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    path = f"../../data/datasets/vs_datasets/{circuit.get_name()}_{quantum_computer_name}_vs_{simulator_name}_dataset"
    dataset.save(path)
    print(f"Saved dataset to {path}.")

    for element in dataset.take(5):
        print(element)


# source_name: (name of quantum_computer or simulator name)
def __get_memory_data_as_int(circuit: ImplementedQuantumCircuit, source_name: str, result_type: LabelTypes):
    results = []
    for filename in data_sources.data.get_data_filenames(circuit, source_name):
        circuit_run_file = pickle.load(open(filename, 'rb'))
        for t in range(len(circuit_run_file['results'])):
            #memory_int = list(map(lambda x: int(x, 16), circuit_run_file['results'][t]['data']['memory']))
            memory_float = list(map(lambda x: (int(x, 16) / 3), circuit_run_file['results'][t]['data']['memory']))
            results.append((result_type.value, memory_float))
    assert len(results) > 0
    print(f"Loaded {len(results)} results for {circuit.get_name()} and {source_name}.")
    return results


# TODO make data more-dimensional. Use all 9 runs as separate dimensions
if __name__ == "__main__":
    # for machine in config.quantum_computer_names_no_split:
    #    for machine2 in config.quantum_computer_names_no_split:
    #        create_vs_dataset(machine, machine2, Walker.get_name())
    # create_mixed_dataset(Walker.get_name())
    create_vs_dataset(quantum_computers.quantum_computer_names[0], quantum_computers.quantum_computer_names[1],
                      Walker())
