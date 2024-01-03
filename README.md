# Approximate Quantumness Certification of NISQ Devices using Machine Learning

## Overview
- `code/`: all the python code and data for training and evaluating the ML model.
  - `circuit_images/`: images for the used quantum circuits (with their default parameters).
  - `data/`: trainings data.
  - `src/`: python code.
    - `extract_data.py`: combines simulated and quantum_computer data into one dataset.
    - `model.py`: very simple ML model.
    - `simulator.py`: generate training data by simulating quantum circuits.
    - `quantum_circuits/`: Qiskit implementations for the used quantum circuits.
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
>   - Linux/MacOS: run `source myvenv/bin/activate`
 
Install required packages: `pip install -r requirements.txt`

## Usage
- (Activate virtual environment if necessary)
- Execute `.py` files by entering the corresponding folder and running `python <filename>.py`

## Roadmap
- [ ] (Optional) Try out model with time dependence. (should allow a flexible amount of shots to be used.)
