import glob
import logging
import os
import pickle
from typing import List, Optional

import numpy as np

from collections import Counter

import simulator
from quantum_backend_type import QuantumBackendType
from quantum_backends import QuantumBackends
from quantum_circuits.implemented_quantum_circuit import ImplementedQuantumCircuit


class CircuitRunData:
    circuit: ImplementedQuantumCircuit
    backend: QuantumBackends

    def __init__(self, circuit: ImplementedQuantumCircuit, backend: QuantumBackends):
        self.circuit = circuit
        self.backend = backend
        if not self.__execution_data_exists():
            logging.debug(f"Could not find run data for circuit {circuit.get_name()} and backend {backend.backend_name}.")
            if self.backend.backend_type == QuantumBackendType.QUANTUM_COMPUTER:
                raise Exception("No quantum computer data found!")
            elif self.backend.backend_type == QuantumBackendType.SIMULATOR:
                simulator.save_quantum_circuit_simulation(circuit, backend)
        self.shots = self.__extract_shots()

    def get_circuit_run_result_filenames(self) -> List[str]:
        file_pattern = (f"../data/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}"
                        f"/{self.backend.backend_name}-{('[0-9]' * 6)}.p")
        filenames = sorted(glob.glob(file_pattern))
        if len(filenames) == 0:
            logging.warning(f"Could not find any files for pattern {file_pattern}")
        return filenames

    def get_extracted_memory_filename(self) -> str:
        return f"../data/extracted_executions/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}/executions-memory-{self.backend.backend_name}.csv"

    def get_execution_memory(self) -> np.ndarray:
        """
        Extracted memory as table looks like this (for example):
        | Shot           | Circuit Step 1 | Circuit Step 2 | ... | Circuit Step n |
        | -------------- | -------------- | -------------- | --- | -------------- |
        | 1              | 0x0            | 0x1            | ... | 0x0            |
        | 2              | 0x3            | 0x3            | ... | 0x3            |
        | ...            | ...            | ...            | ... | ...            |
        | 8000           | 0x1            | 0x0            | ... | 0x2            |

        All shots for the 1. circuit step are stored in the first column.
        For 8000 shots with 250 files in `circuit_execution_files` this results in 2.000.000 rows.

        :return: the extracted memory as numpy array
        """
        executions_memory = []

        # load execution memory if it has already been extracted before.
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
            for n in range(self.shots):
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
        np.savetxt(output_filename, executions_memory, fmt='%s', delimiter=',')
        return executions_memory

    def get_probabilities(self, window_size: int) -> np.ndarray:
        path = f"../data/probabilities/{self.backend.backend_type.folder_name}/{self.circuit.get_name()}"
        os.makedirs(path, exist_ok=True)
        output_filename = os.path.join(path, f"probabilities-{window_size}-{self.backend.backend_name}.npy")

        if os.path.exists(output_filename):
            logging.info(f"Probabilities for {self.backend.backend_name} on circuit {self.circuit.get_name()} have already been calculated.")
            logging.debug("Loading data from already existing file.")
            return np.load(output_filename)

        executions = self.get_execution_memory()
        if executions.shape[0] % window_size > 0:
            raise Exception("Not divisible")

        logging.debug(f"Calculate probabilities with window_size={window_size}")
        num_rows = executions.shape[0]
        num_columns = executions.shape[1]
        probabilities = np.zeros((int(num_rows / window_size), num_columns, len(np.unique(executions))),
                                 dtype='float32')
        for current_shot_num in range(num_rows):
            i = int(current_shot_num / window_size)
            for current_circuit_step in range(num_columns):
                probabilities[i, current_circuit_step, int(executions[current_shot_num, current_circuit_step])] += 1

        probabilities = probabilities / window_size
        os.makedirs(path, exist_ok=True)
        logging.info(f"Saving probabilities in {output_filename} with shape {probabilities.shape}")
        np.save(output_filename, probabilities)
        return probabilities

    def get_histogram_counts(self, step: int):
        CircuitRunData.__change_work_dir_to_current()
        counts = {}
        for filename in self.get_circuit_run_result_filenames():
            content = pickle.load(open(filename, 'rb'))
            counts = dict(
                Counter(counts) + Counter(content["results"][step]["data"]["counts"]))
        return counts

    def get_noise_level(self) -> Optional[str]:
        if self.backend.backend_type == QuantumBackendType.QUANTUM_COMPUTER:
            return None

        noise = ""
        for filename in self.get_circuit_run_result_filenames():
            content = pickle.load(open(filename, 'rb'))
            num_results = len(content['results'])
            for i in range(num_results):
                if noise == "":
                    noise = content['results'][i]['metadata']['noise']
                else:
                    assert noise == content['results'][i]['metadata']['noise']
        return noise

    def __execution_data_exists(self) -> bool:
        filenames = self.get_circuit_run_result_filenames()
        if len(filenames) == 0:
            return False
        for filename in filenames:
            if not os.path.exists(filename):
                return False
        return True

    def __extract_shots(self) -> int:
        shots = 0
        for filename in self.get_circuit_run_result_filenames():
            content = pickle.load(open(filename, 'rb'))
            num_results = len(content['results'])
            for i in range(num_results):
                if shots == 0:
                    shots = int(content['results'][i]['shots'])
                else:
                    assert shots == int(content['results'][i]['shots'])
        return shots

    def __str__(self) -> str:
        return f"Circuit: {self.circuit.get_name()}; Backend: {self.backend.backend_name}; Shots: {self.shots}"

    @staticmethod
    def __change_work_dir_to_current():
        script_path = os.path.abspath(__file__)
        script_dir = os.path.dirname(script_path)
        os.chdir(script_dir)

