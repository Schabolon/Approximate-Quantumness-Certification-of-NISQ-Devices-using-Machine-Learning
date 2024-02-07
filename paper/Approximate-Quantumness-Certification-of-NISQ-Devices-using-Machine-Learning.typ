#import "@local/cetz:0.2.0"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#set heading(numbering: "1.1.")

#outline()

= Introduction and Motivation
- Herleitung des Themas anhand von "Betrug" im Cloud-Computing: Nutzer muss dem Cloud-Anbieter vertrauen -> Möglichkeit für den Endnutzer um festzustellen, ob tatsächlich ein QC für die Berechnung verwendet wurde.

Currently still Noisy Intermediate-Scale Quantum (NISQ) @preskillQuantumComputingNISQ2018 devices.

Threat Model:
Cloud based services (IBM @IBMQuantum2024, Rigetti @RigettiQuantumComputing2024)

Influence of quantum computers on different industries (simulation, drug development, cyber security) @emilioCurrentStatusNext2022

// TODO ab welcher Qubit Zahl ist Simulation nicht mehr "sinnvoll"?

Content:
1. Describes Problem Statement (Why is this a problem?)
  what is already known about this subject (with references).
2. Contribution this thesis makes to solve the problem.

== Structure
Short description of remaining chapters.


= Terms and Definitions
Very short, reference other works whenever possible.
// TODO add quantum computing fundamentals?
// TODO add ml fundamentals (neural net, cnn?)


= Approach
Main algorithm/approach of this thesis.

Use ML techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the calculated results.

== Data for Training

// TODO use different circuits? (or only use walker?).
- 8000 shots per run.

// TODO create table with characteristics of different quantum computers and simulators (e.g. does Simulator use noise?)

Table Execution memory:
#table(
  columns: (auto, auto, auto, auto, auto),
  align: horizon,
  [*Shot*], [*Results for step 1*], [*Results for step 2*], [*Results for step 3*], [*...*],
  [1], [`0x1`], [`0x3`], [`0x0`], [...],
  [2], [`0x0`], [`0x1`], [`0x0`], [...],
  [...], [...], [...], [...], [...],
  [8000], [`0x2`], [`0x1`], [`0x3`], [...],
)
There exist around 250 of these tables for each quantum computer for circuit Walker.

#let data = csv("data/walker_svm_quantum_vs_simulator_window_size_1000_step_1.csv")
#figure(
  table(
    columns: 13,
    ..data.flatten()
  ),
  caption: "Comparison accuracy of SVM for all quantum computers vs all simulators on circuit walker."
)


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
The third circuit is repeated 3 times.

Each step is executed seperately.


=== Executins on Simulator
- Different QISKIT simulators. @Qiskit2024
- 6 backends calculate a noise free result.
- 6 backends _with_ noise models.
//TODO show histogram -> without noise model doesn't make "errors"?

=== Executions on Quantum Computer
- no own access to a quantum computer -> run-data taken from @martinaLearningQuantumNoiseFingerprint2023
- used up to 8 different IBM quantum machines to run the circuit on.

== Machine Learning Approaches
=== Support Vector Machine
- Use different svm algorithms (linear, poly 4, rbf, ...) as proposed in @martinaLearningNoiseFingerprint2022.

=== Artificial Neural Net
- Used 'Keras Tuner' for hyper parameter tuning.

=== Convolutional Neural Net


= Evaluation
Describes why this thesis really solves the problem it claims to solve. (contains results and measurements) 

#let prob_data = csv("data/walker_svm_different_probabilities_ibmq_quito_vs_aer_simulator.csv")
#cetz.canvas(length: 1.5cm, {
  import cetz.draw: *
  import cetz.plot
  plot.plot(size: (10,5), x-tick-step: none, y-tick-step: none, 
    x-ticks: (prob_data.map(((window,acc)) => ((calc.log(int(window)+1),int(window))))),
    x-label: "Window Size",
    y-min: 0.4, y-max: 1,
    y-ticks: (0.5, 0.75, 0.9, 1),
    y-label: "Accuraccy",
  {
    plot.add(prob_data.map(((window,acc)) => (calc.log(int(window)+1), float(acc))))
  })
})

= Related Work
//TODO should this section be up front between "Terms and Definitions" and "Approach"?
List of relevant work, how is the other work relevant + comparison with own work (short summary).

- Distinguish on which quantum computer a specific quantum circuit has been executed (fingerprint) using a support vector machine. @martinaLearningNoiseFingerprint2022
- unique hardware fingerprints (based on qubit frequency) extracted from calibration data. @smithFastFingerprintingCloudbased2022
- Fingerprinting of quantum computers using crosstalk. @miShortPaperDevice2021
- Send Quantum Physically Unclonable Function (QuPUF) to quantum computer, get back response, compare response with expected response (unique to each hardware because of gate error rates, decoherence times, ...) @phalakQuantumPUFSecurity2021

== Probably irrelevant
// TODO confirm (and delete)
- Use a quantum algorithm to localize different devices emmiting radio frequencies (mobile phones, IoT devices).@shokryDeviceindependentQuantumFingerprinting2022

= Future Work
Short, what would I improve if I had infinitely more time?

= Conclusion
Summary

#bibliography("Sources.bib")