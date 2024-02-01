import pickle
import unittest
from unittest import TestCase

import tensorflow as tf

from circuit_runs import CircuitRuns
from dataset import CustomDataset
from quantum_backends import QuantumBackends
from quantum_circuits.walker import Walker


def get_memory_data_old_implementation(circuit_runs: CircuitRuns):
    results = []
    for filename in circuit_runs.get_circuit_run_result_filenames():
        circuit_run_file = pickle.load(open(filename, 'rb'))
        for t in range(len(circuit_run_file['results'])):
            memory_int = list(map(lambda x: int(x, 16), circuit_run_file['results'][t]['data']['memory']))
            results.append((circuit_runs.backend.backend_type.label, memory_int))
    assert len(results) > 0
    return results


class TestDataset(unittest.TestCase):

    def test_get_memory_data_compared_to_old_implementation(self):
        circuit_runs = CircuitRuns(Walker(), QuantumBackends.AER_SIMULATOR)
        actual = CustomDataset.get_memory_data(circuit_runs)
        expected = get_memory_data_old_implementation(circuit_runs)

        actual_labels, actual_features = zip(*actual)
        expected_labels, expected_features = zip(*expected)

        self.assertEqual(expected_labels, actual_labels)
        for i in range(len(expected_features)):
            self.assertListEqual(expected_features[i], actual_features[i].tolist(), msg=f"Feature {i} does not match.")


if __name__ == '__main__':
    unittest.main()
