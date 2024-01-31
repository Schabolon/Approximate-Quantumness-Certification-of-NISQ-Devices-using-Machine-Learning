#set heading(numbering: "1.1.")

#outline()

= Introduction and Motivation
- Herleitung des Themas anhand von "Betrug" im Cloud-Computing: Nutzer muss dem Cloud-Anbieter vertrauen -> Möglichkeit für den Endnutzer um festzustellen, ob tatsächlich ein QC für die Berechnung verwendet wurde.

Content:
1. Describes Problem Statement (Why is this a problem?)
2. Contribution this thesis makes to solve the problem.

== Structure
Short description of remaining chapters.


= Terms and Definitions
Very short, reference other works whenever possible.


= Approach
Main algorithm/approach of this thesis.

Use ML techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the calculated results.

== Data for Training
Using different circuits.
- 8000 shots per run.

Example:


=== Circuits
Circuits executed multiple times until different points.

Example:
#figure(
  grid(
    columns: 2,
    gutter: 2mm,
    image("images/walker-step-1.svg"),
    image("images/walker-step-2.svg"),
    image("images/walker-step-3.svg"),
    ),
  caption: "Walker circuit with different steps. Source:" //TODO image created on my own, circuit from paper. Do I have to give the paper as source?
) <walker-steps>

Each step is executed seperately.


=== Executins on Simulator
- 6 different QISKIT simulators. @Qiskit
- `quasm_simulator` uses noise model @QasmSimulatorQiskitAer
- the other 5 models calculate a noise free result.
//TODO show histogram -> without noise model doesn't make "errors"

=== Executions on Quantum Computer
- no own access to a quantum computer -> run-data taken from @martinaLearningQuantumNoiseFingerprint2023
- used up to 8 different IBM quantum machines to run the circuit on.

== Machine Learning Approaches
=== Support Vector Machine
- Use different "versions" as proposed in @martinaLearningNoiseFingerprint2022.

=== Neuronal Net
- Used 'Keras Tuner' for hyper parameter tuning.

=== Convolutional Neuronal Net
=== Long Short-Term Memory


= Evaluation
Describes why this thesis really solves the problem it claims to solve. (contains results and measurements) 

= Related Work
//TODO should this section be up front between "Terms and Definitions" and "Approach"?
List of relevant work, how is the other work relevant + comparison with own work (short summary).

- Learning the noise fingerprint of quantum devices @martinaLearningNoiseFingerprint2022

= Future Work
Short, what would I improve if I had infinitely more time?

= Conclusion
Summary

#bibliography("Sources.bib")