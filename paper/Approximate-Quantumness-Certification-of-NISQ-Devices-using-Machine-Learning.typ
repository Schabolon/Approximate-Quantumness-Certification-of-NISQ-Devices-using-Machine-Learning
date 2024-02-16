#import "@local/cetz:0.2.0"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#set heading(numbering: "1.1.")
#set page(numbering: "1")

#outline()

#pagebreak()

// TODO at some places switch quantum computer with QC
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
// TODO Threat model mehr herausarbeiten. (eigene Überschrift?)
// TODO erwähnen, dass dieses Threat model nur für kleine Circuits relevant ist? (explosion der Dimensonen, nicht mit klassischer Hardware berechenbar)
In this cloud based scenario, the user has to trust the cloud-based quantum provider to execute the quantum circuit on the advertised quantum hardware.
An adversarial cloud-provider could potentially claim to have a quantum computer backend, but in reality all circuits are just simulated on a classical computer.
// TODO write in 3rd person?
// TODO Paper Contributions mehr herausarbeiten.
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
This section provides a brief introduction to quantum computing and machine learning ideas.

== Quantum Computing
A quantum computer leverages quantum bits (qubits).
Qubits have two basis states $|0 angle.r = [1, 0]^T$ and $|1 angle.r = [0, 1]^T$. // TODO change 'T' to dedicated Transpose symbol?
The notation with '$| med angle.r$' is called Dirac notation.
Classical bits are either 0 or 1.
Qubits on the other hand can be in states other than $|0 angle.r$ and $|1 angle.r$.
A superposition is denoted as linear combination of states as seen in @superpositon-linear-combination.
#figure(
  $ |psi angle.r = alpha|0 angle.r + beta|1 angle.r $,
  caption: "Qubit state written as linear combination of the two basis states"
) <superpositon-linear-combination>
In @superpositon-linear-combination $alpha$ and $beta$ are complex values and describe probability amplitudes.
The probabilities have to satisfy the normalization condition $|alpha|^2 + |beta|^2 = 1$.
By leveraging quantum properties such as superposition, interference and entanglement, it is possible to solve a specific selection of problems with reduced time and space complexity.
One example for such a quantum algorithm is Shor's algorithm @shorPolynomialTimeAlgorithmsPrime1997.
In this paper circuit are made of the Pauli-X gate, the Hadamard gate, the Controlled not gate (CNOT) and the Toffoli gate. Their respective circuit representation can be seen in @quantum-gates.
The Pauli-X gate performs a base flip on a single qubit.
// TODO what does the hadamard gate do?
The CNOT gate performs a base flip on the target qubit, depending on the state of the control qubit.
Similarly, the Toffoli gate has two control qubits which influence, whether the target qubit gets flipped.
#figure(
  grid(
    columns: 4,
    align(horizon, image("images/gates/pauli-x.svg", width: 50%)),
    align(horizon, image("images/gates/hadamard.svg", width: 50%)),
    align(horizon, image("images/gates/cnot.svg", width: 40%)),
    align(horizon, image("images/gates/ccx.svg", width: 30%))
  ),
  caption: "Quantum gates (from left to right): Pauli-X gate, Hadamard gate, Controlled not gate, Toffoli gate"
) <quantum-gates>
After performing a measurement on a qubit, the result is either a $0$ or a $1$.
// TODO add reference to circuit design (reason, why these different circuits had to be created/run seperately and not measured in between)
After a measurement, the wave function collapses and the qubit remains in either the $|0 angle.r$ state (if $0$ has been measured) or in the $|1 angle.r$ state (if $1$ has been measured).
The number of shots specifies how many times one algorithm is run on the quantum computer.
As a result, the user receives a distribution of the different outcomes @nielsenQuantumComputationQuantum2010.

// Current hardware (physical qubits)
For building physical quantum computers, different approaches exist.
Quantum computers built by IBM are based on superconducting qubit technology @QuantumSystemInformation.
Other architectures include trapped ions, photonics and nuclear magnetic resonance @laddQuantumComputers2010.
Current quantum chips mainly suffer from decoherence, gate errors, readout errors and crosstalk.
For a qubit the decoherence time refers to how long the qubit can contain its information.
Decoherence can occur for example when a qubit interacts with the environment.
When quantum computers are constructed from multiple qubits, unwanted interactions between these qubits is called crosstalk.

== Machine Learning
In this paper, the following supervised learning approaches are being utilized.

=== Support Vector Machine
#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot
      plot.plot(
        size: (5,4),
        x-tick-step: none,
        y-tick-step: none,
        x-min: 0,
        x-max: 6,
        y-min: 0,
        y-max: 6,
        x-label: "",
        y-label: "",
        legend: "legend.south",
      {
      plot.add(((0,1), (5,6)), label: "Hyperplane")
      let points_above = ((.3, 2), (1,4), (.7, 3), (1.1, 5), (1.4, 4), (2, 3.4), (2.1, 4.5), (2.9, 4.4), (3.4, 5.2), (4, 5.5))
      let points_below = ((.7,1), (1,.3), (1.8, 1.5), (2.5, 1.2), (2.2, 0.8), (3.1, 1.3), (3.8, 1.1), (4.2, 1.8), (4.5, 1.5), (5.8, 1.1), (2.7, 0.5), (3.4, 0.8), (3.9, 0.6), (4.6, 0.9), (5.3, 0.7), (4, 4), (5, 5.4), (3.7, 3), (5.8, 5), (5, 3), (3, 2), (2, 2), (2.5, 3.1), (1.5, 1.9), (5.2, 3.8), (5.3, 2))
      for (p_1, p_2) in points_above {
        cetz.plot.add(((p_1, p_2),), mark: "o", mark-style: (stroke: red, fill: red), mark-size: .1)
      }
      for (p_1, p_2) in points_below {
        cetz.plot.add(((p_1, p_2),), mark: "o", mark-style: (stroke: green, fill: green), mark-size: .1)
      }
    })
  }),
  caption: "SVM:"
) <svm>
// A support vector machine (SVM) uses a hyperplane based on a linear function to separate input features into two classes, see @svm.
// By mapping the input features into a higher-dimensional features space, a so-called kernel trick, it is possible to perform non-linear classification.
// svm maximizes margin? -> best generalization?
// svm really short, no "new" research in this paper

A Support Vector Machine (SVM) is a machine learning algorithm primarily used for classification and regression tasks.
It operates by constructing an optimal hyperplane in a high-dimensional space that separates different classes of data points.
This optimal hyperplane is determined by the data points, referred to as support vectors, that lie closest to the decision boundary, see @svm.
The hyperplane divides the input features into two distinct classes.
Its position and orientation are determined to maximize the margin or distance between the hyperplane and the nearest data point from either class.
This approach ensures the best possible separation between classes and enhances the algorithm's generalization capabilities.
However, real-world data is often not linearly separable.
To overcome this limitation, SVMs employ a technique known as the kernel trick.
A linear decision boundary can be found by mapping the input features into a higher dimensional feature space.
The kernel trick allows SVMs to construct a non-linear decision boundary in the original input space, thereby enabling the classification of complex datasets.
As a result, SVMs are computationally efficient and particularly suited for handling high-dimensional data.
See @cristianiniIntroductionSupportVector2000 for additional details.

=== Feedforward Neural Network
Each neural network consists of multiple neurons/perceptrons.
These perceptrons are grouped in layers.
The first layer is called input layer.
After that come hidden layers.
The results are taken from the last layer, the output layer.
See @feedforward-net for a visualization.
#figure(
  image("images/feedforward-neural-network.svg", height: 25%),
  caption: "Feed forward neural net"
) <feedforward-net>

For each neuron @perceptron-math is calculated.

#figure(
  $ y = f(sum_(i=1)^(n) w_i x_i + b) $,
  caption: "Equation for a single perceptron. y: output, f: activation function, w_i: weights for each input x_i, b: bias, n: number of inputs"
) <perceptron-math>

For more details see @russellArtificialIntelligenceModern2021.

// multiple neuron layers
// hidden layer
// connections have weights
// bias
// each neuron has activation function

=== Convolutional Neural Network
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

// TODO in the beginning, every qubit is in state |0>

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