import logging
import random
from typing import List

from circuit_runs import CircuitRuns
from quantum_backend_type import QuantumBackendType


class CustomDataset:
    circuit_runs: List[CircuitRuns]

    # steps: List[int]: circuit steps to take into account for generating the dataset.

    labels: List[int]
    features: List[List[int]]

    def __init__(self, circuit_runs: List[CircuitRuns], window_size=0):
        """
        :param circuit_runs:
        :param window_size: uses probability data for the dataset if window_size > 0. (regular dataset otherwise).
        """
        self.circuit_runs = circuit_runs
        self.labels = []
        self.features = []
        if window_size > 0:
            self.__load_probability_data(window_size)
        else:
            self.__load_data()
        # TODO add normalization for features?
        self.__shuffle()

        # sanity checks
        assert self.labels.count(QuantumBackendType.QUANTUM_COMPUTER.label) > 10
        assert self.labels.count(QuantumBackendType.SIMULATOR.label) > 10
        assert len(self.labels) == len(self.features)

    def get_test_train_split(self, train_split=0.8):
        """
        :param train_split: percentage of features/labels used for training
        :return: (train_features, train_labels, test_features, test_labels)
        """
        assert len(self.labels) == len(self.features)
        num_train_elements = int(len(self.labels) * train_split)
        return (self.features[:num_train_elements], self.labels[:num_train_elements],
                self.features[num_train_elements:], self.labels[num_train_elements:])

    def __load_data(self):
        logging.info("Loading dataset ...")
        for circuit_run in self.circuit_runs:
            # load features
            extracted_executions = circuit_run.get_execution_memory()
            num_rows = extracted_executions.shape[0]
            num_columns = extracted_executions.shape[1]  # equals the number of steps the circuit was generated with
            for n in range(0, num_rows, circuit_run.shots):
                for t in range(num_columns):
                    self.features.append(extracted_executions[n:n + circuit_run.shots, t].tolist())
            # add labels
            num_labels = int(num_rows / circuit_run.shots) * num_columns
            self.labels.extend([circuit_run.backend.backend_type.label] * num_labels)
            assert len(self.labels) == len(self.features)
        logging.info("Finished loading dataset.")

    def __load_probability_data(self, window_size: int):
        logging.info("Loading probability dataset ...")
        for circuit_run in self.circuit_runs:
            # load features
            if circuit_run.shots % window_size > 0:
                raise Exception("Not divisible")
            num_of_elements_per_feature = int(circuit_run.shots / window_size)
            probabilities = circuit_run.get_probabilities(window_size)
            num_rows = probabilities.shape[0]
            num_columns = probabilities.shape[1]  # equals the number of steps the circuit was generated with
            num_different_results = probabilities.shape[2]
            for n in range(0, num_rows, num_of_elements_per_feature):
                for t in range(num_columns):
                    self.features.append(
                        CustomDataset.__flatten(
                            probabilities[n:n + num_of_elements_per_feature, t, :num_different_results].tolist()))
            # add labels
            num_labels = int(num_rows / num_of_elements_per_feature) * num_columns
            self.labels.extend([circuit_run.backend.backend_type.label] * num_labels)
            assert len(self.labels) == len(self.features)
        logging.info("Finished loading probability dataset.")

    def __shuffle(self):
        combined = list(zip(self.features, self.labels))
        random.shuffle(combined)
        self.features, self.labels = zip(*combined)

    @staticmethod
    def __flatten(two_dimensional_list):
        return [x for xs in two_dimensional_list for x in xs]

    def __str__(self) -> str:
        output = "Circuit runs in Dataset:\n"
        for c in self.circuit_runs:
            output += f"    {c}\n"
        return output
