#import "@local/cetz:0.2.0"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#set heading(numbering: "1.1.")
#set page(numbering: "1")

#outline()

#pagebreak()

// TODO at some places switch quantum computer with QC
= Introduction and Motivation
The quantum computing market is expected to grow from USD 866 million in 2023 to USD 4.375 million in 2030 @QuantumComputingMarket2023.
Quantum computing is especially promising in the fields of simulations, drug development and cybersecurity @emilioCurrentStatusNext2022.
Despite these positive prognoses, current quantum computers are still called Noisy Intermediate-Scale Quantum (NISQ) devices due to the high error and noise rates @preskillQuantumComputingNISQ2018.
Current quantum computers are provided as cloud based services to the user by startups such as Rigetti @RigettiQuantumComputing2024 or IonQ @CompareQuantumSystems2024 and tech giants like IBM @IBMQuantum2024, Microsoft @AzureQuantumQuantum2024 or Amazon @CloudQuantumComputing2024.
These services are mainly aimed at academics and researchers.
As a first step for using such a cloud-based quantum computer, a user account needs to be registered.
Afterwards, the user develops the quantum circuit (e.g. in IBM's Qiskit @Qiskit2024), uploads the quantum circuit and can choose a backend to execute the circuit on.
In a next step, the request gets scheduled and executed on the quantum computer.
Finally, results are sent back to the user.
#figure(
  image("images/quantum-based-cloud-provider-trust-left-to-right.svg"),
  caption: "The user is sending the quantum circuit to the cloud-based quantum computing provider and has to trust the provider that the circuit is executed on an actual quantum computer."
) <cloud-trust>
In this cloud based scenario, the user has to trust the cloud-based quantum provider to execute the quantum circuit on the advertised quantum hardware.
An adversarial cloud-provider could potentially claim to have a quantum computer backend, but in reality all circuits are just simulated on a classical computer.
This scenario primarily affects small circuits due to the exponential growth in dimensions, rendering larger circuits impractical for computation with classical hardware.
// TODO quantum supremacy?? überhaupt wichtig?
In 2020, a research team led by scientist Jian-Wei Pan at the University of Science and Technology of China (USTC) achieved quantum supremacy using 76 photons for the Gaussian boson sampling algorithm @garistoLightBasedQuantumComputer2021.
The samples generated in the study required 200 seconds, a task estimated to take a classical supercomputer 2.5 billion years to complete, as detailed in the paper @zhongQuantumComputationalAdvantage2020.
Quantum supremacy marks the point at which quantum computers can outperform classical computers in specific tasks.
But apaprt from these highly specialized setups, it is still possible to simulate small quantum circuits.
As of 2023, a rough cost estimate for a 9-qubit quantum computer from Rigetti stands at \$900,000 @mechanicRigettiLaunchesNovera2023.
Conversely, simulators can execute small circuits on consumer hardware, drastically reducing the cost barrier for executing quantum computations.
This cost consideration coupled with the scalability limitations of classical hardware underscores the significance of the threat posed by cloud quantum providers employing simulators, particularly in scenarios where the users are unaware of this substitution.
Therefore, mitigating strategies should be devised to ensure transparency and trust in quantum cloud services to safeguard against potential security breaches and ensure the integrity of quantum computations.

// TODO write in 3rd person?
// TODO Paper Contributions mehr herausarbeiten.
This work provides a machine learning based approach which allows the users of cloud-based quantum computers to verify with high certainty that their quantum circuit has been executed on a quantum computer (and not simulated on a classical computer).

== Related Work <related-work>
Previous work has already shown that it is possible to generate a unique hardware fingerprint which is based on the qubit frequencies. The fingerprint is based on quantum computer calibration data which was made available by the cloud provider @smithFastFingerprintingCloudbased2022.
A different research group has developed a Quantum Physically Unclonable Function (QuPUF).
By utilizing the QuPUF, it is possible to identify the quantum computer the QuPUF was executed on @phalakQuantumPUFSecurity2021.
Another approach uses a tomography-based fingerprinting method which is based on crosstalk-induced errors @miShortPaperDevice2021.

The paper "Noise fingerprints in quantum computers: Machine learning software tools" by Martina et al. distinguishes on which quantum computer a specific quantum circuit has been executed by learning the error-fingerprint using a support vector machine @martinaLearningNoiseFingerprint2022.

This paper takes a similar approach to "Noise fingerprints in quantum computers: Machine learning software tools" by Martina et al. @martinaLearningNoiseFingerprint2022 and utilizes the same quantum circuit, but instead of differentiating between various quantum computers, this paper creates machine learning models which are capable of distinguishing whether a quantum circuit was executed by a quantum computer or a simulator on a classical computer.

== Structure
@terms-and-definitions gives a short overview about the most important concepts of quantum computing and machine learning used in this paper.
In @approach the dataset used for training different machine learning algorithms in order to differentiate whether a quantum circuit has been executed by a quantum computer or simulated by a classical computer.
After that in @evaluation the accuracies of the different machine learning algorithms are compared and limitations of this work are discussed.
// TODO und die Anwendbarkeit gezeigt.
// TODO angreifbarkeit zeigen (adversarial attack)
@future-work points out possible questions for further research.
In the end @conclusion contains a short conclusion.


= Terms and Definitions <terms-and-definitions>
This section provides a brief introduction to quantum computing and machine learning ideas.

== Quantum Computing
A quantum computer leverages quantum bits (qubits).
Qubits have two basis states $|0 angle.r = [1, 0]^top$ and $|1 angle.r = [0, 1]^top$.
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
// TODO Erkläre wieso shots benötigt werden.
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
A Support Vector Machine (SVM) is a machine learning algorithm primarily used for classification and regression tasks.
It operates by constructing an optimal hyperplane in a high-dimensional space that separates different classes of data points.
This optimal hyperplane is determined by the data points, referred to as support vectors, that lie closest to the decision boundary, see @svm.
The hyperplane divides the input features into two distinct classes.
Its position and orientation are determined to maximize the margin or distance between the hyperplane and the nearest data point from either class.
This approach ensures the best possible separation between classes and enhances the algorithm's generalization capabilities.
// TODO eventuell kürzen??
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

=== Adversarial Attack
// TODO


= Approach <approach>
The methods mentioned in @related-work are used for fingerprinting, meaning they can predict which results originate from which quantum computer, but they cannot distinguish between a QC or a simulator.
This work therefore attempts to develop an approach that performs this differentiation.
In order to achieve this, only the measurement results of the quantum ciruits are considered.
Therefore this paper uses machine learing techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the circuit's measurement results.
The only precondition is that the data labels are correct (measurement results labeled as 'quantum computer data' have to be from an actual quantum computer).

== Data for Training
The measurement results from a quantum computer  are taken from @martinaLearningQuantumNoiseFingerprint2023.
The reason being that no access to a quantum computer was available during the creation of this paper.
The quantum computer data is the result of running the circuit described in @circuit on up to 8 different IBM quantum machines.
In the dataset it is clearly identifiable on which of the quantum computers the circuit was executed.
The simulation data for this work was created by simulating the identical quantum circuits from @martinaLearningQuantumNoiseFingerprint2023 with Qiskit @Qiskit2024.

=== Circuit <circuit>
The entire circuit looks like @circuit-complete.
In order to measure the circuit at different points, this circuit is executed until different points (steps) and a measurement of the qubits $q_2$ and $q_3$ is carried out after each step.

#figure(
  image("images/walker-step-9.svg"),
  caption: "Complete circuit with 4 qubits. Only the lower two qubits are being measured at the end. Grey separators mark points at which measurements can take place."
) <circuit-complete>

Due to the wavefunction collapse, a new circuit has to be executed and measured for each measurement step.
The entire process is shown in @circuit-steps.
#figure(
  grid(
    columns: 2,
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
  caption: "Circuit with different point at which they get measured."
) <circuit-steps>

This results in 9 measurement points for this circuit.
Each circuit run has been performed with 8000 shots.
For one circuit run with 8000 shots the measurement results look like @measurement-data-table.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: horizon,
    [*Shot*], [*Step 1*], [*step 2*], [*step 3*], [*...*], [*step 9*],
    [1], [$10_2$], [$00_2$], [$11_2$], [...], [$00_2$],
    [2], [$11_2$], [$01_2$], [$10_2$], [...], [$11_2$],
    [...], [...], [...], [...], [...], [...],
    [8000], [$01_2$], [$00_2$], [$00_2$], [...], [$10_2$]
  ), 
  caption: "Measurement examples for one run with 8000 shots. There exist 250 measurement tables for each quantum computer."
) <measurement-data-table>

=== Executions on Simulator
To obtain the simulated data, 7 different Qiskit simulators are utilized.
Only one backend calculates a noise free result, because the variance is caused by the noise but different simulator implementations deliver very similar results.
In order to obtain a comparable order of magnitude of simulated data to that of QC generated data, 6 additional simulators with noise are used.
All of the 6 backends are each utilizing a different noise model which is based on calibration data from real IBM quantum computers @Fake_provider.

== Machine Learning Approaches
The basic approach makes use of machine learning algorithms to distinguish whether a quantum circuit was executed on a QC or a simulator.
As a first approach, different ML algorithms were trained with the unpreprocessed measurement data.
In each case, the complete data set for a measurement point (step) over 8000 shots (i.e. 8000 individual values) was used as an input.
The individual steps are considered completely independently of each other.
In particular, 8000 input neurons had to be used for the artificial neural net.

As a second approach, the data has been preprocessed before machine learning algorithms were applied to it.
For this purpose, the probability values per step were calculated for the four possible result values ($00_2$, $01_2$, $10_2$, $11_2$).
Only these probability values are used as input for the ML algorithms.
When considering a step > 1, the probability values of the previous steps were also used.
This means that step 1 has 4 input values, step 2 has 8 (the 4 unchanged values from step 1 and the 4 additional probabilities from step 2), step 3 has 12 and so on. (See @probability-calculation-table-step-1 and @probability-calculation-table-steps-1-and-2)
// TODO Figure schöner machen.
#figure(
  grid(
    columns: 1,
    gutter: 5mm,
    // TODO add after update align: (center, center, center, center),
    table(
      columns: (auto, auto, auto),
      align: horizon,
      [*Shot*], [*Step 1*], [*...*],
      [1], [$10_2$], [...], 
      [2], [$11_2$], [...], 
      [3], [$11_2$], [...],
      [4], [$01_2$], [...], 
      [5], [$11_2$], [...], 
    ), 
    $ text("Extracted:") [ overbrace([ underbrace(0.0, "Probability for " 00_2 "in Step 1"), 0.2, 0.2, 0.6], "Probabilities for Step 1"), ...] $,
  ),
  caption: "Visualization how the probabilities used as input for the machine learning algorithms are getting extracted from the measurements, including only the first measurement step."
) <probability-calculation-table-step-1>

#figure(
  grid(
    columns: 1,
    gutter: 5mm,
    // TODO add after update align: (center, center, center, center),
    table(
      columns: (auto, auto, auto, auto),
      align: horizon,
      [*Shot*], [*Step 1*], [*Step 2*], [*...*],
      [1], [$10_2$], [$00_2$], [...], 
      [2], [$11_2$], [$00_2$], [...], 
      [3], [$11_2$], [$11_2$], [...],
      [4], [$01_2$], [$01_2$], [...], 
      [5], [$11_2$], [$11_2$], [...], 
    ), 
    $ text("Extracted:") [overbrace([ underbrace(0.0, "Probability for " 00_2 "in Step 1"), 0.2, 0.2, 0.6], "Probabilities for Step 1"), overbrace([0.4, 0.2, 0.0, 0.4], "Probabilities for Step 2"), ...] $,
  ),
  caption: "Visualization how the probabilities used as input for the machine learning algorithms are getting extracted from the measurements, including the first and the second measurement steps."
) <probability-calculation-table-steps-1-and-2>

This second approach also examines whether the 8000 shots can be meaningfully divided into smaller packages.
This has the advantage that more test and training data packages can be formed from the data available for this work.

=== Support Vector Machine
- Use different svm algorithms (linear, poly 4, rbf, ...) as proposed in @martinaLearningNoiseFingerprint2022.
TODO Verlinkung zu @terms-and-definitions.

=== Artificial Neural Net
// TODO keras tuner not needed, hyperparameter due to data preprocessing really stable.
TODO Verlinkung zu @terms-and-definitions.

=== Convolutional Neural Net

TODO Verlinkung zu @terms-and-definitions.

== Adversarial Machine Learning
//TODO "angreiferseite": Adversarial Machine Learning manipulieren


= Evaluation <evaluation>
Describes why this thesis really solves the problem it claims to solve. (contains results and measurements) 

//TODO Komplette Quantencomputer aus dem trainingsset excludieren. (nur mit "optimaler" Window Size)
// einmal jeden QC und einmal jeden Simulator im Training excludieren.
// Tabelle ausgeschlossener QC oder Simulator (Zeile) vs step ranges

== Support Vector Machine
// TODO mention that window sizes 5 to 40 have been excluded (too compute intensive)
#let svm_step_range_vs_window_size = csv("data/svm_window_sizes_vs_step_ranges_all_backends_combined.csv")
#figure(
  tablex(
    columns: 10,
    align: center,
      map-cells: cell => {
    if cell.x >= 1 and cell.y >= 2 {
      cell.content = {
        let value = float(cell.content.text)
        let text-color = gradient.linear(red, green).sample(value * 100%)
        return (..cell, fill: text-color)
      }
    }
    return cell
  },
    [],colspanx(9)[*Step Ranges*],[*Window Sizes*],..svm_step_range_vs_window_size.flatten().slice(1,)
  ),
  caption: ""
)

== Artificial Neural Net
#let ann_step_range_vs_window_size = csv("data/neural_net_window_sizes_vs_step_ranges_all_backends_combined.csv")
#figure(
  tablex(
    columns: 10,
    align: center,
      map-cells: cell => {
    if cell.x >= 1 and cell.y >= 2 {
      cell.content = {
        let value = float(cell.content.text)
        let text-color = gradient.linear(red, green).sample(value * 100%)
        return (..cell, fill: text-color)
      }
    }
    return cell
  },
    [],colspanx(9)[*Step Ranges*],[*Window Sizes*],..ann_step_range_vs_window_size.flatten().slice(1,)
  ),
  caption: ""
)

== Convolutional Neural Net
#let cnn_step_range_vs_window_size = csv("data/cnn_window_sizes_vs_step_ranges_all_backends_combined.csv")
#figure(
  tablex(
    columns: 10,
    align: center,
      map-cells: cell => {
    if cell.x >= 1 and cell.y >= 2 {
      cell.content = {
        let value = float(cell.content.text)
        let text-color = gradient.linear(red, green).sample(value * 100%)
        return (..cell, fill: text-color)
      }
    }
    return cell
  },
    [],colspanx(9)[*Step Ranges*],[*Window Sizes*],..cnn_step_range_vs_window_size.flatten().slice(1,)
  ),
  caption: ""
)

// hier "beste" fälle zeigen
// zeige sowohl "gemischtes ausschließen", als auch "mehrere Quantencomputer ausschließen"
// TODO ohne manche simulator trainieren (erkennt er einen unbekannten simulator)

== Limitations
// TODO nur eingeschränkt richtig
// possible to detect the circuit and route it (maybe to another provider for correct results).
// To counteract this: embed the circuit inside the "real circuit". (uses only 4 qubits of possibly larger quantum computer)

= Future Work <future-work>
Short, what would I improve if I had infinitely more time?

= Conclusion <conclusion>
Summary

#pagebreak()

#bibliography("Sources.bib")