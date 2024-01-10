import pickle
import glob
import os
import tensorflow as tf

from enum import Enum
from quantum_circuits.walker import Walker

quantum_computer_machines = ['ibmq_athens', 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A',
                             'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D',
                             'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G',
                             'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J',
                             'ibmq_santiago', 'ibmq_casablanca', 'ibmq_casablanca-bis', 'ibmq_5_yorktown',
                             'ibmq_bogota', 'ibmq_lima', 'ibmq_quito']

simulator_names = ["aersimulator_density_matrix", "aersimulator_matrix_product_state", "aersimulator_statevector",
                   "qasmsimulator_default", "aersimulator_default", "statevectorsimulator_default"]


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
    for machine in quantum_computer_machines:
        for filename in sorted(glob.glob(
                os.path.join(f"../data/quantum_computer/{circuit_name}", f"{machine}-" + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append((ResultType.QUANTUM_COMPUTER.value, memory_int))

    # Add simulated runs
    print("Processing simulated data ...")
    for name in simulator_names:
        for filename in sorted(
                glob.glob(os.path.join(f"../data/simulated/{circuit_name}", f"{name}-" + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append((ResultType.SIMULATED.value, memory_int))

    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.int32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save(f"../data/datasets/mixed_datasets/{circuit_name}_dataset")


# creates a dataset for a quantum_computer vs a simulator
def create_vs_dataset(quantum_computer_machine: str, simulator_name: str, circuit_name: str):
    print(f"Creating a dataset for {quantum_computer_machine} vs {simulator_name} ...")
    data_pairs = []
    data_pairs.extend(__get_memory_data_as_hex(circuit_name, quantum_computer_machine, "quantum_computer",
                                           ResultType.QUANTUM_COMPUTER))
    data_pairs.extend(__get_memory_data_as_hex(circuit_name, simulator_name, "simulated", ResultType.SIMULATED))
    labels, features = zip(*data_pairs)
    features = tf.constant(features,
                           dtype=tf.int32)  # TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save(f"../data/datasets/vs_datasets/{circuit_name}_{quantum_computer_machine}_vs_{simulator_name}_dataset")


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
    for machine in quantum_computer_machines:
        for simulator in simulator_names:
            create_vs_dataset(machine, simulator, Walker.get_name())
    #create_mixed_dataset(Walker.get_name())
