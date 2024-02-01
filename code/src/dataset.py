import logging
import os
from typing import List
import tensorflow as tf

from circuit_runs import CircuitRuns
from quantum_backend_type import QuantumBackendType


class CustomDataset:
    circuit_runs: List[CircuitRuns]

    # steps: List[int]: circuit steps to take into account for generating the dataset.

    def __init__(self, circuit_runs: List[CircuitRuns]):
        self.circuit_runs = circuit_runs

    def get_name(self) -> str:
        dataset_name = ""
        for circuit_run in self.circuit_runs:
            if len(dataset_name) > 0:
                dataset_name += "-"
            dataset_name += circuit_run.backend.backend_name
        # todo if I add steps, add them to the name as well
        return dataset_name

    def get_dataset_test_train_split(self, train_split=0.8) -> (tf.data.Dataset, tf.data.Dataset):
        """
        :return: (train_dataset, test_dataset)
        """
        dataset = self.get_dataset()
        num_elements = tf.data.experimental.cardinality(dataset).numpy()
        train_size = int(train_split * num_elements)
        train_dataset = dataset.take(train_size)
        test_dataset = dataset.skip(train_size)
        return train_dataset, test_dataset

    def get_dataset(self) -> tf.data.Dataset:
        dataset_name = self.get_name()

        path = "../data/datasets"
        os.makedirs(path, exist_ok=True)
        file_path = os.path.join(path, dataset_name)

        # checks if dataset already exists
        try:
            dataset = tf.data.Dataset.load(file_path)
            logging.info(f"Loaded Dataset {file_path}")
        except tf.errors.NotFoundError:
            dataset = self.__generate_dataset()
            dataset.save(file_path)
        return dataset

    def __generate_dataset(self, shuffle=True) -> tf.data.Dataset:
        logging.info("Generating dataset ...")
        data_pairs = []
        for circuit_run in self.circuit_runs:
            data_pairs.extend(self.get_memory_data(circuit_run))

        labels, features = zip(*data_pairs)

        # sanity checks
        assert labels.count(QuantumBackendType.QUANTUM_COMPUTER.label) > 10
        assert labels.count(QuantumBackendType.SIMULATOR.label) > 10
        assert len(labels) == len(features)

        features = tf.constant(features, dtype=tf.float32)
        labels = tf.constant(labels, dtype=tf.int8)
        dataset = tf.data.Dataset.from_tensor_slices((features, labels))
        if shuffle:
            dataset = dataset.shuffle(buffer_size=len(features))
        logging.info("Finished dataset generation...")
        # TODO add normalization for features?
        return dataset

    @staticmethod
    def get_memory_data(circuit_run: CircuitRuns):
        results = []
        extracted_executions = circuit_run.extract_execution_memory()
        num_rows = extracted_executions.shape[0]
        num_columns = extracted_executions.shape[1]  # equals the number of steps the circuit was generated with
        for n in range(0, num_rows, circuit_run.shots):
            for t in range(num_columns):
                results.append(
                    (circuit_run.backend.backend_type.label, extracted_executions[n:n + circuit_run.shots, t]))
        assert len(results) > 0
        logging.debug(
            f"Loaded {len(results)} results for {circuit_run.circuit.get_name()} and {circuit_run.backend.backend_name}.")
        return results

    def __str__(self) -> str:
        output = "Circuit runs in Dataset:\n"
        for c in self.circuit_runs:
            output += f"    {c}\n"
        return output

    def print_overview(self):
        logging.info("Dataset overview:")
        logging.info(self)
        dataset = self.get_dataset()
        logging.info(f"Number of elements: {len(dataset)}")
        # features, labels = tuple(zip(*dataset))
        # min_feature_value = 9999999999
        # max_feature_value = -1
        # for feature in features:
        #    minimum = min(feature)
        #    maximum = max(feature)
        #    if min_feature_value > minimum:
        #        min_feature_value = minimum
        #    if max_feature_value < maximum:
        #        max_feature_value = maximum
        # logging.info(f"Feature value range: {min_feature_value}, {max_feature_value}")
