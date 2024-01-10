import pickle
import glob
import os
import tensorflow as tf

from enum import Enum

import config
from quantum_circuits.walker import Walker


class ResultType(Enum):
    """
    The two possible data sources.
    """
    QUANTUM_COMPUTER = 0
    SIMULATED = 1


def create_mixed_dataset(circuit_name: str):
    data_pairs = []
    # Add quantum computer runs
    print("Processing quantum computer data ...")
    for quantum_computer_name in config.quantum_computer_names:
        data_pairs.extend(__get_memory_data_as_hex(circuit_name, quantum_computer_name, "quantum_computer",
                                                   ResultType.QUANTUM_COMPUTER))

    # Add simulated runs
    print("Processing simulated data ...")
    for simulator_name in config.get_all_simulator_names():
        data_pairs.extend(__get_memory_data_as_hex(circuit_name, simulator_name, "simulated", ResultType.SIMULATED))

    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.int32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save(f"../data/datasets/mixed_datasets/{circuit_name}_dataset")


# creates a dataset for a quantum_computer vs a simulator
def create_vs_dataset(quantum_computer_name: str, simulator_name: str, circuit_name: str):
    print(f"Creating a dataset for {quantum_computer_name} vs {simulator_name} ...")
    data_pairs = []
    data_pairs.extend(__get_memory_data_as_hex(circuit_name, quantum_computer_name, "quantum_computer",
                                               ResultType.QUANTUM_COMPUTER))
    data_pairs.extend(__get_memory_data_as_hex(circuit_name, simulator_name, "simulated", ResultType.SIMULATED))
    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.int32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save(f"../data/datasets/vs_datasets/{circuit_name}_{quantum_computer_name}_vs_{simulator_name}_dataset")


# source_name: (name of quantum_computer or simulator name)
def __get_memory_data_as_hex(circuit_name: str, source_name: str, source_type: str, result_type: ResultType):
    results = []
    for filename in sorted(glob.glob(
            os.path.join(f"../data/{source_type}/{circuit_name}", f"{source_name}-" + ('[0-9]' * 6) + '.p'))):
        circuit_run_file = pickle.load(open(filename, 'rb'))
        for t in range(len(circuit_run_file['results'])):
            memory_int = list(map(lambda x: int(x, 16), circuit_run_file['results'][t]['data']['memory']))
            results.append((result_type.value, memory_int))
    return results


# TODO make data more-dimensional. Use all 9 runs as separate dimensions
if __name__ == "__main__":
    for machine in config.quantum_computer_names:
        for simulator in config.get_all_simulator_names():
            create_vs_dataset(machine, simulator, Walker.get_name())
    # create_mixed_dataset(Walker.get_name())
