from qiskit_aer import Aer, AerSimulator


# `Aer.get_backend('aer_simulator_stabilizer')` results in an error.
# `Aer.get_backend('aer_simulator_unitary')`: seems like it can't measure.
# `Aer.get_backend('aer_simulator_superop')`: seems like it can't measure.
# `Aer.get_backend('unitary_simulator')`: results in " contains invalid instructions {"instructions": {save_unitary}} for "statevector" method."
# takes very long:(Aer.get_backend('aer_simulator_extended_stabilizer'),
simulators: list[AerSimulator] = [Aer.get_backend('aer_simulator'),
                                  Aer.get_backend('aer_simulator_density_matrix'),
                                  Aer.get_backend('aer_simulator_statevector'),
                                  Aer.get_backend('aer_simulator_matrix_product_state'),
                                  Aer.get_backend('qasm_simulator'),
                                  Aer.get_backend('statevector_simulator')]


def get_simulator_name(simulator: AerSimulator) -> str:
    return simulator.configuration().backend_name


def get_all_simulator_names() -> list[str]:
    names = []
    for simulator in simulators:
        names.append(get_simulator_name(simulator))
    return names
