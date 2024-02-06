import logging
from enum import Enum
from typing import List

import numpy as np

from circuit_run_data import CircuitRunData
from quantum_backend_type import QuantumBackendType


class NormalizationTechnique(Enum):
    NONE = 0
    MIN_MAX = 1


class CustomDataset:
    circuit_run_data: List[CircuitRunData]
    steps: List[int]
    labels: np.array
    features: np.array

    def __init__(self, circuit_run_data: List[CircuitRunData], steps: List[int], window_size=1, normalization_technique=NormalizationTechnique.NONE):
        """
        :param circuit_run_data:
        :param window_size: uses probability data for the dataset if window_size > 1. ("regular" dataset otherwise).
        """
        self.circuit_run_data = circuit_run_data
        self.labels = np.array([])
        self.features = np.array([])
        self.steps = steps
        self.__load_probability_data(window_size)
        self.__normalize_features(normalization_technique)
        self.__shuffle()

        # sanity checks
        assert np.count_nonzero(self.labels == QuantumBackendType.QUANTUM_COMPUTER.label) > 1
        assert np.count_nonzero(self.labels == QuantumBackendType.SIMULATOR.label) > 1
        assert len(self.labels) == len(self.features)

    def get_test_train_split(self, train_split=0.8):
        """
        :param train_split: percentage of features/labels used for training
        :return: (train_features, train_labels, test_features, test_labels)
        """
        assert len(self.labels) == len(self.features)

        split_ratios_features = np.array([train_split, 1 - train_split])
        split_indices_features = (self.features.shape[0] * np.cumsum(split_ratios_features)).astype(int)
        split_features = np.split(self.features, split_indices_features[:-1])

        split_ratios_labels = np.array([train_split, 1 - train_split])
        split_indices_labels = (self.labels.size * np.cumsum(split_ratios_labels)).astype(int)
        split_labels = np.split(self.labels, split_indices_labels[:-1])

        return split_features[0], split_labels[0], split_features[1], split_labels[1]

    def __normalize_features(self, normalization_technique: NormalizationTechnique):
        match normalization_technique:
            case NormalizationTechnique.MIN_MAX:
                feature_min = np.min(self.features)
                feature_max = np.max(self.features)
                for i, feature in enumerate(self.features):
                    self.features[i] = (feature - feature_min) / (feature_max - feature_min)

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
