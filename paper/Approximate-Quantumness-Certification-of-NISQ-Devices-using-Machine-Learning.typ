#import "@local/cetz:0.2.0"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#set heading(numbering: "1.1.")
#set page(numbering: "1")

#outline()

#pagebreak()

= Introduction and Motivation
The quantum computing market is expected to grow from USD 866 million in 2023 to USD 4375 million in 2030 @QuantumComputingMarket2023. //TODO is source good enough? // TODO add , (or .?) to 4375?
Quantum computing is especially promising in the fields of simulations, drug development and cybersecurity @emilioCurrentStatusNext2022.
Despite these positive prognoses, current quantum computers are still called Noisy Intermediate-Scale Quantum (NISQ) devices due to the high error and noise rates @preskillQuantumComputingNISQ2018.
Current quantum computers are provided as cloud based services to the user by startups such as Rigetti @RigettiQuantumComputing2024 or @CompareQuantumSystems2024 and tech giants like IBM @IBMQuantum2024, Microsoft @AzureQuantumQuantum2024 or Amazon @CloudQuantumComputing2024.
These services are mainly aimed at academics and researchers. //TODO relevant?
As a first step for using such a cloud-based quantum computer, a user account needs to be registered.
Afterwards, the user develops the quantum circuit (e.g. in IBM's Qiskit @Qiskit2024), uploads the quantum circuit and can choose a backend to execute the circuit on.
In a next step, the request gets scheduled and executed on the quantum computer.
Finally, results are sent back to the user.
#figure(
  image("images/quantum-based-cloud-provider-trust-left-to-right.svg"),
  caption: "The user is sending the quantum circuit to the cloud-based quantum computing provider and has to trust the provider that the circuit is executed on an actual quantum computer."
) <cloud-trust>
In this cloud based scenario, the user has to trust the cloud-based quantum provider to execute tho quantum circuit on the advertised quantum hardware.
An adversarial cloud-provider could potentially claim to have a quantum computer backend, but in reality all circuits are just simulated on a classical computer.
// TODO write in 3rd person?
This work provides a machine learning based approach which allows the users of cloud-based quantum computers to verify with high certainty that their quantum circuit has been executed on a quantum computer (and not simulated on a classical computer).

== Related Work
Previous work has already shown that it is possible to generate a unique hardware fingerprint which is based on the qubit frequencies. The fingerprint is based on quantum computer calibration data which was made available by the cloud provider @smithFastFingerprintingCloudbased2022.
A different research group has developed a Quantum Physically Unclonable Function (QuPUF).
By utilizing the QuPUF, it is possible to identify the quantum computer the QuPUF was executed on @phalakQuantumPUFSecurity2021.
Another approach uses a tomography-based fingerprinting method which is based on crosstalk-induced errors @miShortPaperDevice2021.

A paper by Martina et al. //TODO ist das korrekt?
distinguishes on which quantum computer a specific quantum circuit has been executed by learning the error-fingerprint using a support vector machine. @martinaLearningNoiseFingerprint2022

This paper takes a similar approach to @martinaLearningNoiseFingerprint2022 and utilizes the same quantum circuit, but instead of differentiating between various quantum computers, this paper creates machine learning models which are capable of distinguishing whether a quantum circuit was executed by a quantum computer or a simulator on a classical computer.

== Structure
@terms-and-definitions gives a short overview about the most important concepts of quantum computing and machine learning used in this paper.
In @approach the dataset used for training different machine learning algorithms in order to differentiate whether a quantum circuit has been executed by a quantum computer or simulated by a classical computer.
After that in @evaluation the accuracies of the different machine learning algorithms are compared and limitations of this work are discussed.
@future-work points out possible questions for further research.
In the end @conclusion contains a short conclusion.


= Terms and Definitions <terms-and-definitions>
- qubit -> 1, 0, superposition
- after meassuring -> wave function collapse -> result is 1 or 0.
- different gates (hadamard 'H', Cnot '+', Pauli-X 'X')
- current architecture error prone. -> noise
- different physical implementation/architecture. -> what does IBM use?
- execute circuit multiple times -> shots

ml basics:
- svm
- neural net
- cnn
(kein gradient descent erklären)

// wenig detail, self contained
// Grundkonzepte von Circuit darstellen (auf computer science ebene)
Very short, reference other works whenever possible.
// TODO add quantum computing fundamentals?
// TODO add ml fundamentals (neural net, cnn?), (wenn dann extrem knapp)


= Approach <approach>
Main algorithm/approach of this thesis.

Use ML techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the calculated results.

== Data for Training
erst rohdaten, hat nicht funktioniert -> danach vorverarbeitet.
Vorverarbeiten auch gut, da verschiedene circuit steps (aber im selben run) zusammengefasst werden. -> zeitliche abhängigkeit.
// TODO evtl untersuchen (Graph mit Window Size)

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
    image("images/walker-step-1.svg", width: auto, height: auto),
    image("images/walker-step-2.svg"),
    image("images/walker-step-3.svg"),
    image("images/walker-step-4.svg"),
    image("images/walker-step-5.svg"),
    image("images/walker-step-6.svg"),
    image("images/walker-step-7.svg"),
    image("images/walker-step-8.svg"),
    image("images/walker-step-9.svg"),
    ),
  caption: "Walker circuit with different steps."
) <walker-steps>

// TODO bilder nicht, wenn selbse generiert

Each step is executed seperately.

//TODO Komplette Quantencomputer aus dem trainingsset excludieren.

//TODO "angreiferseite": Adversarial Machine Learning manipulieren

=== Executins on Simulator
- Different QISKIT simulators. @Qiskit2024
- 1 backend calculates a noise free result.
- 6 backends _with_ noise models.

=== Executions on Quantum Computer
- no own access to a quantum computer -> run-data taken from @martinaLearningQuantumNoiseFingerprint2023
- used up to 8 different IBM quantum machines to run the circuit on.

== Machine Learning Approaches
=== Support Vector Machine
- Use different svm algorithms (linear, poly 4, rbf, ...) as proposed in @martinaLearningNoiseFingerprint2022.

=== Artificial Neural Net
// TODO keras tuner not needed, hyperparameter due to data preprocessing really stable.

=== Convolutional Neural Net


= Evaluation <evaluation>
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

== Limitations
// possible to detect the circuit and route it (maybe to another provider for correct results).
// To counteract this: embed the circuit inside the "real circuit". (uses only 4 qubits of possibly larger quantum computer)

= Future Work <future-work>
Short, what would I improve if I had infinitely more time?

= Conclusion <conclusion>
Summary

#pagebreak()

#bibliography("Sources.bib")