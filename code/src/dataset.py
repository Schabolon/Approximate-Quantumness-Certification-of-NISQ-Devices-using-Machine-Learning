import logging
from typing import List

import numpy as np
import numpy.typing as npt

from circuit_run_data import CircuitRunData


class CustomDataset:
    circuit_run_data: List[CircuitRunData]
    steps: List[int]
    labels: npt.NDArray[np.int8]
    features: npt.NDArray[np.float32]

    def __init__(self, circuit_run_data: List[CircuitRunData], steps: List[int], window_size=1000):
        """
        :param circuit_run_data:
        :param window_size: uses probability data for the dataset if window_size > 1. (otherwise the dataset encodes the qubit-results as "one-hot").
        """
        self.circuit_run_data = circuit_run_data
        self.labels = np.array([], dtype=np.int8)
        self.features = np.array([])
        self.steps = steps
        self.__load_probability_data(window_size)
        self.__shuffle()

        # sanity checks
        # assert np.count_nonzero(self.labels == QuantumBackendType.QUANTUM_COMPUTER.label) > 1
        # assert np.count_nonzero(self.labels == QuantumBackendType.SIMULATOR.label) > 1
        assert len(self.labels) == len(self.features)

    def get_test_train_split(self, train_split=0.8):
        """
        :param train_split: percentage of features/labels which can be used for training.
                            the test features/labels are (1-train_split) percent.
        :return: (train_features, train_labels, test_features, test_labels)
        """
        train_f, train_l, _, _, test_f, test_l = self.get_test_train_validation_split(train_split=train_split,
                                                                                      test_split=1 - train_split,
                                                                                      validation_split=0)
        return train_f, train_l, test_f, test_l

    def get_test_train_validation_split(self, train_split=0.6, validation_split=0.2, test_split=0.2):
        """
        :param train_split: percentage of features/labels which can be used for training.
        :param validation_split: percentage of features/labels which can be used for validation.
        :param test_split: percentage of features/labels which can be used for validation.
        :return: (train_features, train_labels, validation_features, validation_labels, test_features, test_labels)
        """
        assert train_split + validation_split + test_split == 1
        assert len(self.labels) == len(self.features)

        split_ratios = np.array([train_split, validation_split, test_split])

        split_indices_features = (self.features.shape[0] * np.cumsum(split_ratios)).astype(int)
        split_features = np.split(self.features, split_indices_features[:-1])

        split_indices_labels = (self.labels.size * np.cumsum(split_ratios)).astype(int)
        split_labels = np.split(self.labels, split_indices_labels[:-1])

        return split_features[0], split_labels[0], split_features[1], split_labels[1], split_features[2], split_labels[
            2]

    def __load_probability_data(self, window_size: int):
        logging.info("Loading probability dataset ...")
        for circuit_run in self.circuit_run_data:
            if circuit_run.shots % window_size > 0:
                raise Exception("Not divisible")
            # load features
            probabilities = circuit_run.get_probabilities(window_size)
            # take only data for step
            logging.debug(f"Taking only measurement steps {self.steps}")
            probabilities = probabilities[:, self.steps, :]

            new_feature_probabilities = probabilities.reshape(probabilities.shape[0], -1)
            if len(self.features) > 0:
                self.features = np.concatenate((self.features, new_feature_probabilities))
            else:
                self.features = new_feature_probabilities

            # add labels
            num_labels = len(new_feature_probabilities)
            self.labels = np.concatenate((self.labels, np.array([circuit_run.backend.backend_type.label] * num_labels)))
            assert len(self.labels) == len(self.features)
        logging.info("Finished loading probability dataset.")

    def __shuffle(self):
        assert len(self.features) == len(self.labels)
        shuffle_index = np.random.permutation(len(self.features))
        self.features = self.features[shuffle_index]
        self.labels = self.labels[shuffle_index]

    def __str__(self) -> str:
        output = "Circuit runs in Dataset:\n"
        for c in self.circuit_run_data:
            output += f"    {c}\n"
        return output
