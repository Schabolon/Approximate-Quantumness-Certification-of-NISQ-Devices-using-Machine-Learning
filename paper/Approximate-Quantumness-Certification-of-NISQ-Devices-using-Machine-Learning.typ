#import "@preview/cetz:0.2.2"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx
#import "@preview/lovelace:0.2.0": *
#import "@preview/diagraph:0.2.2": *

#show: setup-lovelace

#set text(lang: "en")
#set heading(numbering: "1.1.")
#set page(
  numbering: "1",
  number-align: center,
  margin: 3cm,
)
#set par(justify: true)
#set text(
  font: "Times New Roman",
  size: 12pt
)
#set math.equation(numbering: "(1)")

#show outline.entry.where(
  level: 1
): it => {
  v(14pt, weak: true)
  strong(it)
}

//TODO: übergänge zwischen den einzelnen sektionen, sollte am stück gelesen werden können?

//TODO: Deckblatt hinzufügen (+ check margin am rand)

//Optional: bei graphen die Ticks nach außen richten?
// Let ticks point outwards by giving them negative length
//    set-style(axes: (tick: (length: -.1)))

//Optional: perform Feature importance visualization??
//Optional: add confustion matrix?
//Optional: additionally add training curves to trainings performance of fnn and cnn.
//Optional: have a look, how well the adversarial samples perform on the two other classifiers
//Optional: Perturbation Magnitude (e.g., L0, L2, or L∞ norms) 
//Optional: Confidence Score Changes
//Optional: exclude simulator AND QC.

#align(center, text("Abstract", weight:"bold"))
#pad(left: 1.1cm, right: 1.1cm, [
  Cloud quantum computing is crucial for developing innovative quantum circuits but also presents a potential threat model when using cloud quantum computing services.
  In this scenario, the cloud quantum provider may act as an adversary by advertising the use of quantum computers to clients while using cheaper simulators to return results.
  This thesis demonstrates that it is possible to distinguish whether a quantum circuit has been executed by a simulator (possibly with noise) or a quantum computer with high accuracy.
  Three machine learning techniques are being utilized: a support vector machine, a feedforward neural net, and a convolutional neural net.
  Additionally, an adversarial attack has been used to test the resilience of the feedforward neural net.
  The results of the tests showed that the model is vulnerable to adversarial samples, reducing the model's accuracy.
  The machine learning techniques learn the noise fingerprint, and the results of this work are consistent with previous studies, indicating that it is feasible to differentiate between various quantum computers by their noise fingerprint.
  All three machine learning techniques used in this thesis can distinguish between quantum computers and simulators with an accuracy of over 99.9%.
  Even for previously unseen quantum computers and simulators, these models classify with at least 80% accuracy (the best model has at least 92% accuracy).
])

#v(40pt)

#align(center, text("Zusammenfassung", weight:"bold"))
#pad(left: 1.1cm, right: 1.1cm, [
  Cloud-Quantencomputing ist für die Entwicklung innovativer Quantenschaltungen von entscheidender Bedeutung, stellt aber auch ein potenzielles Bedrohungsmodell bei der Nutzung von Cloud-Quantencomputing-Diensten dar.
  In diesem Szenario kann der Anbieter von Cloud-Quantencomputern als Betrüger auftreten, indem er den Kunden die Nutzung von Quantencomputern anpreist jedoch tatsächlich billigere Simulatoren verwendet, um Ergebnisse zu berechnen.
  In dieser Arbeit wird gezeigt, dass es möglich ist, mit hoher Genauigkeit zu unterscheiden, ob ein Quantenschaltkreis von einem Simulator (möglicherweise mit hinzugefügtem Rauschen) oder einem Quantencomputer ausgeführt wurde.
  Es werden drei Machine Learning Techniken eingesetzt: eine Support-Vektor-Maschine, ein Feedforward Neural Net und ein Convolutional Neraul Net.
  Darüber hinaus wurde die Widerstandsfähigkeit des Feedforward Neural Nets mit Hilfe einer Adversarial Attack getestet.
  Die Ergebnisse der Tests zeigten, dass das Modell anfällig für Adversarial Samples ist, welche die Genauigkeit des Modells verringert.
  Die Machine Learning Techniken lernen den Rausch-Fingerabdruck.
  Die Ergebnisse dieser Arbeit stimmen mit früheren Studien überein, welche darauf hindeuten, dass es möglich ist, verschiedene Quantencomputer anhand ihres Rausch-Fingerabdrucks voneinander zu unterscheiden.
  Alle drei in dieser Arbeit verwendeten Machine Learning Techniken können zwischen Quantencomputern und Simulatoren mit einer Genauigkeit von über 99,9 % unterscheiden.
  Selbst bei den Modellen unbekannten Quantencomputern und Simulatoren klassifizieren diese Modelle mit einer Genauigkeit von mindestens 80 % (das beste Modell hat eine Genauigkeit von mindestens 92 %).
])

#pagebreak(weak: true)

#outline(indent: auto)

#pagebreak()

= Introduction and Motivation
Quantum computing is a rapidly growing field that is gaining attention. 
Experts expect the quantum computing market to grow from USD 866 million in 2023 to USD 4.375 million in 2030 @QuantumComputingMarket2023.
Quantum computing is especially promising in the fields of simulations, drug development, and cybersecurity @emilioCurrentStatusNext2022.
Despite these optimistic prognoses, current quantum computers are still called Noisy Intermediate-Scale Quantum (NISQ) devices due to the high error and noise rates @preskillQuantumComputingNISQ2018.
Current quantum computers (QCs) are provided as cloud-based services to the user by startups such as Rigetti @RigettiQuantumComputing2024 or IonQ @CompareQuantumSystems2024 and tech giants like IBM @IBMQuantum2024, Microsoft @AzureQuantumQuantum2024 or Amazon @CloudQuantumComputing2024.
These services are mainly aimed at academics and researchers.
As a first step, a user must register an account to use such a cloud-based quantum computer.
Afterward, the user develops the quantum circuit (e.g., in IBM's Qiskit @Qiskit2024), uploads the quantum circuit, and can choose a backend to execute the circuit on.
Next, the request gets scheduled and executed on the QC.
Finally, results are sent back to the user.
#figure(
  image("images/quantum-based-cloud-provider-trust-left-to-right.png"),
  caption: "The user is sending the quantum circuit to the cloud-based quantum computing provider and has to trust the provider that the circuit is executed on an actual quantum computer."
) <cloud-trust>
In this cloud-based scenario, the user has to trust the cloud-based quantum provider to execute the quantum circuit on the advertised quantum hardware.
An adversarial cloud provider could claim to have a quantum computer backend, but all circuits are just simulated on a classical computer.
This scenario primarily affects small circuits up to 40 qubits due to the exponential growth in dimensions, rendering larger circuits impractical for computation with classical hardware.
When utilizing a state vector for simulating a quantum circuit without any restrictions, $8 dot 2^n$ bytes are needed to store the state vector, $8$ because each amplitude can be stored as a complex float (4 bytes real and 4 bytes imaginary, single precision).
See @memory-needed-for-simulating-n-qubits for a visualization of the exponential memory growth when simulating a growing number of qubits.

#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot

    plot.plot(size: (12,6), 
      x-tick-step: 5, 
      x-ticks: (1,),
      x-label: "Number of qubits",
      x-min: 1,
      y-tick-step: none, 
      y-ticks: ((0, 0), (5, [$2^5$]), (10, [$2^10$]), (15, [$2^15$]), (20, [$2^20$]), (25, [$2^25$]), (30, [$2^30$]), (35, [$2^35$]), (40, [$2^40$]), (45, [$2^45$]), (50, [$2^50$]), (55, [$2^55$])),
      y-label: "Bytes to store state vector",
    {
      let number-of-qubits = range(1, 55)
      plot.add(domain: (1, 55), number-of-qubits.map((n) => (n, calc.log(8 * calc.pow(2, n), base: 2))))

      plot.add-hline(10, 20, 30, 40, 50, min: 1, max: 55, style: (stroke: (paint: black, dash: "dashed")))
      plot.annotate({content((50, 12), [Kilobyte])})
      plot.annotate({content((50, 22), [Megabyte])})
      plot.annotate({content((50, 32), [Gigabyte])})
      plot.annotate({content((50, 42), [Terabyte])})
      plot.annotate({content((50, 52), [Petabyte])})
    })
  }),
  caption: [Memory needed to store a state vector for 1 up to 55 qubits. The memory footprint is calculated assuming that $8 dot 2^n$ bytes are needed to store $n$ qubits.]
) <memory-needed-for-simulating-n-qubits>
The amount of memory needed for simulating a circuit depends on the simulator approach used.
For a quantum circuit with depth 27 in a 2D lattice of $7 times 7$ qubits, it was possible to simulate a circuit with only 4.5 Terabyte of RAM @pednaultParetoEfficientQuantumCircuit2020, compared to 8 Petabyte needed in previous simulation implementations @hanerPetabyteSimulation45Qubit2017.

In 2020, a research team led by scientist Jian-Wei Pan at the University of Science and Technology of China (USTC) achieved quantum supremacy using 76 photons for the Gaussian boson sampling algorithm @garistoLightBasedQuantumComputer2021.
The samples generated in the study required 200 seconds, a task estimated to take a classical supercomputer 2.5 billion years to complete, as detailed in the paper @zhongQuantumComputationalAdvantage2020.
Quantum supremacy marks the point at which quantum computers outperform classical computers in specific tasks.
The majority of circuits demonstrating quantum supremacy are inherently not directly applicable to practical computational problems.
These circuits primarily serve to exhibit quantum computational supremacy by performing specific tasks that are infeasible for classical computers within a reasonable timeframe without necessarily providing practical computational benefits @caludeRoadQuantumComputational2019.
Conversely, algorithms such as Shor's Algorithm, which have significant practical implications, especially in cryptography, demand more qubits and lower levels of quantum noise for effective implementation.
When passing a quantum circuit used for demonstrating quantum supremacy or with a high number of qubits to a cloud quantum provider, the returned results could be either from an actual quantum computer or a (randomly) fabricated distribution.
Because current quantum computers are noisy and simulating the correct result for a large circuit is infeasible, checking the result for correctness is challenging.
Therefore, these cases are out of the scope of this thesis.

However, apart from these highly specialized setups, it is still possible to simulate small quantum circuits.
As of 2023, a rough cost estimate for a 9-qubit quantum computer from Rigetti stands at \$900,000 @mechanicRigettiLaunchesNovera2023.
Conversely, simulators can execute small circuits on consumer hardware, drastically reducing the cost barrier for executing quantum computations.
For example, Amazon Braket charges between \$0.075 and \$0.275 per minute for simulator their cloud simulator service @AmazonBraketPricing.
When renting the IonQ Harmony quantum computer, Amazon Braket charges \$0.3 per task with an additional cost of \$0.01 per shot @AmazonBraketPricing.
Simulating a quantum circuit with four qubits (see @circuit-measurement-step-9) on consumer hardware took 0.2 seconds for 8000 shots when using the 'Fake_Athens' backend, which adds noise to the result.
Assuming Amazon Brakets most expensive simulator would take 1 second, this would result in a price of
$ 1/60 "minute" dot (\$0.275)/"minute" = \$0.00458. $
When executing the same quantum circuit on the IonQ Harmony quantum computer with 8000 shots, it would cost
$ \$0.3 + 8000 "shots" dot (\$0.01)/"shot" = \$80.3. $
In this specific example, executing the circuit on the quantum computer would cost more than 17,000 times as much. 
Of course, these numbers only hold for such tiny circuits combined with a high number of shots.
Using more qubits and gates increases the simulator's hardware requirements and computation time.
Overall, the price margin for Amazon Braket's services is huge for small quantum circuits, which take a short amount of time for a simulator but have fixed costs when running on a quantum computer.
This cost consideration underscores the significance of the threat posed by cloud quantum providers employing simulators in scenarios where the users are unaware of this substitution.
Therefore, mitigating strategies should be devised to ensure transparency and trust in quantum cloud services to safeguard against potential security breaches and ensure the integrity of quantum computations.

This work provides a machine learning-based approach that allows the users of cloud-based QCs to verify with high certainty that their quantum circuit has been executed on a quantum computer and not simulated on a classical computer.
Additionally, in order to test the robustness of the feedforward neural net, its resilience to the Fast Gradient Sign Method, an adversarial attack, is evaluated.

== Related Work <related-work>
Multiple approaches for fingerprinting different quantum computers already exist.
After collecting data in different fashions, these approaches create a fingerprint that is ideally unique for different quantum hardware.
Therefore, such fingerprint information makes it possible to differentiate between quantum computers.
One such work has shown that generating a unique hardware fingerprint based on qubit frequencies is possible.
The fingerprint is based on quantum computer calibration data, which was made available by the cloud provider @smithFastFingerprintingCloudbased2022.
A different research group has developed a Quantum Physically Unclonable Function (QuPUF).
By utilizing the QuPUF, it is possible to identify the quantum computer the QuPUF was executed on @phalakQuantumPUFSecurity2021.
Another approach uses a tomography-based fingerprinting method based on crosstalk-induced errors @miShortPaperDevice2021.

Martina et al.'s paper "Noise fingerprints in quantum computers: Machine learning software tools" distinguishes which QC a specific quantum circuit has been executed by learning the error fingerprint using a support vector machine @martinaLearningNoiseFingerprint2022.
Creating a dataset containing measurements from quantum circuits executed on different quantum computers is challenging due to the high cost of executing a circuit on a quantum computer many times.
Additionally, a circuit must be designed in order to ideally capture the noise generated by a quantum computer.
Therefore, creating such a dataset is out of the scope of this thesis.
As a result, the dataset containing quantum computer measurements and the circuits provided in @martinaLearningQuantumNoiseFingerprint2023 have been used in this thesis.

This thesis takes a similar approach to "Noise fingerprints in quantum computers: Machine learning software tools" by Martina et al. @martinaLearningNoiseFingerprint2022 and utilizes the same quantum circuits.
However, instead of differentiating between various quantum computers, this thesis creates machine learning models that distinguish whether a quantum circuit was executed by a QC or a simulator on a classical computer.

== Structure
@terms-and-definitions gives a short overview of essential concepts of quantum computing and machine learning used in this thesis.
In @approach, an explanation for the dataset based on the circuit measurements is provided.
These are used to train different machine learning algorithms in order to differentiate whether a quantum circuit has been executed by a quantum computer or simulated by a classical computer.
Additionally, a white-box adversarial attack is performed.
After that, in @evaluation, the accuracies of the different machine learning algorithms are compared, and the limitations of this work are discussed, specifically concerning the white-box adversarial attack.
@future-work-and-conclusion points out possible areas for further research and ends wih a short conclusion.

#pagebreak(weak: true)


= Terms and Definitions <terms-and-definitions>
This section provides a concise overview of theoretical concepts central to this thesis.
It introduces the core fundamentals of quantum computing, which utilizes quantum mechanics for computational purposes.
In the second part, three different machine learning approaches, support vector machine, feedforward neural net, and convolutional neural net, are detailed, highlighting their unique attributes and applicability, motivating why these different approaches have been chosen. 
Additionally, the section delves into the basics of adversarial machine learning, focusing on the fast gradient sign method, which illustrates vulnerabilities in machine learning models by intentionally causing them to misclassify specially prepared samples.

== Quantum Computing
Quantum computing emerges as a revolutionary approach to computation, leveraging the principles of quantum mechanics to significantly enhance computational capabilities beyond the scope of classical computing.
This advanced computing paradigm utilizes fundamental quantum mechanical phenomena, such as superposition and entanglement, enabling quantum computers to surpass traditional computers in solving very specific problems @garistoLightBasedQuantumComputer2021 @zhongQuantumComputationalAdvantage2020.
At the core of quantum computing lies the qubit, a quantum version of the classical binary bit.
Quantum computers, essentially an assembly of one or more qubits, execute quantum algorithms through operations on these qubits, similar to how classical bits function in traditional computing.
These operations are executed using quantum gates, manipulating qubit states within a quantum circuit.
The qubits are measured at the end of the quantum circuit to extract computation results, revealing the outcomes of quantum algorithms @nielsenQuantumComputationQuantum2010.

=== The qubit
A quantum computer leverages quantum bits (qubits).
Qubits have two basis states, which are associated with the vectors
$ |0 angle.r = vec(1, 0) quad |1 angle.r = vec(0, 1). $
The notation with '$| med angle.r$' is called Dirac notation.
Classical bits are either 0 or 1.
Conversely, qubits can be in states other than $|0 angle.r$ and $|1 angle.r$.
A superposition is a linear combination of states, as in @eq1.
$ |psi angle.r = alpha|0 angle.r + beta|1 angle.r $<eq1>
In @eq1, $alpha$ and $beta$ are complex values describing probability amplitudes.
The amplitudes must satisfy the normalization condition $ |alpha|^2 + |beta|^2 = 1. $

=== Quantum circuits
It is possible to solve a specific selection of problems with reduced time and space complexity by leveraging quantum properties.
Examples of such a quantum algorithm are Shor's algorithm @shorPolynomialTimeAlgorithmsPrime1997 and Grover's algorithm @groverFastQuantumMechanical1996.
These quantum algorithms, also called quantum circuits, are executed from left to right.
Each line in the circuit represents one qubit.
#figure(
  image("images/generic-circuit.svg"),
  caption: [Quantum circuit with one qubit. Circuits get executed from left to right. Therefore, the two arbitrary gates are applied to the qubit before the qubit gets measured at the end.]
)
In equations, however, gates are applied from right to left.
The circuits used in this thesis consist of the Pauli-X gate, the Hadamard gate, the Controlled not gate (CNOT), and the Toffoli gate.
The action each of these gates perform on qubits can be described as a unitary matrix.
The matrix for the Pauli-X gate can be written as
$ X = mat(0, 1; 1, 0). $
Applying the gate to a single qubit performs a bit flip:
$ X|0 angle.r = mat(0, 1; 1, 0) vec(1, 0) = vec(0,1) = |1 angle.r $
Therefore, it is the equivalent of the classical NOT gate.
The circuit symbol for the Pauli-X gate looks like @pauli-x-gate.
#figure(
  align(center, image("images/gates/pauli-x.svg", width: 13%)),
  caption: [Circuit symbol for the Pauli-X gate.]
) <pauli-x-gate>

The matrix for the Hadamard gate can be written as
$ H = 1/sqrt(2) mat(1, 1; 1, -1). $
After applying the Hadamard gate to a qubit, the qubit is in a superposition of its basis states.
If the initial state of the qubit was $|0 angle.r$, the resulting state after applying the Hadamard gate will be
$ H |0 angle.r = 1/sqrt(2) mat(1, 1; 1, -1) vec(1,0) =  (|0 angle.r + |1 angle.r)/sqrt(2)  $
which is an equal superposition of the $|0 angle.r$ and $|1 angle.r$ states.
When measuring a qubit in this state, the measurement returns $0$ or $1$ each $50%$ of the time.
The circuit symbol in @hadamard-gate depicts the Hadamard gate.
#figure(
  align(center, image("images/gates/hadamard.svg", width: 13%)),
  caption: [Circuit symbol for the Hadamard gate.]
) <hadamard-gate>

The CNOT gate is the first gate in this section which acts on two qubits.
In case the control qubit (first qubit) is in state $|1 angle.r$, it applies the Pauli-X gate to the target qubit (second qubit).
This can be seen in the matrix of the CNOT gate. It contains the Pauli-X matrix in the lower right corner:
$ "CNOT" = mat(1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 0, 1; 0, 0, 1, 0). $
The circuit symbol for the CNOT gate looks like @cnot-gate.
#figure(
  align(center, image("images/gates/cnot.svg", width: 11%)),
  caption: [Circuit symbol for the CNOT gate. The upper qubit is the control qubit; the lower qubit is the target qubit.]
) <cnot-gate>


Additionally, the circuits in this thesis use the Toffoli gate, which is similar to the CNOT gate.
It has two control qubits and flips the target qubit only in case both control qubits are in state $|1 angle.r$.
The circuit symbol for the Toffoli gate looks like @ccx-gate.
#figure(
  align(center, image("images/gates/ccx.svg", width: 9%)),
  caption: [Circuit symbol for the Toffoli gate. Both upper qubits are the control qubits and the lowest qubit is the target qubit.]
) <ccx-gate>

By utilizing the Hadamard gate and the CNOT gate together, it is possible to entangle two qubits, see @enanglement-circuit.
#figure(
  align(center, image("images/entanglement-circuit.svg", width: 25%)),
  caption: [Circuit for entangling two qubits.]
) <enanglement-circuit>

Entanglement is one of the cornerstone principles of quantum mechanics, enabling phenomena with no classical counterpart.
One of the simplest examples of quantum entanglement is illustrated by the Bell state, a quantum state of two qubits representing a maximally entangled pair.
The Bell stat can be mathematically described as
$ |psi angle.r = (|00 angle.r + |11 angle.r)/sqrt(2). $
If the first qubit returns $|1 angle.r$ when measured, the second qubit has to collapse to $|1 angle.r$ as well. The same holds true for $| 0 angle.r$.
As a result, measurements of $|01 angle.r$ and $|10 angle.r$ are impossible for two qubits in the Bell state.
//TODO: add more references!

=== Measurements and Shots
In quantum computing, measuring a qubit yields a binary outcome: either a $0$ (for $|0 angle.r$) or a $1$ (for $|1 angle.r$).
This measurement process is a critical operation that leads to the collapse of the qubit's wave function, situating it into a definitive state of either $|0 angle.r$ or $|1 angle.r$, depending on the measured value.
#figure(
  align(center, image("images/gates/measurement.svg", width: 15%)),
  caption: [Circuit symbol for a qubit measurement.]
) <measurement-symbol-circuit>
This collapse is a direct consequence of the quantum mechanical principle of wave function collapse, where measurement forces a quantum system to 'choose' a state from among the probabilities described by its wave function prior to measurement.

Additionally, the concept of shots in quantum computing refers to the number of times a quantum algorithm is executed and measured.
The rationale behind multiple shots is to compile a statistical distribution of outcomes, which is instrumental in approximating the quantum state prior to measurement.
This statistical approach is crucial due to the probabilistic nature of quantum measurements, where repeated executions help accurately estimate the likelihood of each possible outcome, thereby providing insight into the quantum system's behavior before measurement @nielsenQuantumComputationQuantum2010.

=== Quantum computers
Different approaches exist for building physical quantum computers.
QCs built by IBM are based on superconducting qubit technology @QuantumSystemInformation.
Other architectures include trapped ions, photonics, and nuclear magnetic resonance @laddQuantumComputers2010.
One of the main issues for today's NISQ devices is the presence of noise, drastically reducing the accuracy with which the QCs compute, hindering the implementation of larger quantum circuits.
Current quantum chips mainly suffer from decoherence, gate errors, readout errors, and crosstalk.
For a qubit, the decoherence time refers to how long the qubit can contain information.
Decoherence can occur, for example, when a qubit interacts with the environment.
Gate error refers to the malfunction of a gate, causing the qubit to deviate from its intended state.
These errors can occur due to imperfections in the physical system that implements the gate, environmental noise, or inaccuracies in the control mechanisms.
Readout errors occur during the qubits' measurement process, resulting in an incorrect measurement.
When quantum computers are constructed from multiple qubits, unwanted interactions between these qubits are called crosstalk.

== Machine Learning
This thesis compares classifiers based on three different classical machine learning techniques.
These machine learning techniques are support vector machine, feedforward neural net, and convolutional neural net.
The support vector machine is one of the standard classification algorithms.
It tries to separate data points into two classes by dividing them with a hyperplane.
The feedforward neural net is based on the notion that combining multiple simple perceptrons into layers results in a complex model capable of handling nonlinear relationships between inputs and outputs.
Combining these layers enables the model to effectively perform classification by capturing the underlying patterns in the data.
The convolutional neural net is incredibly potent when recognizing sequential data due to filters sliding over the data and recognizing low-level patterns.
After these filters, a feedforward neural net is appended to perform the classification.

=== Support Vector Machine
A support vector machine (SVM) is a machine learning algorithm primarily used for classification and regression tasks.
Therefore, an SVM is utilized in this thesis to classify whether a quantum circuit has been executed on a quantum computer or a simulator based on the measurement results.
Additionally, an SVM has already been used to successfully fingerprint quantum computers @martinaLearningNoiseFingerprint2022.
The SVM operates by constructing an optimal hyperplane in a high-dimensional space that separates different classes of data points.
This optimal hyperplane is determined by the data points, referred to as support vectors, that lie closest to the decision boundary, see @svm.
The hyperplane divides the input features into two distinct classes.
Its position and orientation are determined to maximize the distance between the hyperplane and the nearest data point from either class.
This approach ensures the best possible separation between classes and enhances the algorithm's generalization capabilities.
However, real-world data is often not linearly separable.
To overcome this limitation, SVMs employ a technique known as the kernel trick.
A linear decision boundary can be found by mapping the input features into a higher dimensional feature space.
The kernel trick allows SVMs to construct a nonlinear decision boundary in the input space, thereby enabling the classification of complex datasets.
As a result, SVMs are computationally efficient and particularly suited for handling high-dimensional data.
See @cristianiniIntroductionSupportVector2000 for additional details.

#figure(
  cetz.canvas(length: 1cm, {
  import cetz.draw: *
  import cetz.plot
    plot.plot(
      size: (5,4),
      x-tick-step: none,
      y-tick-step: none,
      x-min: 0,
      x-max: 10,
      y-min: 0,
      y-max: 10,
      x-label: [$x_1$],
      y-label: [$x_2$],
      legend: "legend.north-east",
    {
      plot.add(domain: (0, 10), x => x + 1, label: "Hyperplane", style: (stroke: black))
      plot.add(domain: (0, 10), x => x + 3, label: "Margin", style: (stroke: (paint: blue, dash: "dashed")))
      plot.add(domain: (0, 10), x => x - 1, style: (stroke: (paint: blue, dash: "dashed")))

      let points_above = ((1, 4), (4, 7), (2, 8), (3, 7), (2, 6), (4, 7), (5, 9), (4, 9.5), (6, 9.5))
      for (p_1, p_2) in points_above {
        plot.add(((p_1, p_2),), mark: "o", mark-style: (stroke: red, fill: red), mark-size: .2)
      }

      let points_below = ((2, 1), (7, 6), (5, 4), (2.5, 0.5), (4, 1), (3, 1.2), (5, 2), (6, 4), (6, 1), (7, 3), (8, 1), (9, 5), (9.5, 2))
      for (p_1, p_2) in points_below {
        plot.add(((p_1, p_2),), mark: "x", mark-style: (stroke: green, fill: green), mark-size: .2)
      }
      //TODO: ok, dass supportvectoren auf der linie liegen? (und nicht abgegrenzt werden?)
      // Support Vectors, add circle around (where touching upper or lower margins).
      let support_vectors = ((2, 1), (7, 6), (5, 4), (1, 4), (4, 7))
      for (p_1, p_2) in support_vectors {
        plot.add(((p_1, p_2),), mark: "o", mark-style: (stroke: orange, fill: none), mark-size: .3)
      }
  })
}),
caption: [An SVM model demonstrates the separation of two classes of data (red dots and green crosses) with a linear hyperplane in 2D space based on features $x_1$ and $x_2$. The blue dashed lines represent the margins, and the points on these margins (highlighted in yellow) are the support vectors, which are pivotal in defining the hyperplane and its orientation.]
) <svm>

=== Feedforward Neural Network
A feedforward neural network (FNN) is an artificial neural network commonly used for classification tasks, regression, and pattern recognition.
It passes input data through a series of interconnected layers of nodes, known as neurons or perceptrons, where each neuron performs a weighted sum of its inputs combined with a bias and applies an activation function to produce an output.
This can mathematically be written as 
$ y = f(sum_(i=1)^(n) w_i x_i + b) $ <perceptron-math>
where $y$ denotes the perceptron output, $bold(x)$ is the input vector, $f$ is the activation function, $w_i$ is the weight associated with input $x_i$, and $b$ is the bias term.
Each neural network consists of multiple neurons, which are grouped into layers.
The first layer, the input layer, receives the initial input data.
After the input layer, subsequent layers are known as hidden layers, where complex transformations of the input data occur.
Finally, the results are taken from the last layer, the output layer, which provides the network's final output.
See @feedforward-net for a visualization.
The hidden layers within the network allow for the learning of nonlinear relationships, enabling the system to understand complex patterns and dependencies in the data.
Due to its flexible design, the feedforward neural network can be adapted to various use cases.
This adaptability and robust learning capability make the network a good fit for being used as a classifier in this thesis, as it can efficiently handle the complexity and variability of the provided measurement data. 

#figure(
  image("images/feedforward-neural-network.png", height: 25%),
  caption: [Feedforward neural net consisting of an input, hidden, and output layer. When evaluating, the value for each neuron gets calculated by @perceptron-math.]
) <feedforward-net>

During training, the network adjusts the weights of connections between neurons to minimize the loss function, quantifying the difference between predicted outputs and actual targets.
This process often involves techniques such as backpropagation and gradient descent to iteratively reduce the loss.
By doing so, FNNs can learn complex patterns and relationships within data, enabling them to perform a wide range of tasks with high accuracy.
For additional information, see @russellArtificialIntelligenceModern2021.

=== Convolutional Neural Network
A convolutional neural network (CNN) is a specialized artificial neural network employing convolutional layers that automatically learn hierarchical patterns and features from inputs.
These convolutional layers consist of filters sliding across the input, performing convolutions to extract local features.
In this thesis, sequential data (an array of measurements) should be classified.
Therefore, the CNN has been chosen due to its ability to process time series and sequential data with one dimensional filters.
These filters detect low-level patterns in the sequential data while subsequent layers combine these features to recognize higher-level patterns.
The CNN in this thesis consists of convolutional, max pooling, and fully connected layers.
Pooling layers downsample the feature maps, reducing the spatial dimensions of the data and increasing computational efficiency.
Fully connected layers process the extracted features to make the classification.

#figure(
  image("images/typical-cnn-architecture.png"),
  caption: [Typical architecture for a CNN. Source: @kumarDifferentTypesCNN2023]
)

During training, CNNs adjust the parameters of the filters through backpropagation, optimizing them to minimize the difference between predicted outputs and ground truth labels.
This process enables CNNs to effectively learn and generalize from large datasets.
For additional information, see @russellArtificialIntelligenceModern2021.

=== Adversarial Machine Learning using Fast Gradient Sign Method <terms-and-definitions-fgsm>
Machine learning is employed across domains, highlighting its versatility.
However, adversarial machine learning emerges as a critical area of research, focusing on investigating how specially crafted inputs can undermine machine learning models.
These adversarial inputs are designed to trick the model into making errors, revealing potential vulnerabilities and guiding the development of defensive strategies to enhance model robustness.
Various machine learning techniques are tailored to address particular problem sets based on the premise that the training and test data share the same statistical distribution.
However, in practical situations, this belief can prove to be misguided.
In particular, when users intentionally submit erroneous data, it can considerably impact the reliability and effectiveness of machine learning models.
It is possible to attack a neural network in the training or the inference phase @josephAdversarialMachineLearning2017.
In this thesis, only the iinference phase is being targeted.
One simple and fast method of generating adversarial examples is called 
Fast Gradient Sign Method (FGSM), which is a white-box adversarial attack.
White-box adversarial attacks on neural networks operate under the premise that the attacker has complete knowledge of the model's architecture and weights.
This method, introduced by Ian Goodfellow et al. @goodfellowExplainingHarnessingAdversarial2015, operates under the premise that by applying a small, carefully calculated change in the direction of the gradient of the loss with respect to the input data, one can generate a new adversarial sample which is almost indistinguishable from the original but is misclassified by the neural network.
The perturbation is determined by taking the sign of the gradient of the loss with respect to the input features and then multiplying it by a small scalar $epsilon$ to ensure the modification is subtle.
Mathematically, this results in the following:
$ "adversarial_sample" = bold(x) + epsilon dot "sign"(nabla_bold(x) J(bold(theta), bold(x), y)) $ <adversarial-sample-expression>
where $bold(x)$ is the original input sample and $y$ is the according original input label.
$J$ is the loss function used to train the machine learning model, and $bold(theta)$ is the set of model parameters.
An example of how the FGSM attack was used to generate adversarial samples for an image classifier can be seen in @adversarial-example-panda.

#figure(
  image("images/adversarial-example-panda.png"),
  caption: [Initially, the image $bold(x)$ gets correctly classified as "panda" with a confidence of $57.7%$. After multiplying noise generated by the FGSM attack, with $epsilon$ of $0.007$ and adding this perturbation to the original image, the altered image gets classified as "gibbon" with a confidence of $99.3%$.
  #linebreak()
  Source: @goodfellowExplainingHarnessingAdversarial2015.]
) <adversarial-example-panda>

The FGSM is designed to be fast and computationally efficient, making it a powerful tool for analyzing the robustness of neural networks and a significant concern for applications reliant on machine learning for security-sensitive tasks.

#pagebreak(weak: true)

= Approach <approach>
The methods mentioned in @related-work were used for fingerprinting quantum computers.
In contrast, this thesis aims to provide a mechanism for distinguishing between simulators (possibly with a noise model) and quantum computers for one specific circuit; see @circuit for information about the circuit.
In order to achieve this, only the measurement results of the quantum circuit are considered.
It is impossible to prove on which backend a quantum algorithm has been executed based on the measurement results due to the inherent noise of current NISQ devices and the statistical nature of quantum computation.
Therefore, a machine learning based approach has been chosen because it does not require quantum noise modeling or controlling the quantum circuit with time-dependent pulses @mullerInformationTheoreticalLimits2022.
This aspect makes using machine learning techniques an appropriate approach for the task at hand, providing a "black box" capable of classifying based on the outcomes of measurements without delving into the complex specifics of the processes involved.
This thesis only aims to classify based on noise whether the circuit has been executed on a quantum or a simulator backend, but not to reconstruct the noise.

As a threat model, we assume the adversary cloud provider is interested in making a profit and therefore accepts circuits with one up to 35 qubits, needing up to approximately 256 GB of RAM (see @memory-needed-for-simulating-n-qubits for visualization).
Allowing for quantum circuits with more qubits would require exponentially more RAM and increased amounts of computing power, which would, in turn, reduce profit.
When a user sends a quantum circuit to a quantum cloud provider for execution, the user cannot easily validate that the circuit runs on the advertised quantum hardware.
This is due to the fact that the cloud provider can shedule the circuit on any hardware without giving notice to the client.
This is an inherent problem in cloud infrastructure that is not limited to quantum computing.
On the other hand, the client cannot access the quantum hardware directly and, therefore, cannot enforce that the circuit is executed on the correct backend.
In this scenario, we assume that the adversarial quantum provider does not tamper with the circuit provided by the client.
Therefore, this thesis provides a way of determining whether an actual quantum backend or a simulator was used for executing a specific circuit.
The circuit gets executed multiple times and measured at different points for each run in order to be able to consistently classify the type of backend used.
The following sections provide more information on the circuits used, the dataset preparation, and the three machine learning models.

== Data for Training
As previously mentioned in @related-work, the decision to utilize an existing quantum computer measurement dataset was based on several factors.
First and foremost, generating a dataset that includes measurements from various quantum computers can be costly, requiring multiple circuit executions.
Additionally, designing a circuit that accurately captures quantum computer-generated noise adds another layer of complexity.
For these reasons, creating a new dataset was beyond the scope of this thesis.
For these reasons, the creation of a new dataset was beyond the scope of this thesis.
This thesis utilized the dataset and circuits made available by @martinaLearningQuantumNoiseFingerprint2023 as a practical solution.
The QC measurement dataset was obtained by running the circuit described in @circuit on seven different IBM quantum machines (Athens, Santiago, Casablanca, Yorktown, Bogota, Quito, Lima).
The quantum chips vary in connectivity between qubits, from linear topology to a star topology @martinaLearningQuantumNoiseFingerprint2023.
Each quantum machine has different noise parameters for its qubits and quantum gates.
The noise fingerprint learned by the machine learning model is based on these differences.
Each circuit measurement in the dataset can be traced back to the quantum computer on which it was executed.
The simulation data for this work was created by simulating the identical quantum circuits from @martinaLearningQuantumNoiseFingerprint2023, both with and without noise.
The simulators provided by the Qiskit SDK @Qiskit2024 were used.
More details on the measurements generated by simulators can be found in @executions-on-simulator.

=== Circuit <circuit>
//The circuits used in this thesis are taken from Martina et al. in _Noise Fingerprints in Quantum Computers_, 2022. 
The circuit designs implemented in this thesis are derived from the work of Martina et al., as documented in their 2022 publication, "Noise Fingerprints in Quantum Computers" @martinaLearningNoiseFingerprint2022.//TODO: correct citation?
The different circuits are generated by the algorithm described in @circuit-algorithm.
The idea behind the quantum circuit is to simulate quantum transport dynamics in a quantum computer.
A quantum particle is initiated in state $|0000 angle.r$ and "flows" through the circuit via the influence of various quantum gates, including CNOT and Toffoli gates @martinaLearningQuantumNoiseFingerprint2023.
After the first two Hadamard gates and the CNOT gate, qubits $q_0$ and $q_2$ are entangled in the bell state.
Qubits $q_2$ and $q_3$ are used to track the particle's position.
They can return binary pairs of $00_2$, $01_2$, $10_2$, and $11_2$ first bit corresponding to $q_2$ and second bit to $q_3$ when measured. //TODO: use 00_2 or (0,0)?
Qubits $q_0$ and $q_1$ are ancilla qubits, with the only purpose of controlling the other qubits.

#algorithm(
  caption: [Generation of quantum circuits for different measurement steps. Code for circuit generation adapted from Martina et al. in _Noise Fingerprints in Quantum Computers_, 2022 @martinaLearningNoiseFingerprint2022], //TODO: correctly cited?
  pseudocode(
    line-numbering: false,
    [*Ensure:* $|0 angle.r_i forall i in 0,...,3$], ind,
      [*for* step from 0 to $k$ *do* #comment[$k$ is the measurement step. (e.g. $k=1$ creates circuit in @circuit-measurement-step-1)]], ind, 
        [*if* $"step" mod 3 = 0$ *then*], ind,
          [$0 arrow.l H$ #comment[Hadamard gate on the $0^"th"$ qubit]],
          [$1 arrow.l H$],
          [$"CNOT"(0 arrow.r 2)$ #comment[Controlled NOT gate on the $2^"nd"$ qubit conditioned on the qubit 0]], ded,
        [*else if* $"step" mod 3 = 1$ *then*], ind,
          [$"CNOT"(1 arrow.r 3)$],
          [$0 arrow.l X$ #comment[X gate on the $0^"th"$ qubit]], ded,
        [*else*], ind,
          [$1 arrow.l X$],
          [$"Toffoli"(0,1 arrow.r 2)$ #comment[Toffoli gate on the $2^"nd"$ qubit conditioned on the qubits 0,1]], ded,
        [*end if*], ded,
      [*end for*],
      [Measure(2) #comment[Projective measurement of the $2^"nd"$ qubit]], 
      [Measure(3)],
      [*return* 8000 shots from the measurements],
  )
) <circuit-algorithm>

In order to measure the circuit at different points, @circuit-algorithm is executed with $k=1$ up to $k=9$, which results in 9 measurement points for this circuit.
The circuit corresponding to the first measurement step can be seen in @circuit-measurement-step-1. 
The entire circuit, corresponding to measurement step 9, is depicted in @circuit-measurement-step-9.
All circuits for measurement steps in between are in the appendix (see @appendix).
Measurements are performed by applying the Pauli Z operator on qubits $q_2$ and $q_3$ after each execution, see the last lines of @circuit-algorithm.
Due to the wavefunction collapse, the circuit has to be regenerated, re-executed, and measured for each measurement step $k$.
Consequently, this approach does not employ repeated measurements as utilized in a quantum monitoring protocol or within the framework of Zeno quantum dynamics @gherardiniErgodicityRandomlyPerturbed2017 @fischerObservationQuantumZeno2001 @schaferExperimentalRealizationQuantum2014.
For a single measurement step with $k=1$, all four qubits ($q_0$, $q_1$, $q_2$, and $q_3$) are each initialized in state $|0 angle.r$.
Measuring the circuit in this state would result in $00_2$.
Upon initialization, two Hadamard gates are applied to qubits $q_0$ and $q_1$, as documented by @circuit-measurement-step-1.
Following this, a CNOT gate operation is executed with $q_0$ as controll qubit, operating on $q_2$.
Subsequently, the measurement of qubit $q_2$ yields a binary outcome of 0 or 1 with equal probability, reflecting a 50% chance for each outcome, while the measurement of $q_3$ still returns 0.
Of course, these results will only occur under ideal circumstances.
On current NISQ devices, noise falsifies these measurement outcomes.
The goal of the approach in this thesis is to make use of this noise to distinguish between quantum computers and simulators based on their noise profile.
Each circuit run has been performed with 8000 shots.
The data gathered from measuring one circuit run at 9 different steps with 8000 shots look like @measurement-data-table.

#figure(
  image("images/walker-step-1.svg", height: 20%),
  caption: "Circuit which corresponds to measurement step 1."
) <circuit-measurement-step-1>
#v(10pt)
#figure(
  image("images/walker-step-9.svg"),
  caption: "Circuit which corresponds to measurement step 9. The circuit consists of four qubits; only the lower two qubits are measured at the end. Grey separators mark points at which measurements can take place."
) <circuit-measurement-step-9>
#v(10pt)

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: horizon,
    [*Shot*], [*Step 1*], [*Step 2*], [*Step 3*], [*...*], [*Step 9*],
    [1], [$10_2$], [$00_2$], [$11_2$], [...], [$00_2$],
    [2], [$11_2$], [$01_2$], [$10_2$], [...], [$11_2$],
    [...], [...], [...], [...], [...], [...],
    [8000], [$01_2$], [$00_2$], [$00_2$], [...], [$10_2$]
  ), 
  caption: "Measurement examples for one run with 8000 shots. The table contains data for all measurement steps from one up to measurement step 9. 250 measurement tables exist for each quantum computer and simulator used in this thesis."
) <measurement-data-table>

=== Executions on Simulator <executions-on-simulator>
Seven different Qiskit simulators are utilized to obtain the simulated data.
Only one backend calculates a noise-free result because different simulator implementations without noise deliver similar results.
In order to obtain a comparable order of magnitude of simulated data to that of QC-generated data, six additional simulators with noise are used.
All six backends utilize a different noise model based on calibration data collected from real IBM quantum computers @Fake_provider.
The following fake backends were used: Fake_Vigo, Fake_Athens, Fake_Santiago, Fake_Lima, Fake_Belem, and Fake_Cairo.
Three of these fake backends are based on configurations of quantum computers, which were used for creating training data to account for an adversarial cloud provider trying to mimic some specific quantum computer.
The noise introduced in these simulators accumulates from different factors.
The probability for a readout error for each simulator is visualized in @simulator-readout-error.
These errors vary even within the same simulator for different qubits.
#figure(
 cetz.canvas({
  import cetz.chart

  let simulator_readout_error_data = (
    ([0],0.010099999999999998,0.04139999999999999,0.008499999999999952,0.026100000000000012,0.013299999999999979,0.07509999999999994),
    ([1],0.011700000000000044,0.03200000000000003,0.007299999999999973,0.020000000000000018,0.014399999999999968,0.022499999999999964),
    ([2],0.02429999999999999,0.02400000000000002,0.007900000000000018,0.016599999999999948,0.018000000000000016,0.014599999999999946),
    ([3],0.01529999999999998,0.03400000000000003,0.007099999999999995,0.0515000000000001,0.015600000000000058,0.021500000000000075),
    ([4],0.02190000000000003,0.02059999999999995,0.012199999999999989,0.057499999999999996,0.009600000000000053,0.033299999999999996)
  )

  cetz.draw.set-style(legend: (fill: white))
  chart.barchart(mode: "clustered",
                y-label: [Qubit],
                x-label: [Probability for readout error],
                size: (10, 10),
                label-key: 0,
                value-key: (..range(1, 7)),
                bar-width: 1,
                x-tick-step: 0.01,
                bar-style: cetz.palette.new(colors: (rgb("#41bfaa"), rgb("#466eb4"), rgb("#00a0e1"), rgb("#e6a532"), rgb("#d7642c"), rgb("#af4b91"))),
                simulator_readout_error_data,
                labels: ([Fake_Athens], [Fake_Belem], [Fake_Cairo], [Fake_Lima], [Fake_Santiago], [Fake_Vigo]),
                legend: "legend.east")
}),
    caption: [Readout error rates for different simulators at their respective qubits. The Cairo simulator has calibration data for 27 qubits, but only 5 are shown to be able to compare the different simulators.]
) <simulator-readout-error>

Each gate has its own error probabilities as well.
The error rates of the CNOT gate for each simulator are listed in @simulator-cnot-error-rate.

#figure(
 cetz.canvas({
  import cetz.chart

  let simulator_cx_gate_error = (
  ([Fake_Athens],0.011112942844963669),
  ([Fake_Belem],0.016558485595031758),
  ([Fake_Cairo],0.025727626602790654),
  ([Fake_Lima],0.008339674869236618),
  ([Fake_Santiago],0.006299998381426697),
  ([Fake_Vigo],0.012012477900732316),
  )

  cetz.draw.set-style(legend: (fill: white))
  chart.barchart(mode: "basic",
                y-label: [Simulator],
                x-label: [Probability for CNOT gate error],
                size: (10, 5),
                label-key: 0,
                value-key: 1,
                x-decimals: 3,
                x-tick-step: 0.005,
                bar-style: cetz.palette.new(colors: (rgb("#41bfaa"), rgb("#466eb4"), rgb("#00a0e1"), rgb("#e6a532"), rgb("#d7642c"), rgb("#af4b91"))),
                simulator_cx_gate_error,
                )
}),
    caption: [Error rates for the CNOT gate in different simulators. Qubit $q_0$ is the control, and $q_1$ is the target qubit for the error rates.]
) <simulator-cnot-error-rate>

All these different errors accumulate when simulating a quantum circuit.
Since these error rates are based on calibration data of actual quantum computers, the overall noise model is quite complex but within the error range of real quantum computers.

== Machine Learning Approaches <machine-learning-approaches>
Machine learning is the preferred approach for distinguishing between simulators and quantum computers primarily because it does not necessitate quantum noise modeling or controlling the quantum circuit with time-dependent pulses @mullerInformationTheoreticalLimits2022.
This characteristic makes machine learning approaches well suited for this task, offering a "black box" model that can effectively classify based on measurement results without intricate details of the underlying processes.
Machine learning has already been successfully utilized to analyze quantum systems @youssryQuantumNoiseSpectroscopy2020 and to efficiently learn quantum noise @harperEfficientLearningQuantum2020.

The three machine learning methods used in this thesis are used as classifiers
$ "Classifier" f: X -> C $
where $f$ is the machine learning method used.
The output $C$ consists of two different classes:
$ C = {0, 1} = {`"Quantum Computer"`, `"Simulator"`} $
The input data $X$ has been preprocessed to contain the probability distributions per step for the four possible measurement result values ($00_2, 01_2, 10_2, 11_2$).
In the following, especially for the example, we will use the corresponding decimal numbers instead to improve readability ($0$, $1$, $2$, $3$).
The following describes how the input data, represented by $X$, is prepared.
Three variables affect the input data: the number of shots taken, denoted by $s$ (in this thesis, $s = 8000$), the measurement step, denoted by $k$ (ranging from 1 to 9), and the window size $w in {t in NN | s mod t = 0}$ ($w$ is a positive integer that evenly divides $s$).
The measurement step $k$ corresponds with the measurements taken on the $k^"th"$ circuit (for $k=1$, see @circuit-measurement-step-1, up to @circuit-measurement-step-9 for $k=9$).
Initially, the preliminary input data consists of a matrix $M$ containing all measurements at specific measurement steps (for one quantum computer/simulator with all measurement steps from 1 up to $k$ performed).
The matrix row accounts for the shots and the column for the measurement step $k$.
Therefore, the matrix $M$ has dimension $s times k$.
The window size $w$ defines how many rows of $M$ get aggregated into one row.
Aggregation is performed by counting how often each value of $m_(i,j)$ occurs in $w$ rows.
The resulting matrix $D$ has dimension $s/w times k$.
Elements in $D$ are ordered tuples consisting of four elements:
$ d_(i,j) = (c_1, c_2, c_3, c_4) $
where $c_q$ represents, how often the measurement result $q$ has been counted.
$ "For" d_(i,j) in.rev c_q = sum_(l = i)^(i + w) bb(1)_q (m_(l,j)) $
where $bb(1)_q$ is the indicatior function with $bb(1)_q (n) = 1$ for $n = q$ and $bb(1)_q (n) = 0$ for $n eq.not q$.
Afterwards, every value in $D$ gets divided by $w$ for normalization.
By normalizing, all input values are kept between 0 and 1, which improves the learning process for the machine learning techniques.
$ d_(i,j) = (c_1/w, c_2/w, c_3/w, c_4/w) $
As the last step, each row in the matrix $D$ gets converted into an ordered tuple and added to $X$, the set of inputs:
$ X = {(d_(i,1), d_(i,2), dots , d_(i,k)) | 1 <= i <= s} $
Therefore, $X$ is a set of ordered tuples, each consisting of 1 up to 9 ordered tuples with four values each.

The following example with $s = 6$ and $k = 2$ depicts the complete conversion from initial measurement data ($M$) to the input data for the classifier ($X$):
$ M = mat(1, 2; 1, 1; 3, 3; 1, 0; 1, 2; 1, 1) $
With $w = 3$, we get: (aggregation and normalization in one step)
$ D = mat((0, 2/3, 0, 1/3), (0, 1/3, 1/3, 1/3); (0, 1, 0, 0), (1/3, 1/3, 1/3, 0)) $ //TODO: maybe highlight with color what gets aggregated to what.
In the tuple $d_(1,1) = (0, 2/3, 0, 1/3)$, the first $0$ means "zero of the first $w$ (in this case 3) shots contained the measurement result of $0$". \
This results in:
$ X = {((0, 2/3, 0, 1/3), (0, 1/3, 1/3, 1/3)), ((0, 1, 0, 0), (1/3, 1/3, 1/3, 0))} $

For $k=3$, each ordered tuple $x in X$ would contain 3 different sub-tuples such that $x = (x_1, x_2, x_3)$.
$X$ can contain the probability distribution data accumulated from multiple runs from different quantum computers or simulators.

In the following machine learning approaches, if no window size is mentioned, these models were trained and evaluated with data preprocessed with a window size of 2000.
The window size of 2000 was chosen because it results in high accuracy even with a low number of measurement steps across models, as described in @evaluation.

=== Support Vector Machine
In order to select the best support vector machine algorithm for training, a preliminary evaluation was conducted using 20% of the dataset.
This evaluation process involved comparing the classification accuracy of three potential SVM algorithms: linear, polynomial, and radial basis function.
During this phase, the algorithm demonstrating superior accuracy is then selected for further training.
This makes it possible to achieve high accuracies even for complicated input data while trying to keep the computational cost low.
The chosen algorithm undergoes training on 60% of the input data, and its performance is subsequently assessed using the remaining 20% of the data to ensure its efficacy and reliability.
The selection process for the SVM algorithm is based on @martinaLearningNoiseFingerprint2022.

=== Feedforward Neural Net <approach-ffnn>
The feedforward neural net was trained on 80% of the dataset, 20% were used to evaluate the model's accuracy.
The input layer of the neural network was designed to be variable, accommodating between 4 to 36 inputs, depending on the number of measurement steps that are included in the dataset.
When using measurement step 1 up to $k$, $4 dot k$ inputs are required.
This flexibility was needed to be able to compare different amounts of measurement steps in @evaluation.
The architecture included two dense hidden layers containing 45 and 20 neurons, respectively, both utilizing the hyperbolic tangent (tanh) activation function.
For hyperparameter tuning, the KerasTuner @omalley2019kerastuner, specifically employing the Hyperband algorithm, was utilized.
This method optimizes for validation accuracy by exploring various configurations for the number of neurons in each layer and the activation function used.
For the first layer, the number of neurons could range from 1 to 100, with a step size of 5, while for the second layer, the range was from 1 to 50 neurons, also with a step size of 5.
The activation functions tested were rectified linear unit (ReLU), sigmoid, and tanh.
The choice of the tanh activation function was based on its performance, which yielded higher accuracy compared to ReLU and sigmoid when tested with the KerasTuner.
The final number of neurons for each layer were determined through a combination of using the KerasTuner and manual trial and error.
The output layer was constructed with a single neuron, employing a sigmoid activation function to produce a probability output between 0 and 1, indicative of the data source being a quantum computer or simulator, respectively.
See @fnn-architecture-diagram for an overview of the model's architecture.

#figure(
  raw-render(
    width: 30%,
    ```dot
    digraph NeuralNetwork {
      node [shape=record];
      rankdir=TD;
      
      // Define nodes
      input [label=<{<B>Input</B>| Input shape: (4 * k)}>, fillcolor="#72be90", style=filled];
      hidden1 [label=<{<B>Dense Layer 1</B>| Output shape: (45) | Activaton function: tanh}>, fillcolor="#6a6ca4", style=filled];
      hidden2 [label=<{<B>Dense Layer 2</B>| Output shape: (20) | Activaton function: tanh}>, fillcolor="#6a6ca4", style=filled];
      output [label=<{<B>Dense Output Layer</B>| Output shape: (1) | Activation function: Sigmoid}>, fillcolor="#ea9397", style=filled];
      
      // Define connections
      input -> hidden1;
      hidden1 -> hidden2;
      hidden2 -> output;
      
      // Additional styling
      edge [color=gray];
      ranksep="0.5 equally";
      nodesep="0.5";
    }

    ```
  ),
  caption: [Architecture diagram for the feedforward neural net. In the input layer, $k$ refers to the measurement step.]
) <fnn-architecture-diagram>

For the training process, the Adam optimizer was selected.
The loss during training was quantified using binary cross-entropy, the standard choice for binary classification problems.
Training was conducted over a maximum of 100 epochs with a batch size of 32.
In order to reduce training time, after 5 consecutive epochs with no improvement for the validation loss, further epochs were skipped, balancing computational efficiency and the model's ability to learn from the training data.
This early stopping was necessary, especially when training with measurement steps $k >= 3$, because the highest accuracy has been reached almost after the first epoch, see @fnn-training-step-5.
Extending the training beyond 100 epochs did not significantly improve accuracy, as shown in @fnn-training-step-1.
After training, the model's accuracy was evaluated using the previously unseen test data.
This configuration led to the model's successful differentiation between the two backend types, see @evaluation.

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_1_val_accuracy.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: 0.4, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_1_val_loss.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: 0.25, y-max: 0.75,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Training history for the feedforward neural net. The dataset used was a combination of all measurement data generated by all available quantum computers and simulators. Only data from measurement step 1 has been used for training with a window size of 2000. These charts show that validation accuracy (left graph) and validation loss (right graph) do not improve significantly after 100 training epochs.]
) <fnn-training-step-1>

#v(15pt)

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_5_val_accuracy.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max:200,
        x-label: "Epoch",
        y-min: 0.9, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_5_val_loss.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: 0.01, 
        x-min: -5, x-max:200,
        x-label: "Epoch",
        y-min: -0.003, y-max: 0.04,
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Training history for the feedforward neural net. The dataset used was a combination of all measurement data generated by all available quantum computers and simulators. Data from measurement steps 1 up to (including) measurement step 5 have been used for training with a window size of 2000. These charts show that validation accuracy (left graph) and validation loss (right graph) almost immediately reach their best values after training starts.]
) <fnn-training-step-5>

=== Convolutional Neural Net
A convolutional neural network model was trained, utilizing a dataset divided into 80% for training and 20% for validation.
The input layer of the model was designed to be adaptable, accommodating a variable number of neurons ranging from 4 to 36, depending on the number of measurement steps incorporated in the dataset, similar to @approach-ffnn.
When using measurement step 1 up to $k$, $4 dot k$ inputs are required.
The first convolutional layer contains 40 1-dimensional filters, each with a kernel size of 3, using the ReLU activation function.
Following the convolutional layer, a 1-dimensional max pooling operation was applied, reducing the dimensionality of the data.
After the max pooling, the network architecture includes a flattening step, transforming the pooled feature maps into a single, linear vector.
This flattened vector was then fed into two additional hidden layers, comprising 64 and 32 neurons, each employing the ReLU activation function to further process and refine the features extracted from the input data.
The KerasTuner @omalley2019kerastuner, with the Hyperband algorithm, was utilized for hyperparameter tuning the CNN.
Optimization took place with respect to the validation accuracy by exploring various configurations for the number of filters, the size of the filters, the number of neurons in each layer, and the activation function used.
For the convolutional layer, the number of filters could range from 1 to 50, with filter sizes between 2 and 4.
Optimization for the feedforward neural net part was similar to @approach-ffnn.
For the first dense layer, the number of neurons could range from 1 to 100, for the second dense layer, the range was from 1 to 50 neurons, both with a step size of 5.
The activation functions tested were rectified linear unit (ReLU), sigmoid, and tanh.
The choice of the ReLU activation function was based on its performance, which yielded higher accuracy with the KerasTuner.
The final number of filters, their size, and the number of neurons for each layer were determined using a combination of the KerasTuner and manual trial and error.
The output layer consists of a single neuron utilizing a sigmoid activation function.
This setup is particularly suited for binary classification tasks, as it produces an output in the range of 0 to 1, indicative of the class membership of the input data.
See @cnn-architecture-diagram for an overview of the model's architecture.

#figure(
  raw-render(
    width: 30%,
    ```dot
    digraph CNN {
      node [shape=record];
      rankdir=TD;
      
      // Define nodes
      input [label=<{<B>Input Layer</B>| Input shape: (4 * k)}>, fillcolor="#72be90", style=filled];
      conv1 [label=<{<B>Convolutional Layer</B>| Kernel size: 1 x 3 | No. of filters: 40}>, fillcolor="#6a6ca4", style=filled];
      pooling [label=<{<B>1D Max Pooling Layer</B>}>, fillcolor="#6a6ca4", style=filled];
      hidden1 [label=<{<B>Dense Layer 1</B>| Output shape: (64) | Activaton function: ReLU}>, fillcolor="#6a6ca4", style=filled];
      hidden2 [label=<{<B>Dense Layer 2</B>| Output shape: (32) | Activaton function: ReLU}>, fillcolor="#6a6ca4", style=filled];
      output [label=<{<B>Dense Output Layer</B>| Output shape: (1) | Activation function: Sigmoid}>, fillcolor="#ea9397", style=filled];
      
      // Define connections
      input -> conv1;
      conv1 -> pooling;
      pooling -> hidden1;
      hidden1 -> hidden2;
      hidden2 -> output;
      
      // Additional styling
      edge [color=gray];
      ranksep="0.3";
      nodesep="0.4";
    }

    ```
  ),
  caption: [Architecture diagram for the convolutional neural net. In the input layer, $k$ refers to the measurement step.]
) <cnn-architecture-diagram>

The Adam optimizer and binary cross-entropy were employed for optimization and loss calculation, respectively.
Binary cross-entropy is a standard loss function used for binary classification problems, measuring the difference between predicted probabilities and actual class labels.
The model was trained for a maximum of 100 epochs, with further epochs skipped after five consecutive epochs with no improvement for the validation loss to balance computational efficiency and the model's ability to learn from the training data.
Early stopping was essential when training with measurement steps $k >= 3$, as the highest accuracy was usually achieved after the first epoch; see @cnn-training-step-5.
Extending training beyond 100 epochs did not significantly improve accuracy, see @cnn-training-step-1.
After training, the model's accuracy was assessed using previously unseen validation data.
This setup enabled successful differentiation between the two backend types, as described in @evaluation.

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_1_val_accuracy.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: 0.4, y-max: 1.05,
        y-ticks: (0.5, 0.6, 0.7, 0.8, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_1_val_loss.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: 0.25, y-max: 0.75,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Training history for the CNN. The dataset used was a combination of all measurement data generated by all available quantum computers and simulators. Only data from measurement step 1 has been used for training with a window size of 2000. These charts show that validation accuracy (left graph) and validation loss (right graph) do not improve significantly after 50 to 100 training epochs.]
) <cnn-training-step-1>

#v(15pt)

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_5_val_accuracy.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: none, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: 0.9, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_5_val_loss.csv")

      plot.plot(size: (5,4), x-tick-step: 50, y-tick-step: 0.002, 
        x-min: -5, x-max: 200,
        x-label: "Epoch",
        y-min: -0.0003, y-max: 0.004,
        y-label: "Loss",
        y-decimals: 5,
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Training history for the CNN. The dataset used was a combination of all measurement data generated by all available quantum computers and simulators. Data from measurement steps 1 up to (including) measurement step 5 have been used for training with a window size of 2000. These charts show that validation accuracy (left graph) and validation loss (right graph) almost immediately reach their optimal values after training starts.]
) <cnn-training-step-5>

== Adversarial Machine Learning with Fast Gradient Sign Method
For the adversarial attack, the goal is to take measurements from a simulator, perform the Fast Gradient Sign Attack on them, and show that they are classified as 'has been run on a quantum computer' afterward.
The model attacked was the feedforward neural net (as described in @approach-ffnn), which has been trained on 80% of all available simulator and quantum computer data, containing all 9 measurement steps.
The remaining 20% were used for measuring the model accuracy beforehand.
All 9 measurements were included to achieve the highest accuracy and robustness against unknown quantum computer inputs (see @adversarial-accuracy). 
1400 input samples were converted into adversarial samples.
The attack itself was performed by taking the gradient of the loss for each of the input samples.
In order to keep the perturbation small, $epsilon$ ranged from 0 (no change in the input sample) to 0.07 with a step size of 0.005. 
A comparison of the original input and adversarial samples can be seen in @adversarial-samples-histogram-measurement-step-1 and @adversarial-samples-histogram-measurement-step-9.
The probability values in the adversarial samples get clipped such that only valid values between 0 and 1 remain.
Additionally, subsequent packs of four values each get normalized to sum up to 1, making sure they represent valid probabilistic distributions.
This means that an input 
$ x = ((c_1, c_2, c_3, c_4)^k) $
gets normalized such that for each tuple in $x$, the following holds:
$ sum_(i=1)^4 c_i = 1. $
Because all 9 measurement steps were included, $k = 9$.
Through this attack, it was possible to get the model to label measurements generated by a simulator as quantum computer generated.
See @evaluation-fgsm for a detailed evaluation.

#pagebreak(weak: true)

= Evaluation <evaluation>
The evaluation section shows, that distinguishing what type of backend the circuit was executed on is possible with up to 100% accuracy.
Additionally it shows that an increasing window size and taking more measurement steps into account both increases accuracy.
Furthermore, single and multiple quantum computers and simulators are being excluded from the training set and used as test set, showing that the models can even classify unknown backends with an accuracy of at least 90% when using all 9 measurement steps.

== Compare window size vs measurement step range
This section evaluates the effects of window size and measurement step range on the three machine learning approaches.
It has been included to show that the classification of quantum computer or simulator is possible.
The dataset used for this evaluation contains every quantum computer and every simulator with 20% of the data used for validaton.
By choosing a larger window size, the accuracy accross models increases drastically.
Especially when compared to small window sizes such as $w = 5$. //TODO: reference figure
This is due to the fact that more measurements get included into the calculated probability distribution, capturing the noise produced by the backend more relaibly.
From a winodw size of $w = 2000$ and upward, the accuracy gain is neglegible.
Especially when training only on a combination of the first three measurement steps and using window sizes of 2000, every model is able to reach an accuracy of 98% or above.
Only for a small number of measurement steps $k=1$ or $k=2$ a difference is visible, with a small accuracy advantage for the feedforward neural net, see @comparison-measurement-steps-w-2000.

//TODO: adjust colors for graphs (same window size should have same color accross graphs)
#grid(
  gutter: 20pt,
  grid(
    columns: 2,
    gutter: 20pt,
    figure(
      cetz.canvas(length: 1cm, {
        import cetz.draw: *
        import cetz.plot

        let window_size_50 = ((1, 0.597), (2, 0.621),(3, 0.845), (4, 0.933), (5, 0.944), (6, 0.954), (7, 0.958), (8, 0.974), (9, 0.980))
        let window_size_100 = ((1, 0.623), (2, 0.648), (3, 0.904), (4, 0.974), (5, 0.981), (6, 0.986),(7, 0.988), (8, 0.994), (9, 0.996))
        let window_size_2000 = ((1, 0.694), (2, 0.815), (3, 0.997), (4, 1.000), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))
        let window_size_8000 = ((1, 0.693), (2, 0.879), (3, 0.997), (4, 1.000), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))


        plot.plot(size: (5.5,4.5), x-tick-step: 1, y-tick-step: none, 
          x-min: 0.5, x-max: 9,
          x-label: "Measurement steps",
          y-min: 0.45, y-max: 1.05,
          y-ticks: (0, 0.25, 0.5, 0.7, 0.9, 1),
          y-label: "Accuraccy",
          legend: "legend.inner-south-east",
        {
          plot.add(window_size_50, label: [w = 50], mark: "x", mark-size: 0.10)
          plot.add(window_size_100, label: [w = 100], mark: "x", mark-size: 0.10)
          plot.add(window_size_2000, label: [w = 2000], mark: "x", mark-size: 0.10)
          plot.add(window_size_8000, label: [w = 8000], mark: "x", mark-size: 0.10)
        })
      }),
      caption: [Accuracy for the SVM, trained on the dataset containing all quantum computer and all simulator data. A window size of $w = 5$ has been omitted, because the training time for such a high number of inputs was not feasible.],
    ),

    figure(
      cetz.canvas(length: 1cm, {
        import cetz.draw: *
        import cetz.plot

        let window_size_5 = ((1, 0.549), (2, 0.565), (3, 0.670), (4, 0.737), (5, 0.751), (6, 0.760), (7, 0.767), (8, 0.796), (9, 0.808))
        let window_size_50 = ((1, 0.586), (2, 0.642), (3, 0.848), (4, 0.941), (5, 0.955), (6, 0.961),(7, 0.963), (8, 0.978), (9, 0.982))
        let window_size_100 = ((1, 0.629), (2, 0.679), (3, 0.897), (4, 0.978), (5, 0.986), (6, 0.987), (7, 0.986), (8, 0.995), (9, 0.996))
        let window_size_2000 = ((1, 0.773), (2, 0.868), (3, 0.993), (4, 0.999), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))
        let window_size_8000 = ((1, 0.671), (2, 0.937), (3, 0.999), (4, 1.000), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))

        plot.plot(size: (5.5,4.5), x-tick-step: 1, y-tick-step: none, 
          x-min: 0.5, x-max: 9,
          x-label: "Measurement steps",
          y-min: 0.45, y-max: 1.05,
          y-ticks: (0, 0.25, 0.5, 0.7, 0.9, 1),
          y-label: "Accuraccy",
          legend: "legend.inner-south-east",
        {
          plot.add(window_size_5, label: [w = 5], mark: "x", mark-size: 0.10)
          plot.add(window_size_50, label: [w = 50], mark: "x", mark-size: 0.10)
          plot.add(window_size_100, label: [w = 100], mark: "x", mark-size: 0.10)
          plot.add(window_size_2000, label: [w = 2000], mark: "x", mark-size: 0.10)
          plot.add(window_size_8000, label: [w = 8000], mark: "x", mark-size: 0.10)
        })
      }),
      caption: [Accuracy for the FNN, trained on the dataset containing all quantum computer and all simulator data.]
    ),
  ),

  figure(
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let window_size_5 = ((1, 0.549), (2, 0.568), (3, 0.669), (4, 0.738), (5, 0.750), (6, 0.760), (7, 0.767), (8, 0.795), (9, 0.807))
      let window_size_50 = ((1, 0.558), (2, 0.642), (3, 0.848), (4, 0.937), (5, 0.953), (6, 0.958), (7, 0.965), (8, 0.977), (9, 0.980))
      let window_size_100 = ((1, 0.639), (2, 0.682), (3, 0.903), (4, 0.979), (5, 0.984), (6, 0.983), (7, 0.990), (8, 0.995), (9, 0.997))
      let window_size_2000 = ((1, 0.642), (2, 0.856), (3, 0.990), (4, 0.999), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))
      let window_size_8000 = ((1, 0.627), (2, 0.817), (3, 0.989), (4, 1.000), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))

      plot.plot(size: (5.5,4.5), x-tick-step: 1, y-tick-step: none, 
        x-min: 0.5, x-max: 9,
        x-label: "Measurement steps",
        y-min: 0.45, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.7, 0.9, 1),
        y-label: "Accuraccy",
        legend: "legend.inner-south-east",
      {
        plot.add(window_size_5, label: [w = 5], mark: "x", mark-size: 0.10)
        plot.add(window_size_50, label: [w = 50], mark: "x", mark-size: 0.10)
        plot.add(window_size_100, label: [w = 100], mark: "x", mark-size: 0.10)
        plot.add(window_size_2000, label: [w = 2000], mark: "x", mark-size: 0.10)
        plot.add(window_size_8000, label: [w = 8000], mark: "x", mark-size: 0.10)
      })
    }),
    caption: [Accuracy for the CNN, trained on the dataset containing all quantum computer and all simulator data.]
  ),
) <window-size-vs-step-ranges-plots>

#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot

    let cnn_window_size_2000 = ((1, 0.642), (2, 0.856), (3, 0.990), (4, 0.999), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))

    let fnn_window_size_2000 = ((1, 0.773), (2, 0.868), (3, 0.993), (4, 0.999), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))

    let svm_window_size_2000 = ((1, 0.694), (2, 0.815), (3, 0.997), (4, 1.000), (5, 1.000), (6, 1.000), (7, 1.000), (8, 1.000), (9, 1.000))

    plot.plot(size: (5.5,4), x-tick-step: 1, y-tick-step: none, 
      x-min: 0.5, x-max: 9,
      x-label: "Measurement steps",
      y-min: 0.55, y-max: 1.05,
      y-ticks: (0, 0.25, 0.5, 0.7, 0.9, 1),
      y-label: "Accuraccy",
      legend: "legend.inner-south-east",
    {
      plot.add(svm_window_size_2000, label: [SVM], mark: "x", mark-size: 0.10)
      plot.add(fnn_window_size_2000, label: [FNN], mark: "x", mark-size: 0.10)
      plot.add(cnn_window_size_2000, label: [CNN], mark: "x", mark-size: 0.10)
    })
  }),
  caption: [Accuracy comparison between SVM, FNN and CNN. All three models were trained on the dataset containing all quantum computer and all simulator data.]
) <comparison-measurement-steps-w-2000>

== Exclude quantum computer or simulator from training dataset
This section evaluates the accuracy of the different models in case they encounter quantum comuters or simulators, which were not in the training dataset.
This is interesting insofar as that this would be the real world scenario for the classifiers, because they should be able to correctly classify the measurement results even if the backend is unknown to the model.
When excluding only a single quantum computer from the training dataset and using exclusively the measurements generated by the excluded quantum computer as testset, the performance for only the first measurement step is highly variable ranging from 0 up to 0.921. 
All three models have a slightly decresed accuracy for classification when the quantum computer Athens or Santiago was excluded.
This could be due to the fact, that simulators with noise models based on Athens and Santiago were used for generating simulator measurements with noise.
However, they had higher accuracy when Lima was excluded, even though a simulator with a noise model which was based on Lima has been used as well.
This could be due to the fact that the noise model could have been generated a few years back @Fake_provider, not matching the calibration used for the Lima QC in this dataset.
Overall, all three models reach high accuracies when using all 9 measurement steps (@svm-single-qc-excluded, @fnn-single-qc-excluded, @cnn-single-qc-excluded).

#text(size: 10pt, [])
#let svm_exclude_single_qc = csv("data/svm_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Measurement Step Ranges*],[*Excluded QC*],..svm_exclude_single_qc.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the SVM. A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used as testset.",
  kind: table,
) <svm-single-qc-excluded>

#let ann_exclude_single = csv("data/neural_net_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Measurement Step Ranges*],[*Excluded QC*],..ann_exclude_single.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the feedforward neural net. A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used as testset.",
  kind: table,
) <fnn-single-qc-excluded>

#let cnn_exclude_single = csv("data/cnn_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Measurement Step Ranges*],[*Excluded QC*],..cnn_exclude_single.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the CNN. A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used as testset.",
  kind: table,
) <cnn-single-qc-excluded>

Building on the analysis of excluding single quantum computers, a more complex evaluation approach involves excluding every possible combination of up to 4 quantum computers without considering the order in which they are excluded.
In this testing scenario, only the measurement data originating from the excluded QCs serve as the test set.
This approach ensures that the models face scenarios where they must generalize well beyond the specific characteristics of any single QC.
In the dataset, all 9 measurement steps were used, in order to achieve the highest possible accuracy, which would be a critical factor for real-world applications.
Averaging the accuracy across each number of excluded QCs provides a comprehensive view of how well each model adapts to varying levels of information scarcity.
Among the three models, the FNN exhibits superior performance.
As depicted in @accuracy-multiple-excluded-qcs, the FNN achieves an average accuracy of 96.6% when four quantum computers are excluded.
This high level of accuracy, despite the exclusion of multiple QCs, underscores the FNN's robustness.

#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot

    let cnn = ((0, 1.000), (1, 0.977), (2, 0.957), (3, 0.939), (4, 0.902))

    let fnn = ((0, 1.000), (1, 0.995), (2, 0.995), (3, 0.989), (4, 0.966))

    let svm = ((0, 1.000), (1, 0.964), (2, 0.954), (3, 0.946), (4, 0.919))

    plot.plot(size: (5.5,4), x-tick-step: 1, y-tick-step: none, 
      x-min: -0.2, x-max: 4.2,
      x-label: "No. of excluded QCs",
      y-min: 0.85, y-max: 1.02,
      y-ticks: (0.85, 0.9, 0.95, 1),
      y-label: "Accuraccy",
      legend: "legend.south-east",
    {
      plot.add(svm, label: [SVM], mark: "x", mark-size: 0.10)
      plot.add(fnn, label: [FNN], mark: "x", mark-size: 0.10)
      plot.add(cnn, label: [CNN], mark: "x", mark-size: 0.10)
    })
  }),
  caption: [Dataset with the given number of QCs excluded. Only the measurements from the excluded QCs were used as testset. The accuracy depicted is for models trained on data consisting of all 9 measurement steps.]
) <accuracy-multiple-excluded-qcs>

When excluding only a single simulator from the training dataset and using exclusively the measurements generated by the excluded simulator as testset, the performance for only the first measurement step is highly variable, similar to the exclusion of one quantum computer. 
The Aer Simulator, Fake Santiago, and Fake Cairo get misclassified when using only one measurement step accross all three models.
This could be because these simulators have a small (or in case of the Aer Simulator no) noise perturbation.
The Fake Santiago and Fake Cairo simulators for example have quite low qubit readout errors (see @simulator-readout-error).
The models have an almost perfect accuracy when using the first four measurement steps or more.
Overall, all three models reach perfect accuracies of 1.0 when using all 9 measurement steps (@svm-single-simulator-excluded, @fnn-single-simulator-excluded, @cnn-single-simulator-excluded).

#let svm_exclude_single_simulator = csv("data/svm_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Measurement Step Ranges*],[*Excluded Simulator*],..svm_exclude_single_simulator.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the SVM. A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used as testset.",
  kind: table,
) <svm-single-simulator-excluded>

#let fnn_exclude_single_simulator = csv("data/neural_net_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
    [],colspanx(9)[*Measurement Step Ranges*],[*Excluded Simulator*],..fnn_exclude_single_simulator.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the FNN. A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used as testset.",
  kind: table,
) <fnn-single-simulator-excluded>

#let cnn_exclude_single_simulator = csv("data/cnn_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Step Ranges*],[*Excluded Simulator*],..cnn_exclude_single_simulator.flatten().slice(1,)
    )
  ),
  caption: "Accuracy for the CNN. A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy.",
  kind: table,
) <cnn-single-simulator-excluded>

Excluding every possible combination of 4 simulators without considering the order in which they are excluded, shows that when taking measurement steps from 1 up to 4 into account, all models have an accuracy of over 99.3%.
The accuracy at measurement steps from 1 up to 9 is 100% accross all models, see @exclude-four-simulators. 
Therefore, the models have either better abstracted an general notion of simulator noise, or the simulators in the dataset were easier to classify compared to the quantum computers.

#let exclude_4_simulators = csv("data/exclude_four_simulators_vs_step_range_all_models.csv")
#figure(
  text(
    size: 9pt,
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
      [],colspanx(9)[*Step Ranges*],[*Model*],..exclude_4_simulators.flatten().slice(1,)
    )
  ),
  caption: [Comparing the accuracy of the SVM, FNN, and CNN. This table contains the average accuracy of all training runs excluding every possible combination of four simulators. Only the data generated by the excluded simulators was used as testset each time.],
  kind: table,
) <exclude-four-simulators>


== Adversarial Machine Learning with Fast Gradient Sign Method <evaluation-fgsm>
//TODO: "defense" against fgsm complicated, because distribution values actually approach real quantum computer values. Not even a human could correcly determin the class (im gegensatz zu fgsm bei bildern).
By converting 1400 samples generated by simulators into adversarial samples in such a fasion that they are recognized as 'generated by a quantum computer'.
The result can be seen in @adversarial-accuracy.
When epsilon is zero the sample equals the original input sample.
The graph shows that with increasing $epsilon$ values, the accuracy gets worse due to the increased perturbation in the adversarial sample.

#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot

    plot.plot(size: (10,5), x-tick-step: 0.010, y-tick-step: none, 
      x-decimals: 3,
      x-label: "Epsilon",
      y-min: 0, y-max: 1.05,
      y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
      y-label: "Accuraccy",
    {
      let adversarial_accuracy_data = csv("data/walker_adversarial_attack_simulator_to_quantum.csv")

      plot.add(adversarial_accuracy_data.map(((epsilon,acc)) => (float(epsilon), float(acc))), mark: "x", mark-size: 0.10)
    })
  }),
  caption: "Comparison of the models accuracy on adversarial samples with different epsilon values. 1400 samples were converted to adversarial samples for this graph. The larger the epsilon value gets, the larger the perturbation in the adversarial sample.",
  kind: table,
) <adversarial-accuracy>

The histograms in @adversarial-samples-histogram-measurement-step-1 to  @adversarial-samples-histogram-measurement-step-9 visualize the probabilities for each measurement result at different measurement steps in the quantum circuit.
In most cases an increase of $epsilon$ leads to a probability distribution which is closer to the distribution of a quantum computer.

#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_0_adversarial.svg"),
  caption: [Comparison of different epsilon values for the first measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well.]
) <adversarial-samples-histogram-measurement-step-1>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_8_adversarial.svg"),
  caption: [Comparison of different epsilon values for the ninth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well.]
) <adversarial-samples-histogram-measurement-step-9>

It is possible for a malevolent quantum cloud provider to perform such an adversarial attack.
Even though, it is quite hard to pull off due to the fact, that FGSM is a white-box attack.
As a result, the neural net which should differenciate between simulator and quantum computer has to be known by the malevorent quantum cloud provider.

== Discussion
//Overall for the classification part: the FNN seems to have a slight advantage compared to the CNN and SVM when classifying unknown quantum computers.
// for unknown simulators, all three models perform equal with 100% accuracy.

//TODO: discussion for fgsm.

== Limitations <limitations>
The main limitation of this work is, that classification can only be performed with the circuit from  @circuit.
This is due to the fact, that different quantum circuits result in different distributions of measurement results.
Despite this limitation, it is possible to utilize this approach for simulator detection.
In order to achieve this, the circuit from @circuit gets sent to the (possibly adversarial) quantum cloud provider.
The results get classified in order to determine whether the circuit has been run on a quantum computer or simulated on a classical computer.
It would be possible for the quantum cloud provider to recognize this specific circuit, route the circuit to a legit quantum computer provider, and forward the results to the end user.
To prevent this, the circuit could be embedded into the circuit which the user wants to execute.

Additionally, as shown in @evaluation-fgsm, it is possible to forge adversarial samples which get classified with the incorrect label.
Despite keeping the model hidden to try to prevent such a white-box adversarial attack, it could be possible to generate adversarial samples despite the precautions by using the transferability of adversarial samples @szegedyIntriguingPropertiesNeural2013.

Furthermore, only measurement data from IBM quantum computers was available for training the machine learning models in this thesis.
The generalization capability of the models has not been tested when confronted with a quantum computer from another manufacturer or based on another technology than superconducting qubits.

#pagebreak(weak: true)

= Future Work and Conclusion <future-work-and-conclusion>
This thesis demonstrates that it is possible, with current machine learning algorithms, to predict with a high probability whether an existing quantum circuit was executed by a quantum computer or by a simulator backend.
While the machine learning models proposed in this thesis cannot generalize to other arbitrary quantum circuits, they can still potentially be retrained and adapted for classifying results from different quantum circuits.
Therefore, it would be interesting to test if this approach can distinguish between simulators and quantum computers for other quantum circuits beyond the one used in this thesis.
Moreover it would be interesting to explore how adding additional samples from different (and possibly more modern) quantum computers would influence the accuracy.
Also, it could be interesting to perform further, more advanced adversarial attacks on the neural net, such as a trying to utilize the basic iterative method @kurakinAdversarialExamplesPhysical2017.
When taking the limitations shown in @limitations into account, this approach can be used as a usefull indicator for validating that the correct backend types has been used for executing a quantum circuit. 
//TODO: add more text

#pagebreak(weak: true)

= Appendix <appendix>
#figure(
  image("images/walker-step-2.svg", width: 40%),
  caption: "Circuit which corresponds to measurement step 2."
) <circuit-measurement-step-2>
#v(10pt)
#figure(
  image("images/walker-step-3.svg", width: 45%),
  caption: "Circuit which corresponds to measurement step 3."
) <circuit-measurement-step-3>
#v(10pt)
#figure(
  image("images/walker-step-4.svg", width: 50%),
  caption: "Circuit which corresponds to measurement step 4."
) <circuit-measurement-step-4>
#v(10pt)
#figure(
  image("images/walker-step-5.svg", width: 60%),
  caption: "Circuit which corresponds to measurement step 5."
) <circuit-measurement-step-5>
#v(10pt)
#figure(
  image("images/walker-step-6.svg", width: 70%),
  caption: "Circuit which corresponds to measurement step 6."
) <circuit-measurement-step-6>
#v(10pt)
#figure(
  image("images/walker-step-7.svg", width: 80%),
  caption: "Circuit which corresponds to measurement step 7."
) <circuit-measurement-step-7>
#v(10pt)
#figure(
  image("images/walker-step-8.svg", width: 90%),
  caption: "Circuit which corresponds to measurement step 8."
) <circuit-measurement-step-8>
#v(10pt)

#pagebreak(weak: true)

#bibliography("Sources.bib")