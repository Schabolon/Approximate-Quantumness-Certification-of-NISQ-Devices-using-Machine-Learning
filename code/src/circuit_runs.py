import glob
import logging
import os
import pickle
from typing import List

import numpy as np

from collections import Counter
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class CircuitRuns:
    circuit: ImplementedQuantumCircuit
    backend: QuantumBackends
    shots: int

    #todo run simulator if simulator + no data found
    def __init__(self, circuit: ImplementedQuantumCircuit, backend: QuantumBackends, shots=8000):
        self.circuit = circuit
        self.backend = backend
        self.shots = shots

    def get_circuit_run_result_filenames(self) -> List[str]:
        file_pattern = (f"../data/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}"
                        f"/{self.backend.backend_name}-{('[0-9]' * 6)}.p")
        filenames = sorted(glob.glob(file_pattern))
        if len(filenames) == 0:
            logging.warning(f"Could not find any files for pattern {file_pattern}")
        return filenames

    def get_extracted_memory_filename(self) -> str:
        return (f"../data/extracted_executions/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}/executions-memory-{self.backend.backend_name}.csv")

    def extract_execution_memory(self) -> np.ndarray:
        """
        Extracted memory as table looks like this (for example):
                         | Circuit Step 1 | Circuit Step 2 | ... | Circuit Step n |
        | -------------- | -------------- | -------------- | --- | -------------- |
        | 1. Shot result | 0x0            | 0x1            | ... | 0x0            |
        | 2. Shot result | 0x3            | 0x3            | ... | 0x3            |
        | ...            | ...            | ...            | ... | ...            |

        All shots for the 1. circuit step are stored in the first column.
        For 8000 shots with 250 files in `circuit_execution_files` this results in 2.000.000 rows.

        :return: the extracted memory as numpy array
        """
        executions_memory = []

        output_filename = self.get_extracted_memory_filename()
        if os.path.exists(output_filename):
            logging.info(
                f"Executions from {self.backend.backend_name} on circuit {self.circuit.get_name()} have already been extracted.")
            logging.debug("Loading data from already existing file.")
            extracted_executions = np.loadtxt(output_filename, delimiter=',')
            return extracted_executions

        for filename in self.get_circuit_run_result_filenames():
            logging.debug(f"Extracting execution memory from file {filename}")
            if not os.path.exists(filename):
                logging.warning(f"File {filename} could not be found. Skipping ...")
                continue
            circuit_results = pickle.load(open(filename, 'rb'))
            shots = len(circuit_results['results'][0]['data']['memory'])
            for n in range(shots):
                current_execution = []
                for t in range(len(circuit_results['results'])):
                    execution = int(circuit_results['results'][t]['data']['memory'][n], 0)
                    current_execution.append(execution)
                executions_memory.append(current_execution)

        if len(executions_memory) == 0:
            raise Exception(f"Could not extract any execution memory for {self.backend.backend_name} on circuit {self.circuit.get_name()}!")

        executions_memory = np.array(executions_memory)
        logging.info(f"Saving executions in {output_filename} with shape {executions_memory.shape}")
        os.makedirs(os.path.dirname(output_filename), exist_ok=True)
        np.savetxt(output_filename, executions_memory, delimiter=',')
        return executions_memory

    # todo make possible to use multiple window sizes (combine results)
    def calculate_probabilities(self, window_size=1000):
        executions = self.extract_execution_memory()
        if executions.shape[0] % window_size > 0:
            raise Exception("Not divisible")

        path = f"../data/probabilities/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}"
        file_path = os.path.join(path, f"probabilities-{window_size}-{self.backend.backend_name}.npy")

        if os.path.exists(file_path):
            logging.info(f"Probabilities for {self.backend.backend_name} on circuit {self.circuit.get_name()} have already been calculated.")
            # TODO auch laden + returnen?
            logging.debug("Skipping ...")
            return

        logging.debug(f"Calculate probabilities with window_size={window_size}")
        num_rows = executions.shape[0]
        num_columns = executions.shape[1]
        probabilities = np.zeros((int(num_rows / window_size), num_columns, len(np.unique(executions))),
                                 dtype='float32')
        for n in range(num_rows):
            i = int(n / window_size)
            for t in range(num_columns):
                probabilities[i, t, executions[n, t]] += 1

        probabilities = probabilities / window_size
        os.makedirs(path, exist_ok=True)
        logging.info(f"Saving probabilities in {file_path} with shape {probabilities.shape}")
        np.save(file_path, probabilities)

    def get_histogram_counts(self, step: int):
        counts = {}
        for filename in self.get_circuit_run_result_filenames():
            content = pickle.load(open(filename, 'rb'))
            counts = dict(
                Counter(counts) + Counter(content["results"][step]["data"]["counts"]))
        return counts

    def __str__(self) -> str:
        return f"Circuit: {self.circuit.get_name()}; Backend: {self.backend.backend_name}; Shots: {self.shots}"
