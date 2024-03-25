# Approximate Quantumness Certification of NISQ Devices using Machine Learning

## Overview
- `code/`: all the python code and data for training and evaluating the ML model.
  - `visualization/`: images of quantum circuits, quantum gates and histograms.
  - `results/`: files containing accuracy measurements for the different models.
  - `data/`: training data.
  - `src/`: python code.
    - `model/`: contains code for training and evaluating the different machine learning models
    - `quantum_circuits/`: Qiskit implementations for the quantum circuits.
    - `visualization/`: code for generating visualizations for quantum circuits, gates and histograms.
    - `circuit_run_data.py`: manages the data for a single circuit + backend.
    - `dataset.py`: manages a dataset. Generates simulator data if needed.
    - `main.py`: start evaluating the machine learning models from here.
    - `quantum_backend_type.py`: enum to manage different labels and folder names for quantum computers and simulators.
    - `quantum_backends.py`: enum of quantum backends (simulators and quantum computers).
    - `simulator.py`: generate training data by simulating quantum circuits.
- `paper/`: the source file for building the paper as pdf.

## Setup
### Prerequisites
- [Python](https://www.python.org/) >= 3.11
- [typst](https://typst.app/) >= 0.10.0 (only for generating the paper)

### Installation
> Good Practice: Create and enter a virtual python environment.
> 
> - Creation: `python -m venv venv`
> - Activation:
>   - Windows: cmd: `venv\Scripts\activate.bat` or PowerShell: `venv\Scripts\Activate.ps1`
>   - Linux/MacOS: run `source venv/bin/activate`
 
Install required packages: `pip install -r requirements.txt`

## Usage
- (Activate virtual environment if necessary)
- Execute `.py` files by entering the corresponding folder and running `python <filename>.py`
