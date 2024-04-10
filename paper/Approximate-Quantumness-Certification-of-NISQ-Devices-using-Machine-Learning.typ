#import "@preview/cetz:0.2.2"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx
#import "@preview/lovelace:0.2.0": *

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

//TODO: make figure start (Figure 1:) bold.
//#set figure(
//  numbering : it => text(weight:"bold")[#it],
//)

//TODO: übergänge zwischen den einzelnen sektionen, sollte am stück gelesen werden können?

//TODO: mehr margin am Rand (orientirung am Deckblatt).
//TODO: Deckblatt hinzufügen

//TODO: bei graphen die Ticks nach außen richten?

//TODO: note: idea is to classify noise model of simulator vs noise model of quantum computer (in a general fashion)

#show outline.entry.where(
  level: 1
): it => {
  v(14pt, weak: true)
  strong(it)
}

#align(center, text("Abstract", weight:"bold"))
//TODO: add abstract

#v(30pt)

#align(center, text("Zusammenfassung", weight:"bold"))
//TODO: add zusammenfassung

#pagebreak()

#outline(indent: auto)

#pagebreak()

= Introduction and Motivation
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
When utilizing a statevector for simulating a quantum circuit without any restrictions, $8 dot 2^n$ bytes are needed to store the statevector, $8$ because each amplitude can be stored as a complex float (4 bytes real and 4 bytes imaginary, single precision).
See @memory-needed-for-simulating-n-qubits for a visualization of the exponential memory growth when simulationg a growing number of qubits.

#figure(
  cetz.canvas(length: 1cm, {
    import cetz.draw: *
    import cetz.plot

    // Let ticks point outwards by giving them negative length
    set-style(axes: (tick: (length: -.1)))

    plot.plot(size: (12,6), 
      x-tick-step: 5, 
      x-ticks: (1,),
      x-label: "Number of qubits",
      x-min: 1,
      y-tick-step: none, 
      y-ticks: ((0, 0), (5, [$2^5$]), (10, [$2^10$]), (15, [$2^15$]), (20, [$2^20$]), (25, [$2^25$]), (30, [$2^30$]), (35, [$2^35$]), (40, [$2^40$]), (45, [$2^45$]), (50, [$2^50$]), (55, [$2^55$])),
      y-label: "Bytes to store statevector",
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
  caption: [Memory needed to store a statevector for 1 up to 55 qubits. The memory footprint is calculated on the assumption that $8 dot 2^n$ bytes are needed to store $n$ qubits.]
) <memory-needed-for-simulating-n-qubits>
The amount of memory needed for simulating a circuit depends on the simulator approach used.
For a quantum circuit with depth 27 in a 2D lattice of $7 times 7$ qubits it was possible to simulate a circuit with only 4.5 Terabyte of RAM @pednaultParetoEfficientQuantumCircuit2020, compared to 8 Petabyte needed in previous simulation implementations @hanerPetabyteSimulation45Qubit2017.

In 2020, a research team led by scientist Jian-Wei Pan at the University of Science and Technology of China (USTC) achieved quantum supremacy using 76 photons for the Gaussian boson sampling algorithm @garistoLightBasedQuantumComputer2021.
The samples generated in the study required 200 seconds, a task estimated to take a classical supercomputer 2.5 billion years to complete, as detailed in the paper @zhongQuantumComputationalAdvantage2020.
Quantum supremacy marks the point at which quantum computers outperform classical computers in specific tasks.
The majority of circuits demonstrating quantum supremacy are inherently not directly applicable to practical computational problems.
These circuits primarily serve to exhibit quantum computational supremacy by performing specific tasks that are infeasible for classical computers within a reasonable timeframe, without necessarily providing practical computational benefits @caludeRoadQuantumComputational2019.
Conversely, algorithms such as Shor's Algorithm, which have significant practical implications, especially in the field of cryptography, demand a higher number of qubits and lower levels of quantum noise for effective implementation.
When passing a quantum circuit which has been used for demonstrating quantum supremacy or with a high number of qubits to a cloud quantum provider the returned results could be either from an actual quantum computer or a (randomly) fabricated distribution.
Due to the fact that current quantum computers are noisy and simulating the correct result for a large circuit is infeasible, checking the result for correctness is challenging.
Therefore these cases are out of the scope of this thesis.

However, apart from these highly specialized setups, it is still possible to simulate small quantum circuits.
As of 2023, a rough cost estimate for a 9-qubit quantum computer from Rigetti stands at \$900,000 @mechanicRigettiLaunchesNovera2023.
Conversely, simulators can execute small circuits on consumer hardware, drastically reducing the cost barrier for executing quantum computations.
For example Amazon Braket charges between \$0.075 and \$0.275 per minute for simulator their cloud simulator service @AmazonBraketPricing.
When renting the IonQ Harmony quantum computer, Amazon Braket charges \$0.3 per task with an additional cost of \$0.01 per shot @AmazonBraketPricing.
Simulating a quantum circuit with 4 qubits (which can be seen in @circuit-measurement-step-9) on consumer hardware took 0.2 seconds for 8000 shots when using the 'fake_athens_v2' backend which adds noise to the result.
Assuming Amazon Brakets most expensive simulator would take 1 second, this would result in a price of
//TODO: punkt am Ende des Satzes? (bzw. am Ende der Gleichung?)
$ 1/60 "minute" dot (\$0.275)/"minute" = \$0.005 $
When executing the same quantum circuit on the IonQ Harmony quantum computer with 8000 shots it would cost
$ \$0.3 + 8000 "shots" dot (\$0.01)/"shot" = \$80.3 $
In this specific example executing the circuit on the quantum computer would cost more than 16,000 times as much. 
Of course these numbers only hold true for such tiny circuits combined with a high number of shots.
//TODO: mention that simulating circuits with more gates takes longer.
Overall, the price margin is especially large for small quantum circuits, which take a short amount of time for a simulator but have fixed costs when being run on the quantum computer.
This cost consideration underscores the significance of the threat posed by cloud quantum providers employing simulators in scenarios where the users are unaware of this substitution.
Therefore, mitigating strategies should be devised to ensure transparency and trust in quantum cloud services to safeguard against potential security breaches and ensure the integrity of quantum computations.

//TODO: note that no noise reconstruction only classification?
This work provides a machine learning-based approach that allows the users of cloud-based QCs to verify with high certainty that their quantum circuit has been executed on a quantum computer and not simulated on a classical computer.
Additionally, in order to test the robustness of the feedforward neural net, its ressilience to the Fast Gradient Sign Method, an adversarial attack, is evaluated.

== Related Work <related-work>
Multiple approaches for fingerprinting different quantum computers already exist.
After collecting data in different fashions these approaches create a fingerprint which is ideally unique for different quantum hardward.
By using the fingerprint-information it is afterwards possible to differentiate between different quantum computers.
One such work has shown that it is possible to generate a unique hardware fingerprint based on qubit frequencies.
The fingerprint is based on quantum computer calibration data, which was made available by the cloud provider @smithFastFingerprintingCloudbased2022.
A different research group has developed a Quantum Physically Unclonable Function (QuPUF).
By utilizing the QuPUF, it is possible to identify the quantum computer the QuPUF was executed on @phalakQuantumPUFSecurity2021.
Another approach uses a tomography-based fingerprinting method based on crosstalk-induced errors @miShortPaperDevice2021.

Martina et al.'s paper "Noise fingerprints in quantum computers: Machine learning software tools" distinguishes which QC a specific quantum circuit has been executed by learning the error fingerprint using a support vector machine @martinaLearningNoiseFingerprint2022.
Creating a dataset containing measurements from quantum circuits executed on different quantum computers is challenging to create due to the high cost of executing a circuit on a quantum computer many times.
Additionally, a circuit has to be designed in order to ideally capture the noise generated by a quantum computer.
On top of that, in order to get measurements with consistent noise, the circuit has to be executed on a quantum computer without being disturbed by recallibration of the QC.
Therefore the creation of such a dataset is out of the scope of this thesis.
As a result, the dataset containing quantum computer measurements and the circuits provided in @martinaLearningQuantumNoiseFingerprint2023 have been used in this thesis.

This thesis takes a similar approach to "Noise fingerprints in quantum computers: Machine learning software tools" by Martina et al. @martinaLearningNoiseFingerprint2022 and utilizes the same quantum circuits.
However, instead of differentiating between various quantum computers, this thesis creates machine learning models that distinguish whether a quantum circuit was executed by a QC or a simulator on a classical computer.

== Structure
@terms-and-definitions gives a short overview of the most important concepts of quantum computing and machine learning used in this thesis.
In @approach, an explanation for the dataset based on the circuit measurements is provided.
These are used for training different machine learning algorithms in order to differentiate whether a quantum circuit has been executed by a quantum computer or simulated by a classical computer.
Additionally, a white-box adversarial attack is performed.
After that, in @evaluation, the accuracies of the different machine learning algorithms are compared, and the limitations of this work are discussed, specifically concerning the white-box adversarial attack.
@future-work points out possible areas for further research.
At the end, @conclusion contains a short conclusion.


= Terms and Definitions <terms-and-definitions>
This section provides a concise overviews of theoretical concepts central to this thesis.
It introduces the core fundamentals of quantum computing, which utilizes quantum mechanics for computational purposes.
As second part, three different machine learning approaches, support vector machine, feedforward neural net, and convolutional neural net, 
are detailed, highlighting their unique attributes and applicability, as well as motivating why these different approaches haven been chosen. 
Additionally, the section delves into the basics of Adversarial Machine Learning, focusing on the Fast Gradient Sign Method, which illustrates vulnerabilities in machine learning models by intentionally causing them to missclassify specially prepared samples.

== Quantum Computing
//TODO: subdivide into sections:
//=== The qubit
//=== Quantum circuits
// maybe === Quantum computers???
A quantum computer leverages quantum bits (qubits).
Qubits have two basis states which are associated with the vectors
$ |0 angle.r = vec(1, 0) quad |1 angle.r = vec(0, 1). $
The notation with '$| med angle.r$' is called Dirac notation.
Classical bits are either 0 or 1.
Conversely, qubits can be in states other than $|0 angle.r$ and $|1 angle.r$.
A superposition is a linear combination of states, as in @eq1.
$ |psi angle.r = alpha|0 angle.r + beta|1 angle.r $<eq1>
In @eq1 $alpha$ and $beta$ are complex values describing probability amplitudes.
The amplitudes must satisfy the normalization condition $ |alpha|^2 + |beta|^2 = 1. $
It is possible to solve a specific selection of problems with reduced time and space complexity by leveraging quantum properties such as superposition, interference, and entanglement.
Examples of such a quantum algorithm are Shor's algorithm @shorPolynomialTimeAlgorithmsPrime1997 and Grover's argorithm @groverFastQuantumMechanical1996.
//TODO: add that circuits are evaluated from left to right.
The circuits used in this thesis consist of the Pauli-X gate, the Hadamard gate, the Controlled not gate (CNOT), and the Toffoli gate.
Their respective circuit representation can be seen in @quantum-gates.
The Pauli-X gate performs a bit flip on a single qubit.
The CNOT gate performs a bit flip on the target qubit, depending on the state of the control qubit.
//TODO: mathmatically show what circuits do?
Similarly, the Toffoli gate has two control qubits, influencing whether the target qubit gets flipped.
#figure(
  grid(
    columns: 4,
    align(horizon, image("images/gates/pauli-x.svg", width: 50%)),
    align(horizon, image("images/gates/hadamard.svg", width: 50%)),
    align(horizon, image("images/gates/cnot.svg", width: 40%)),
    align(horizon, image("images/gates/ccx.svg", width: 30%))
  ),
  caption: "Quantum gates (from left to right): Pauli-X gate, Hadamard gate, Controlled not gate, and Toffoli gate."
) <quantum-gates>
In quantum computing, measuring a qubit yields a binary outcome: either a $0$ or a $1$.
//TODO: add image of measurement-circuit part.
//TODO: explain bell state (used in circuit).
This measurement process is a critical operation that leads to the collapse of the qubit's wave function, situating it into a definitive state of either $|0 angle.r$ or $|1 angle.r$, depending on the measured value.
This collapse is a direct consequence of the quantum mechanical principle of wave function collapse, where measurement forces a quantum system to 'choose' a state from among the probabilities described by its wave function prior to measurement.
Additionally, the concept of "shots" in quantum computing refers to the number of times a quantum algorithm is executed and measured.
The rationale behind multiple shots is to compile a statistical distribution of outcomes, which is instrumental in approximating the quantum state prior to measurement.
This statistical approach is crucial due to the probabilistic nature of quantum measurements, where repeated executions help accurately estimate the likelihood of each possible outcome, thereby providing insight into the quantum system's behavior before measurement @nielsenQuantumComputationQuantum2010.

Different approaches exist for building physical quantum computers.
QCs built by IBM are based on superconducting qubit technology @QuantumSystemInformation.
Other architectures include trapped ions, photonics, and nuclear magnetic resonance @laddQuantumComputers2010.
//the main issue to be still solved is the unavoidable presence of external noise sources that dramatically
// limit the accuracy of quantum computations, as well as the large-scale realization of quantum circuits and algorithms.
//TODO: mention NISQ? (reference to introduction?)

//TODO: explain that computers can have different topologies?
Current quantum chips mainly suffer from decoherence, gate errors, readout errors, and crosstalk.
//TODO: explain errors better and more in detail T1 and T2 Times, Readout Error, ...
// readout error and gate error relevant for simulator. 
For a qubit, the decoherence time refers to how long the qubit can contain information.
Decoherence can occur, for example, when a qubit interacts with the environment.
When quantum computers are constructed from multiple qubits, unwanted interactions between these qubits are called crosstalk.

== Machine Learning
In this thesis, approaches based on three different supervised machine learning techniques get compared.
These machine learning techniqes are support vector machine, feedforward neural net, and convolutional neural net.
The support vector machine is one of the standard classification algorithms.
It tries to seperate datapoints into two classes by dividing them with a hyperplane.
The feedforward neural net is based on the notion that combining multiple simple perceptrons into layers results in a more powerful and complex model capable of handling nonlinear relationships between inputs and outputs.
The combination of these layers enables the model to effectively perform classification by capturing the underlying patterns in the data.
The convolutional neural net is especially potent when it comes to recognizing sequential data.
This is due to the use of filters sliding over the data and recognizing low level patterns.
After these filters a feedforward neural net is appended for performing the classification.

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

      let points_below = ((2, 1), (7, 6), (5, 4), (2.5, 0.5), (4, 1), (3, 1.5), (5, 2), (6, 4), (6, 1), (7, 3), (8, 1))
      for (p_1, p_2) in points_below {
        plot.add(((p_1, p_2),), mark: "x", mark-style: (stroke: green, fill: green), mark-size: .2)
      }
      //TODO: ok, dass supportvectoren auf der linie liegen? (und nicht abgegrenzt werden?)
      // Support Vectors, add circle around (where touching upper or lower margins).
      let support_vectors = ((2, 1), (7, 6), (5, 4), (1, 4), (4, 7))
      for (p_1, p_2) in support_vectors {
        plot.add(((p_1, p_2),), mark: "o", mark-style: (stroke: yellow, fill: none), mark-size: .3)
      }
  })
}),
caption: [A SVM model demonstrating the separation of two classes of data (red dots and green crosses) with a linear hyperplane in 2D space based on features $x_1$ and $x_2$. The blue dashed lines represent the margins, and the points on these margins (highlighted in yellow) are the support vectors, which are pivotal in defining the hyperplane and its orientation.]
) <svm>
A support vector machine (SVM) is a machine learning algorithm primarily used for classification and regression tasks.
Therefore, a SVM is being utilized in this thesis in order to classify whether a quantum circuit has been executed on a quantum computer or a simulator based on the measurement results.
// Additionally, previous work has successfully used SVMs for fingerprinting quantum computers @martinaLearningNoiseFingerprint2022 ??
The SVM operates by constructing an optimal hyperplane in a high-dimensional space that separates different classes of data points.
This optimal hyperplane is determined by the data points, referred to as support vectors, that lie closest to the decision boundary, see @svm.
The hyperplane divides the input features into two distinct classes.
Its position and orientation are determined to maximize the distance between the hyperplane and the nearest data point from either class.
This approach ensures the best possible separation between classes and enhances the algorithm's generalization capabilities.
However, real-world data is often not linearly separable.
To overcome this limitation, SVMs employ a technique known as the kernel trick.
A linear decision boundary can be found by mapping the input features into a higher dimensional feature space.
The kernel trick allows SVMs to construct a non-linear decision boundary in the input space, thereby enabling the classification of complex datasets.
As a result, SVMs are computationally efficient and particularly suited for handling high-dimensional data.
See @cristianiniIntroductionSupportVector2000 for additional details.

=== Feedforward Neural Network
// TODO: short motivation, why did I use it?
A feedforward neural network (FNN) is an artificial neural network commonly used for classification tasks, regression, and pattern recognition.
It passes input data through a series of interconnected layers of nodes, known as neurons or perceptrons, where each neuron performs a weighted sum of its inputs combined with a bias and applies an activation function to produce an output.
This can mathmatically be written as 
$ y = f(sum_(i=1)^(n) w_i x_i + b) $ <perceptron-math>
where $y$ denotes the perceptron output, $bold(x)$ is the input vector, $f$ is the activation function, $w_i$ is the weight associated with input $x_i$, and $b$ is the bias term.
Each neural network consists of multiple neurons, which are grouped into layers.
The first layer, the input layer, receives the initial input data.
After the input layer, subsequent layers are known as hidden layers, where complex transformations of the input data occur.
Finally, the results are taken from the last layer, the output layer, which provides the network's final output.
See @feedforward-net for a visualization.

#figure(
  image("images/feedforward-neural-network.svg", height: 25%), //TODO: adujust image colors, maybe: #72be90, #6a6ca4, #ea9397
  caption: [Feedforward neural net consisting of input layer, hidden layer and output layer. When evaluating, the value for each neuron gets calculated by @perceptron-math.]
) <feedforward-net>

During training, the network adjusts the weights of connections between neurons to minimize the loss function, which quantifies the difference between predicted outputs and actual targets.
//TODO: add that in this paper binary crossentropy loss was used + formula?
//TODO: add more mathmatically, what a loss function is?
This process often involves techniques such as backpropagation and gradient descent to iteratively reduce the loss.
By doing so, FNNs can learn complex patterns and relationships within data, enabling them to perform a wide range of tasks with high accuracy.
For additional information, see @russellArtificialIntelligenceModern2021.

=== Convolutional Neural Network
// TODO: motivation, why did I use it?
// 1D kernels for time series, sequential data -> motivation why it is considered in my thesis.
A convolutional neural network (CNN) is a specialized artificial neural network employing convolutional layers that automatically learn hierarchical patterns and features from inputs.

These convolutional layers consist of filters with a specific kernel size that slide across the input, performing convolutions to extract local features.
CNNs typically consist of multiple layers, including convolutional, pooling, and fully connected layers.
The convolutional layers detect low-level features, while subsequent layers combine these features to recognize higher-level patterns.
Pooling layers downsample the feature maps, reducing the spatial dimensions of the data and increasing computational efficiency.
Finally, fully connected layers process the extracted features to make predictions or classifications.
During training, CNNs adjust the parameters of the filters through backpropagation, optimizing them to minimize the difference between predicted outputs and ground truth labels.
This process enables CNNs to effectively learn and generalize from large datasets.
Their ability to learn relevant features from raw input data and their hierarchical architecture make them well-suited for handling complex tasks.
For additional information see @russellArtificialIntelligenceModern2021.

=== Adversarial Machine Learning using Fast Gradient Sign Method <terms-and-definitions-fgsm>
//TODO: hinführung verbessern? (machine learning wird in vielen verschiedenen bereichen verwendet, adversarial machine learning zeigt probleme/"verteidigungstaktiken"??)
Adversarial machine learning is an area of research investigating how machine learning models can be compromised by inputs designed to cause the model to make a mistake.
These inputs are known as adversarial examples.
The goal of adversarial machine learning is to understand machine learning models' vulnerabilities and develop techniques to make them more robust against such attacks.
Various machine learning techniques are tailored to address particular problem sets based on the premise that the training and test data share the same statistical distribution.
However, in practical situations, this belief can prove to be misguided.
In particular, when users intentionally submit erroneous data, it can considerably impact the reliability and effectiveness of machine learning models.
One simple and fast method of generating adversarial examples is called 
Fast Gradient Sign Method (FGSM), which is a white-box adversarial attack.
White-box adversarial attacks on neural networks operate under the premise that the attacker has complete knowledge of the model's architecture and weights.
This method, introduced by Ian Goodfellow et al. @goodfellowExplainingHarnessingAdversarial2015, operates under the premise that by applying a small, carefully calculated change in the direction of the gradient of the loss with respect to the input data, one can generate a new adversarial sample which is almost indistinguishable from the original but is misclassified by the neural network.
The perturbation is determined by taking the sign of the gradient of the loss with respect to the input features and then multiplying it by a small scalar $epsilon$ to ensure the modification is subtle.
Mathmatically this results in:
$ "adversarial_sample" = bold(x) + epsilon dot "sign"(nabla_bold(x) J(bold(theta), bold(x), y)) $ <adversarial-sample-expression>
where $bold(x)$ is the original input sample and $y$ is the according original input label.
$J$ is the loss function used for training the machine learning model and $bold(theta)$ are the model parameters.
An example where the FGSM attack has been used for generating adversarial samples for an image classifier can be seen in @adversarial-example-panda.

#figure(
  image("images/adversarial-example-panda.png"),
  caption: [Initially, the image $bold(x)$ gets correctly classified as "panda" with a confidence of $57.7%$. After multiplying noise, which was generated by the FGSM attack, with $epsilon$ of $0.007$ and adding this perturbation to the original image, the altered image gets classified as "gibbon" with a confidence of $99.3%$.
  #linebreak()
  Image from Goodfellow et al. in _Explaining and Harnessing Adversarial Examples_, p.3, 2015.]
) <adversarial-example-panda>

The FGSM is designed to be fast and computationally efficient, making it not only a powerful tool for analyzing the robustness of neural networks but also a significant concern for applications reliant on machine learning for security-sensitive tasks.

= Approach <approach>
The methods mentioned in @related-work are used for fingerprinting, meaning they can predict which results originate from which quantum computer, but most of them cannot distinguish between a QC or a simulator with a noise model.
//TODO: is "most of them" correct? hedging needed, maybe formulate in another way?
This work attempts to develop an approach that performs this differentiation.
In order to achieve this, only the measurement results of the quantum circuits are considered.
Therefore, this thesis uses machine learning techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the circuit's measurement results.

As a threat model, we assume the adversary cloud provider is interested in making a profit and therefore accepts circuits with one up to 35 qubits, needing up to approximately 256 GB of RAM (see @memory-needed-for-simulating-n-qubits for visualization).
Allowing for quantum circuits with more qubits would require exponentially more RAM and increased amounts of computing power, which would, in turn, reduce profit.
When a user sends a quantum circuit to a quantum cloud provider for execution, the user cannot easily validate that the circuit runs on the advertised quantum hardware.
This is due to the fact that the cloud provider can shedule the circuit on any hardware without giving notice to the client.
This is an inherent problem to cloud infrastructure not limited to quantum computing. //TODO: add source?


// user has no influence over "sheduling", no access to hardware (cloud computing). only passing a different circuit to the cloud quantum provider.
// -> use circuit to detect whether quantum backend or simulator has been used.

// not provable, on which backend software was run due to inherent noise + every backend should ideally return the same result.

// use machine learning for learning the inherent noise model of different simulators + quantum computers.
// black-box models

//TODO: Threat model, assumptions about infrastructure (#qubits, capabilities of adversary)
//TODO: capabilities of user/"defender"/"center" -> can choose circuits that will be executed.
//TODO: motivate approach -> why not exactly provable? verification?
//TODO: why ml?
//TODO: what is the motivation in @martinaLearningQuantumNoiseFingerprint2023 for picking these circuits?
// Why this specific quantum circuit has been chosen is being detailed in @circuit.

== Data for Training
The measurement results from a quantum computer are taken from @martinaLearningQuantumNoiseFingerprint2023.
The reason is that no access to a quantum computer was available during the creation of this thesis.
// as mentioned in @structure ...
//TODO: expensice, challenging to perform measurement with in qc calibration -> out of scope
The QC measumerent data has been obtained by running the circuit described in @circuit on 7 different IBM quantum machines (Athens, Santiago, Casablanca, Yorktown, Bogota, Quito, Lima).
//TODO: The chips differ by two main aspects. The first is the architecture (or connectivity) of the qubits, which ranges from a simple line topology to a ladder or a star topology. The second important difference is the so-called quantum volume [36] (8, 16, 32 for the machines used in our experiments) that quantifies the maximum dimension of a circuit that can be effectively executed, and is correlated also with the noise affecting each device.
// source for [36]: Validating quantum computers using randomized model circuits.
// Indeed, some quantum machines are inherently noisier than other, and even single qubits inside a machine can have a distinctive noise profile. All these peculiar differences in noise and topology represent the fingerprint that we aim to exploit using our method.
Each circuit measurement in the dataset can be traced back to the quantum computer it was executed on.
The simulation data for this work was created by simulating the identical quantum circuits from @martinaLearningQuantumNoiseFingerprint2023 both with and without noise.
The simulators provided by the Qiskit SDK @Qiskit2024 were used.

=== Circuit <circuit>
//The circuits used in this thesis are taken from Martina et al. in _Noise Fingerprints in Quantum Computers_, 2022. 
The circuit designs implemented within this thesis are derived from the work of Martina et al., as documented in their 2022 publication, "Noise Fingerprints in Quantum Computers".//TODO: correct citation?
The different circuits get generated by the algorithm described in @circuit-algorithm.
The idea behind the quantum circuit is to simulate quantum transport dynamics in a quantum computer.
A quantum particle is initiated in state $|0000 angle.r$ and "flows" through the circuit via the influence of various quantum gates, including CNOT and Toffoli gates @martinaLearningQuantumNoiseFingerprint2023.
After the first two Hadamard gates and the CNOT gate, qubits $q_0$ and $q_2$ are entangled in the bell state.
Qubits $q_2$ and $q_3$ are used to track the particle's position.
They can return binary pairs of $00_2$, $01_2$, $10_2$, and $11_2$ first bit corresponding to $q_2$ and second bit to $q_3$ when measured. //TODO: use 00_2 or (0,0)?
Qubits $q_0$ and $q_1$ are ancilla qubits, with the only purpose of controlling the other qubits.

#algorithm(
  caption: [Generation of quantum circuts for different measurement steps. Code for circuit generation stems from Martina et al. in _Noise Fingerprints in Quantum Computers_, 2022], //TODO: correctly cited?
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

In order to measure the circuit at different points, @circuit-algorithm is executed with $k=1$ up to $k=9$, which results in 9 measurement points for this ciruit.
The circuit corresponding to the first measurement step can be seen in @circuit-measurement-step-1. 
The entire circuit, corresponding to measurement step 9, is depicted in @circuit-measurement-step-9.
Measurements are performed by applying the Pauli Z operator on qubits $q_2$ and $q_3$ after each execution, see the end section of @circuit-algorithm.
Due to the wavefunction collapse, the circuit has to be regenerated, reexecuted, and measured for each measurement step $k$.
Consequently, this approach does not employ repeated measurements as utilized in a quantum monitoring protocol or within the framework of Zeno quantum dynamics @gherardiniErgodicityRandomlyPerturbed2017 @fischerObservationQuantumZeno2001 @schaferExperimentalRealizationQuantum2014.
For a single measurement step with $k=1$, all four qubits ($q_0$, $q_1$, $q_2$, and $q_3$) are each initialized in state $|0 angle.r$.
Measuring the circuit in this state would result in $00_2$.
Upon initialization, two Hadamard gates are applied to qubits $q_0$ and $q_1$, as documented by @circuit-measurement-step-1.
Following this, a CNOT gate operation is executed with $q_0$ as controll qubit, operating on $q_2$.
Subsequently, the measurement of qubit $q_2$ yields a binary outcome of 0 or 1 with equal probability, reflecting a 50% chance for each outcome, while the measurement of $q_3$ still returns 0.
Of course, these results will only occur under ideal circumstances.
On current NISQ devices noise falsifies these measurement outcomes.
The goal of the approach in this thesis is to make use of this noise in order to distinguish between quantum computers and simulators based on their noise profile.
With an increasing number of gates, the amount of noise slowly accumulates. //TODO: add more information? this is one of the reasons, why we measure at different steps in the circuit.

All circuits for measurement steps in between are in the appendix (see @appendix).
#figure(
  image("images/walker-step-1.svg", height: 20%),
  caption: "Circuit which corresponds to measurement step 1."
) <circuit-measurement-step-1>
#v(10pt)
#figure(
  image("images/walker-step-9.svg"),
  caption: "Circuit which corresponds to measurement step 9. Complete circuit with four qubits. Only the lower two qubits are being measured at the end. Grey separators mark points at which measurements can take place."
) <circuit-measurement-step-9>
#v(10pt)
Each circuit run has been performed with 8000 shots.
The data gathered from measuring one circuit run at 9 different steps with 8000 shots look like @measurement-data-table.

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
  caption: "Measurement examples for one run with 8000 shots. There exist 250 measurement tables for each quantum computer and simulator used in this thesis." //TODO: improve caption
) <measurement-data-table>

=== Executions on Simulator
Seven different Qiskit simulators are utilized to obtain the simulated data.
Only one backend calculates a noise-free result because different simulator implementations without noise deliver similar results.
In order to obtain a comparable order of magnitude of simulated data to that of QC-generated data, six additional simulators with noise are used.
All six backends are each utilizing a different noise model based on calibration data collected from real IBM quantum computers @Fake_provider.
The following fake backends were used: Vigo, Athens, Santiago, Lima, Belem, Cairo.
Three of these fake backends are based on configurations of quantum computers which were used for creating training data in order to account for a adversarial cloud provider trying to mimic some specific quantum computer.
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
                size: (10, 12),
                label-key: 0,
                value-key: (..range(1, 7)),
                bar-width: 1,
                x-tick-step: 0.01,
                bar-style: cetz.palette.new(colors: (rgb("#41bfaa"), rgb("#466eb4"), rgb("#00a0e1"), rgb("#e6a532"), rgb("#d7642c"), rgb("#af4b91"))),
                simulator_readout_error_data,
                labels: ([Athens], [Belem], [Cairo], [Lima], [Santiago], [Vigo]),
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
  ([Athens],0.011112942844963669),
  ([Belem],0.016558485595031758),
  ([Cairo],0.025727626602790654),
  ([Lima],0.008339674869236618),
  ([Santiago],0.006299998381426697),
  ([Vigo],0.012012477900732316),
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
    caption: [Error rates for the CNOT gate in different simulators. Qubit $q_0$ is the controll and $q_1$ is the target qubit for the error rates.]
) <simulator-cnot-error-rate>

All these different errors accumulate when simulating a quantum circuit.
Due to the fact, that these error rates stem from the calibration data of actual quantum computers, the overall noise-model is quite complex, but within the error range of real quantum computers. //TODO: is this last sentence good?

== Machine Learning Approaches <machine-learning-approaches>
Machine learning stands out as the preferred approach for distinguishing between simulators and quantum computers primarily because it does not necessitate quantum noise modeling nor the control of the quantum circuit with time-dependent pulses @mullerInformationTheoreticalLimits2022.
This characteristic makes machine learning approaches exceptionally well suited for this task, offering a "black-box" model that can effectively classify based on measurement results without intricate details of the underlying processes.
Quantum systems have already been succesfully analyzed by machine learning methods .
Machine learning has already been succesfully utilized to analyze quantum systems @youssryQuantumNoiseSpectroscopy2020 and to efficiently learn quantum noise @harperEfficientLearningQuantum2020.

The three machine learning methods used in this thesis are used as classifiers
$ "Classifier" f: X -> C $
where $f$ is the machine learning method used.
The output $C$ consists of two different classes:
$ C = {0, 1} = {`"Quantum Computer"`, `"Simulator"`} $
The input data $X$ has been preprocessed to contain the probability distributions per step for the four possible measurement result values ($0$, $1$, $2$, $3$). //TODO: use 00_2, 01_2, ... as measurement results?
How exactly the input $X$ gets prepared is detailed in the following:
Three different variables influence the input data, the number of shots $s in NN$ (in this thesis $s = 8000$), the measurement step $k = [1, 9]$, and the window size $w in {t in NN | s mod t = 0}$.
The measurement step $k$ corresponds with the measurements taken on the $k^"th"$ circuit (for $k=1$, see @circuit-measurement-step-1, etc.) //TODO: etc. ok?
Initially, the preliminary input data consists of a matrix $M$ containing all measurements at specific measuremnt steps (for one quantum computer/simulator with all measurement steps from 1 up to $k$ performed).
The matrix row accounts for the shots and the column for the measurement step $k$.
Therefore, the matrix $M$ has dimension $s times k$.
The window size $w$ defines, how many rows of $M$ get aggregated together into one row.
Aggregation is performed by counting, how often each value of $m_(i,j)$ occurs in $w$ rows.
The resulting matrix $D$ has dimension $s/w times k$.
Elements in $D$ are ordered tuples consisting of four elements:
$ d_(i,j) = (c_1, c_2, c_3, c_4) $
where $c_q$ represents, how often the measurement result $q$ has been counted.
$ "For" d_(i,j) in.rev c_q = sum_(l = i)^(i + w) bb(1)_q (m_(l,j)) $
where $bb(1)_q$ is the indicatior function with $bb(1)_q (n) = 1$ and otherwise $bb(1)_q = 0$.
Afterwards, every value in $D$ gets divided by $w$ for normalization which improves the training of the feedforward neural net and the convolutional neural net due to the smaller numbers: //TODO: improve + add reference?
$ d_(i,j) = (c_1/w, c_2/w, c_3/w, c_4/w) $
As last step, each row in the matrix $D$ gets converted into a ordered tuple and added to $X$, the set of inputs:
$ X = {(d_(i,1), d_(i,2), dots , d_(i,k)) | 1 <= i <= s} $
Therefore, $X$ is a set of ordered tuples, each consisting of 1 up to 9 orderdt tuples with four values each.

The following example with $s = 6$ and $k = 2$ depicts the complete conversion from initial measurement data ($M$) to the input data for the classifier ($X$):
$ M = mat(1, 2; 1, 1; 3, 3; 1, 0; 1, 2; 1, 1) $
With $w = 3$ we get: (aggregation and normalization in one step)
$ D = mat((0, 2/3, 0, 1/3), (0, 1/3, 1/3, 1/3); (0, 1, 0, 0), (1/3, 1/3, 1/3, 0)) $ //TODO: maybe highlight with color what gets aggregated to what.
In the tuple $d_(1,1) = (0, 2/3, 0, 1/3)$, the first $0$ means "zero of the first $w$ (in this case 3) shots contained the measurement result of $0$". \
This results in:
$ X = {((0, 2/3, 0, 1/3), (0, 1/3, 1/3, 1/3)), ((0, 1, 0, 0), (1/3, 1/3, 1/3, 0))} $

For $k=3$, each ordered tuple $x in X$ would contain 3 different sub-tuples such that $x = (x_1, x_2, x_3)$.
$X$ can contain the probability distribution-data accumulated from multiple runs from different quantum computers or simulators.

In the following machine learning approaches, in case no window size is mentioned, these models where trained and evaluated with data preprocessed with a window size of 2000.
This value has been taken from @svm-window-size-vs-step-range, @fnn-window-size-vs-step-range, and @cnn-window-size-vs-step-range because it shows a high accuracy even with a low amount of measurement steps accross models, allowing for an easier comparison.

=== Support Vector Machine

To optimize the selection of the support vector machine algorithm for training, 20% of the dataset is allocated for preliminary evaluation.
This evaluation process involves comparing the performance, specifically accuracy, of multiple potential SVM algorithms: linear, polynomial, and radial basis function.
During this phase, the algorithm demonstrating superior accuracy is then selected for further training.
This makes it possible to achieve high accuracies even for complicated input data while trying to keep the computational cost low.
The chosen algorithm undergoes training on 60% of the input data, and its performance is subsequently assessed using the remaining 20% of the data to ensure its efficacy and reliability.
The selection process for the SVM algorithm is similar to @martinaLearningNoiseFingerprint2022.

=== Feedforward Neural Net <approach-ffnn>
//TODO: add architecture diagram
//TODO: add training curves.
//TODO: mention keras + tensorflow used
The feedforward neural net was trained on 80% of the dataset, 20% were used for evaluationg the accuracy of the model.
The input layer of the neural network was designed to be variable, accommodating between 4 to 36 neurons, depending on the number of measurement steps that are included in the dataset.
This flexibility was needed to be able to compare different amounts of measurement steps, see @fnn-window-size-vs-step-range.
The architecture included two dense hidden layers containing 45 and 20 neurons, respectively, utilizing the hyperbolic tangent (tanh) activation function.
//TODO: used relu function because it yielded higher accuracy when comparing between relu, sigmoid and than with keras tuner.
Increasing the amount of neurons didn't yield any noticable increase in accuracy, the number of neurons was determined by utilizing the keras tuner and manual trial and error afterwards.
The output layer was constructed with a single neuron, employing a sigmoid activation function to produce a probability output between 0 and 1, indicative of the data source being a simulator or a quantum computer, respectively.

For the training process, the Adam optimizer was selected.
The loss during training was quantified using binary cross-entropy, the standard choice for binary classification problems.

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_1_val_accuracy.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: 0.4, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_1_val_loss.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: 0.25, y-max: 0.75,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Validation acc (left), Validation loss (right). Only Trained on measurement step 1 (window size 2000).] //TODO: ausarbeiten
)

//TODO: mention early stop (after epoch 5 when acc over 99.9%)
//TODO: mention early stop after no improvement in val_loss for 3 epochs

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_fnn_step_5_val_accuracy.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
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

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: 0.01, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: -0.003, y-max: 0.04,
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Validation acc (left), Validation loss (right). Only Trained on measurement steps 1 up to (including) 5 combined  (window size 2000).] //TODO: ausarbeiten
)

Training was conducted over five epochs with a batch size of 32, balancing computational efficiency and the model's ability to learn from the training data.
Observations indicated that extending the training beyond five epochs did not significantly improve accuracy, suggesting an optimal learning plateau had been reached within the given epoch span.
After training, the model's accuracy was evaluated by using the previously unseen test data.
This configuration led to the model's successful differentiation between the two data sources, see @evaluation-ffnn.

=== Convolutional Neural Net
A convolutional neural network model was developed, utilizing a dataset divided into 80% for training and 20% for testing.
The input layer of the model was designed to be adaptable, accommodating a variable number of neurons ranging from 4 to 36, depending on the number of measurement steps incorporated in the dataset, similar to @approach-ffnn.
The first layer contains 30 1-dimensional convolutional filters, each with a kernel size of 3, using the Rectified Linear Unit (ReLU) activation function.
//TODO: used relu function because it yielded higher accuracy when comparing between relu, sigmoid and than with keras tuner.
//TODO: better explain, how the keras tuner was used.
Following the convolutional layer, a 1-dimensional max pooling operation was applied, reducing the dimensionality of the data.
After the max pooling, the network architecture includes a flattening step, transforming the pooled feature maps into a single, linear vector.
This flattened vector was then fed into two additional hidden layers, comprising 64 and 32 neurons, each employing the ReLU activation function to further process and refine the features extracted from the input data.
Increasing the amount of neurons or the number of convolutional filters didn't result in a noticable increase in accuracy.
For finding a general structure, the keras tuner was utilized.
Afterwards the values where finally adjusted by hand per trial and error.
The final stage of the model was an output layer consisting of a single neuron utilizing a sigmoid activation function.
This setup is particularly suited for binary classification tasks, as it produces a probability output in the range of 0 to 1, indicative of the class membership of the input data.

//TODO: add accuracy and loss for trainings-data as well? (inside same chart, different color).

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_1_val_accuracy.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: 0.4, y-max: 1.05,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Accuraccy",
      {
        plot.add(fnn_val_acc.map(((epoch,acc)) => (int(epoch), float(acc))))
      })
    }),

    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_1_val_loss.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: 0.25, y-max: 0.75,
        y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Validation acc (left), Validation loss (right). Only Trained on measurement step 1 (window size 2000).] //TODO: ausarbeiten
)

//TODO: mention early stop (after epoch 5 when acc over 99.9%)
//TODO: mention early stop after no improvement in val_loss for 3 epochs

#figure(
  grid(
    columns: 2,
    gutter: 35pt,
    cetz.canvas(length: 1cm, {
      import cetz.draw: *
      import cetz.plot

      let fnn_val_acc = csv("data/training_history/history_cnn_step_5_val_accuracy.csv")

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: none, 
        x-min: -5,
        x-label: "Epoch no.",
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

      plot.plot(size: (5,5), x-tick-step: 50, y-tick-step: 0.01, 
        x-min: -5,
        x-label: "Epoch no.",
        y-min: -0.003, y-max: 0.04,
        y-label: "Loss",
      {
        plot.add(fnn_val_acc.map(((epoch,loss)) => (int(epoch), float(loss))))
      })
    }),
  ),
  caption: [Validation acc (left), Validation loss (right). Only Trained on measurement steps 1 up to (including) 5 combined  (window size 2000).] //TODO: ausarbeiten
)

//TODO: mention that 100 epochs is not the optimum, but the best balance for computational cost vs accuracy.

The Adam optimizer and binary cross-entropy were employed for optimization and loss calculation, respectively.
Binary cross-entropy is a standard loss function for binary classification problems, measuring the discrepancy between the predicted probabilities and the actual class labels.
The model underwent training in five epochs, with observations indicating that further extending the training duration beyond this period did not yield significant improvements in model accuracy.
This suggests the model reached an optimal learning plateau within the specified epoch count.
Post-training, the model's performance was evaluated using the previously unseen test data to measure its generalization capability, see @evaluation-cnn.


== Adversarial Machine Learning with Fast Gradient Sign Method
For the adversarial attack the goal is to measurements from a simulator, perform the Fast Gradient Sign Method on them and show that they are classified as 'has been run on a quantum computer' afterwards.
The model used was a feedforward neural net (as described in @approach-ffnn) which has been trained on 80% of all available simulator and quantum computer data, containing all 9 measurement steps.
The remaining 20% were used for measuring the model accuracy beforehand.
All 9 measurements were included to achieve the highest accuracy and robustness against unknown quantum computer inputs (see @adversarial-accuracy). 
This was done by taking the gradient of the loss with respect to the input feature.
The sign of the gradient is used to create a perturbation on the given input feature.
In order to keep the perturbation small, it is multiplied by a small number $epsilon$ and added onto the original input (see @adversarial-sample-expression).
In order to produce valid values, the adversarial sample gets clipped such that only values between 0 and 1 are allowed.
Additionally, subsequent packs of four values each get normalized to sum up to 1, making sure they represent valid probabilistic distributions.
Through this attack it was possible to get the model to label measurements generated by a simulator as quantum computer generated.
See @evaluation-fgsm for a detailed evaluation.

= Evaluation <evaluation>
For each model, three different evaluations have been performed:
1. an accuracy comparison for different window size and measurement step ranges.
2. the impact of excluding one quantum computer and using only the excluded quantum computer as test data.
3. excluding at least one and up to four quantum computers and using exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated.

// TODO: ist es ok, die Auswertung eher allgemein vor den einzelnen Auswertungen zu schreiben?
#text(blue)[TODO: ist es ok, die Auswertung eher allgemein vor den einzelnen Auswertungen zu schreiben?]

The first comparison of accuracy for different window size and measurement step ranges shows how an increased number of measurement steps is increasing the accuracy.
Especially when training only on a combination of the first three measurement steps and using window sizes of 2000, every model is able to reach an accuracy of 98% or above.
As explained in @machine-learning-approaches for the rest of the evaluation a window size of 2000 was chosen.

The second and third tables show how well the different models can generalize to unseen quantum computers.
Even when four different quantum computers are excluded from the training set, all three models achieve accuracy of more than 90% when taking all 9 measurement steps into account.
The fourth and fifth tables display the accuracy when excluding different simulator backends.
When including measurement steps 1 up to 3, all three models are classifying more than 93% of test samples correctly.  
The tables excluding the quantum computers or simulator backends are relevant for the usecase when trying to safeguard against adversarial quantum cloud providers.
In this case, most of the simulators and quantum computers will be unknown.
When using only one measurement step, accuracy values are on average below 20% for all models, regardless of the number of excluded quantum computers.
When excluding simulators, the number of excluded simulator backends has a greater influence on the output accuracy, compared to excluded quantum computers. 
Excluding only one simulator backend results in at least 30% accuracy accross all models at measurement step one.
The classification task is only binary classification, meaning the models are performing worse than making random guesses.
Therefore it seems especially crucial to have multiple measurement steps when dealing with unseen data.

//TODO: combine data into single diagram for easier comparison? -> only show window sizes 5, 50 and 2000 (but for each approach).
// maybe add tables for step range vs window size only to appendix?

== Support Vector Machine
For the SVM, window sizes start from 50 (and not from 5 like the other models), because training the SVM with such small window sizes took too much time.
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
  caption: "Support vector machine: Comparison of the accuracy for different window sizes and measurement step ranges. Circuit run-data from all quantum computers and all simulators was used.",
  kind: table,
) <svm-window-size-vs-step-range>

#let svm_exclude_single_qc = csv("data/svm_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded QC*],..svm_exclude_single_qc.flatten().slice(1,)
  ),
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy.",
  kind: table,
)

#let svm_exclude_multiple_qcs = csv("data/svm_exclude_multiple_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded QCs*],..svm_exclude_multiple_qcs.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated.",
  kind: table,
)

#let svm_exclude_single_simulator = csv("data/svm_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded Simulator*],..svm_exclude_single_simulator.flatten().slice(1,)
  ),
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy.",
  kind: table,
)

#let svm_exclude_multiple_simulators = csv("data/svm_exclude_multiple_simulators_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded Simulators*],..svm_exclude_multiple_simulators.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated.",
  kind: table,
)

== Feedforward Neural Net <evaluation-ffnn>
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
  caption: "Feedforward neural net: Comparison of the accuracy for different window sizes and measurement step ranges. Circuit run-data from all quantum computers and all simulators was used.",
  kind: table,
) <fnn-window-size-vs-step-range>

#let ann_exclude_single = csv("data/neural_net_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded QC*],..ann_exclude_single.flatten().slice(1,)
  ),
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy.",
  kind: table,
)

#let ann_exclude_multiple = csv("data/neural_net_exclude_multiple_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded QCs*],..ann_exclude_multiple.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated.",
  kind: table,
)

#let ann_exclude_single_simulator = csv("data/neural_net_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded Simulator*],..ann_exclude_single_simulator.flatten().slice(1,)
  ),
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy.",
  kind: table,
)

#let ann_exclude_multiple_simulators = csv("data/neural_net_exclude_multiple_simulators_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded Simulators*],..ann_exclude_multiple_simulators.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated.",
  kind: table,
)

== Convolutional Neural Net <evaluation-cnn>
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
  caption: "Convolutional neural net: Comparison of the accuracy for different window sizes and measurement step ranges for the convolutional neural net. Circuit run-data from all quantum computers and all simulators was used.",
  kind: table,
)

#let cnn_exclude_single = csv("data/cnn_excluded_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded QC*],..cnn_exclude_single.flatten().slice(1,)
  ),
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy.",
  kind: table,
) <cnn-window-size-vs-step-range>

#let cnn_exclude_multiple = csv("data/cnn_exclude_multiple_quantum_computer_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded QCs*],..cnn_exclude_multiple.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated.",
  kind: table,
)

#let cnn_exclude_single_simulator = csv("data/cnn_excluded_simulator_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*Excluded Simulator*],..cnn_exclude_single_simulator.flatten().slice(1,)
  ),
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy.",
  kind: table,
)

#let cnn_exclude_multiple_simulators = csv("data/cnn_exclude_multiple_simulators_vs_step_ranges_all_other_backends_combined.csv")
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
    [],colspanx(9)[*Step Ranges*],[*\# of Excluded Simulators*],..cnn_exclude_multiple_simulators.flatten().slice(1,)
  ),
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated.",
  kind: table,
)

== Adversarial Machine Learning with Fast Gradient Sign Method <evaluation-fgsm>
//TODO: "defense" against fgsm complicated, because distribution values actually approach real quantum computer values. Not even a human could correcly determin the class (im gegensatz su fgsm bei bildern).
By converting 1400 samples generated by simulators into adversarial samples in such a fasion that they are recognized as 'generated by a quantum computer'.
The result can be seen in @adversarial-accuracy.
When epsilon is zero the adversarial sample equals the original input sample.
The graph shows that with increased $epsilon$ values, the accuracy gets worse due to the increased perturbation in the adversarial sample.

#figure(
  cetz.canvas(length: 1.5cm, {
    import cetz.draw: *
    import cetz.plot

    let adversarial_accuracy_data = csv("data/walker_adversarial_attack_simulator_to_quantum.csv")

    plot.plot(size: (10,5), x-tick-step: none, y-tick-step: none, 
      x-ticks: (adversarial_accuracy_data.map(((epsilon,acc)) => float(epsilon))),
      x-decimals: 3,
      x-label: "Epsilon",
      y-min: 0, y-max: 1.05,
      y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
      y-label: "Accuraccy",
    {
      plot.add(adversarial_accuracy_data.map(((epsilon,acc)) => (float(epsilon), float(acc))))
    })
  }),
  caption: "Comparison of the models accuracy on adversarial samples with different epsilon values. 1400 samples were converted to adversarial samples for this graph. The larger the epsilon value gets, the larger the perturbation in the adversarial sample.",
  kind: table,
) <adversarial-accuracy>

// TODO: alle histogramme zeigen, oder nur eine Auswahl?
#text(blue)[TODO: alle histogramme zeigen, oder nur eine Auswahl?]

The histograms in @adversarial-samples-histogram-measurement-step-1 to  @adversarial-samples-histogram-measurement-step-8 visualize the probabilities for each measurement result at different measurement steps in the quantum circuit.
In most cases an increase of $epsilon$ leads to a probability distribution which is closer to the distribution of a quantum computer.

#figure(
  image("images/adversarial_samples_histogram/legend.svg"),
  caption: "Legend for the following figures depicting histograms."
) <adversarial-samples-histogram-legend>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_0_adversarial.svg"),
  caption: [Comparison of different epsilon values for the first measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-1>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_1_adversarial.svg"),
  caption: [Comparison of different epsilon values for the second measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-2>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_2_adversarial.svg"),
  caption: [Comparison of different epsilon values for the third measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-3>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_3_adversarial.svg"),
  caption: [Comparison of different epsilon values for the fourth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-4>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_4_adversarial.svg"),
  caption: [Comparison of different epsilon values for the fifth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-5>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_5_adversarial.svg"),
  caption: [Comparison of different epsilon values for the sixth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-6>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_6_adversarial.svg"),
  caption: [Comparison of different epsilon values for the seventh measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-7>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_7_adversarial.svg"),
  caption: [Comparison of different epsilon values for the eighth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-8>
#figure(
  image("images/adversarial_samples_histogram/hist_walker_step_8_adversarial.svg"),
  caption: [Comparison of different epsilon values for the ninth measurement step. As a refference, the average of all quantum computer probability distributions is plotted as well. For the legend see @adversarial-samples-histogram-legend]
) <adversarial-samples-histogram-measurement-step-9>

It is possible for a malevolent quantum cloud provider to perform such an adversarial attack.
Even though, it is quite hard to pull off due to the fact, that FGSM is a white-box attack.
As a result, the neural net which should differenciate between simulator and quantum computer has to be known by the malevorent quantum cloud provider.

== Limitations <limitations>
The main limitation of this work is, that classification can only be performed with the circuit from  @circuit.
This is due to the fact, that different quantum circuits result in different distributions of measurement results.
Despite this limitation, it is possible to utilize this approach for simulator detection.
In order to achieve this, the circuit from @circuit gets sent to the (possibly adversarial) quantum cloud provider.
The results get classified in order to determine whether the circuit has been run on a quantum computer or simulated on a classical computer.
It would be possible for the quantum cloud provider to recognize this specific circuit, route the circuit to a legit quantum computer provider, and forward the results to the end user.
To prevent this, the circuit could be embedded into the circuit which the user wants to execute.

Additionally, as shown in @evaluation-fgsm, it is possible to forge adversarial samples which get classified with the incorrect label.
One way to prevent such a white-box adversarial attack is to keep the trained neural net hidden.

//TODO: only trained with quantum computer date from ibm (only one quantum computer architecture)
//TODO: only one source of simulators (qiskit)
//TODO: future work: compare different quantum computer architectures + simulators?

= Future Work <future-work>
One possible improvement would be to showcase that this approach can distinguish between simulators and quantum computers for other quantum circuits than the one used in this work (@circuit).
Moreover it would be interesting to explore how adding additional samples from different (and possibly more modern) quantum computers would influence the accuracy.
Also, it could be interesting to perform further, more advanced adversarial attacks on the neural net, such as a trying to perform a adversarial patch attack @brownAdversarialPatch2018.

= Conclusion <conclusion>
This thesis goes to show that it is possible, with current machine learning algorithms, to predict with a high probability for an existing quantum circuit whether it was executed by a quantum computer or by a simulator backend.
The machine learning models proposed in this thesis can not generalize to other arbitrary quantum circuits.
Despite that, it is probably possible to use the proposed approach in this thesis for classifying the results from different quantum circuits (see @future-work).
When taking the limitations shown in @limitations into account, this approach can be used as a usefull indicator for validating that the correct backend types has been used for executing a quantum circuit. 

#pagebreak()

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

#pagebreak()

#bibliography("Sources.bib")