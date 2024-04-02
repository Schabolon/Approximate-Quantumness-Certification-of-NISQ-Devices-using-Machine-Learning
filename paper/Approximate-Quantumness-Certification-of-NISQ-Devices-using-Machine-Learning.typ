#import "@preview/cetz:0.2.2"
#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#set heading(numbering: "1.1.")
#set page(numbering: "1")
#set par(justify: true)

#outline()

// Fragen:
// - Braucht die Bibliography eine Überschriften-Nummer?
// - Soll Figure 1 noch weitere Schritte bekommen? (Result -> User)
// - write in 3rd person? 
// - wird der Code mitbewertet?
// - Ressourcen für die Präsentation (einfach Arbeit vorstellen + Fragen?)
// - In welcher Sprache sollte die Präsentation gehalten werden?

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
This scenario primarily affects small circuits due to the exponential growth in dimensions, rendering larger circuits impractical for computation with classical hardware.

// TODO
#text(blue)[TODO ist quantum supremacy überhaupt relevant?]

In 2020, a research team led by scientist Jian-Wei Pan at the University of Science and Technology of China (USTC) achieved quantum supremacy using 76 photons for the Gaussian boson sampling algorithm @garistoLightBasedQuantumComputer2021.
The samples generated in the study required 200 seconds, a task estimated to take a classical supercomputer 2.5 billion years to complete, as detailed in the paper @zhongQuantumComputationalAdvantage2020.
Quantum supremacy marks the point at which quantum computers outperform classical computers in specific tasks.
However, apart from these highly specialized setups, it is still possible to simulate small quantum circuits.
As of 2023, a rough cost estimate for a 9-qubit quantum computer from Rigetti stands at \$900,000 @mechanicRigettiLaunchesNovera2023.
Conversely, simulators can execute small circuits on consumer hardware, drastically reducing the cost barrier for executing quantum computations.
This cost consideration, coupled with the scalability limitations of classical hardware, underscores the significance of the threat posed by cloud quantum providers employing simulators, particularly in scenarios where the users are unaware of this substitution.
Therefore, mitigating strategies should be devised to ensure transparency and trust in quantum cloud services to safeguard against potential security breaches and ensure the integrity of quantum computations.

This work provides a machine learning-based approach that allows the users of cloud-based QCs to verify with high certainty that their quantum circuit has been executed on a quantum computer and not simulated on a classical computer.

== Related Work <related-work>
Previous work has shown that it is possible to generate a unique hardware fingerprint based on the qubit frequencies. The fingerprint is based on quantum computer calibration data, which was made available by the cloud provider @smithFastFingerprintingCloudbased2022.
A different research group has developed a Quantum Physically Unclonable Function (QuPUF).
By utilizing the QuPUF, it is possible to identify the quantum computer the QuPUF was executed on @phalakQuantumPUFSecurity2021.
Another approach uses a tomography-based fingerprinting method based on crosstalk-induced errors @miShortPaperDevice2021.

Martina et al.'s paper "Noise fingerprints in quantum computers: Machine learning software tools" distinguishes which QC a specific quantum circuit has been executed by learning the error fingerprint using a support vector machine @martinaLearningNoiseFingerprint2022.

This paper takes a similar approach to "Noise fingerprints in quantum computers: Machine learning software tools" by Martina et al. @martinaLearningNoiseFingerprint2022 and utilizes the same quantum circuit.
However, instead of differentiating between various quantum computers, this paper creates machine learning models that distinguish whether a quantum circuit was executed by a QC or a simulator on a classical computer.

== Structure
@terms-and-definitions gives a short overview of the most important concepts of quantum computing and machine learning used in this paper.
In @approach, an explanation for the dataset based on the circuit measurements is provided.
These are used for training different machine learning algorithms in order to differentiate whether a quantum circuit has been executed by a quantum computer or simulated by a classical computer.
Additionally, a white-box adversarial attack is performed.
After that, in @evaluation, the accuracies of the different machine learning algorithms are compared, and the limitations of this work are discussed, specifically concerning the white-box adversarial attack.
@future-work points out possible areas for further research.
At the end, @conclusion contains a short conclusion.


= Terms and Definitions <terms-and-definitions>
This section provides a brief introduction to quantum computing and machine learning ideas.

== Quantum Computing
A quantum computer leverages quantum bits (qubits).
Qubits have two basis states $|0 angle.r = [1, 0]^top$ and $|1 angle.r = [0, 1]^top$.
The notation with '$| med angle.r$' is called Dirac notation.
Classical bits are either 0 or 1.
Conversely, qubits can be in states other than $|0 angle.r$ and $|1 angle.r$.
A superposition is denoted as a linear combination of states, as in @superpositon-linear-combination.
#figure(
  $ |psi angle.r = alpha|0 angle.r + beta|1 angle.r $,
  caption: "A qubit state is written as a linear combination of the two basis states."
) <superpositon-linear-combination>
In @superpositon-linear-combination $alpha$ and $beta$ are complex values and describe probability amplitudes.
The probabilities must satisfy the normalization condition $|alpha|^2 + |beta|^2 = 1$.
It is possible to solve a specific selection of problems with reduced time and space complexity by leveraging quantum properties such as superposition, interference, and entanglement.
One example of such a quantum algorithm is Shor's algorithm @shorPolynomialTimeAlgorithmsPrime1997.
This paper's circuits consist of the Pauli-X gate, the Hadamard gate, the Controlled not gate (CNOT), and the Toffoli gate. Their respective circuit representation can be seen in @quantum-gates.
The Pauli-X gate performs a base flip on a single qubit.
The CNOT gate performs a base flip on the target qubit, depending on the state of the control qubit.
Similarly, the Toffoli gate has two control qubits, influencing whether the target qubit gets flipped.
#figure(
  grid(
    columns: 4,
    align(horizon, image("images/gates/pauli-x.svg", width: 50%)),
    align(horizon, image("images/gates/hadamard.svg", width: 50%)),
    align(horizon, image("images/gates/cnot.svg", width: 40%)),
    align(horizon, image("images/gates/ccx.svg", width: 30%))
  ),
  caption: "Quantum gates (from left to right): Pauli-X gate, Hadamard gate, Controlled not gate, Toffoli gate."
) <quantum-gates>
In quantum computing, measuring a qubit yields a binary outcome: either a $0$ or a $1$.
This measurement process is a critical operation that leads to the collapse of the qubit's wave function, situating it into a definitive state of either $|0\rangle$ or $|1\rangle$, depending on the measured value.
This collapse is a direct consequence of the quantum mechanical principle of wave function collapse, where measurement forces a quantum system to 'choose' a state from among the probabilities described by its wave function prior to measurement.
Additionally, the concept of "shots" in quantum computing refers to the number of iterations a quantum algorithm is executed.
The rationale behind multiple shots is to compile a statistical distribution of outcomes, which is instrumental in approximating the quantum state prior to measurement.
This statistical approach is crucial due to the probabilistic nature of quantum measurements, where repeated executions help accurately estimate the likelihood of each possible outcome, thereby providing insight into the quantum system's behavior before measurement @nielsenQuantumComputationQuantum2010.

Different approaches exist for building physical quantum computers.
QCs built by IBM are based on superconducting qubit technology @QuantumSystemInformation.
Other architectures include trapped ions, photonics, and nuclear magnetic resonance @laddQuantumComputers2010.
Current quantum chips mainly suffer from decoherence, gate errors, readout errors, and crosstalk.
For a qubit, the decoherence time refers to how long the qubit can contain information.
Decoherence can occur, for example, when a qubit interacts with the environment.
When quantum computers are constructed from multiple qubits, unwanted interactions between these qubits are called crosstalk.

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
Its position and orientation are determined to maximize the distance between the hyperplane and the nearest data point from either class.
This approach ensures the best possible separation between classes and enhances the algorithm's generalization capabilities.
// TODO eventuell kürzen??
However, real-world data is often not linearly separable.
To overcome this limitation, SVMs employ a technique known as the kernel trick.
A linear decision boundary can be found by mapping the input features into a higher dimensional feature space.
The kernel trick allows SVMs to construct a non-linear decision boundary in the input space, thereby enabling the classification of complex datasets.
As a result, SVMs are computationally efficient and particularly suited for handling high-dimensional data.
See @cristianiniIntroductionSupportVector2000 for additional details.

=== Feedforward Neural Network
A feedforward neural network (FNN) is an artificial neural network commonly used for various machine learning tasks, including classification, regression, and pattern recognition.
It passes input data through a series of interconnected layers of nodes, known as neurons or perceptrons, where each neuron performs a weighted sum of its inputs combined with a bias and applies an activation function to produce an output, which can be written as seen in @perceptron-math.

#figure(
  grid(
    columns: 1,
    gutter: 2mm,
    $ y = f(sum_(i=1)^(n) w_i x_i + b) $,
    v(1pt), // add space between math expression and explanation
    (align(left, text[where:])),
    (align(left, text[
      - $y$: perceptron output
      - $x$: input vector
      - $f$: activation function
      - $w_i$: weight for input $x_i$
      - $b$: bias
    ])),
    v(1pt) // adds space between explanation and caption

  ),
  caption: "Equation for a single perceptron."
) <perceptron-math>

Each neural network consists of multiple neurons, which are grouped into layers.
The first layer, the input layer, receives the initial input data.
After the input layer, subsequent layers are known as hidden layers, where complex transformations of the input data occur.
Finally, the results are taken from the last layer, the output layer, which provides the network's final output.
See @feedforward-net for a visualization.

#figure(
  image("images/feedforward-neural-network.svg", height: 25%),
  caption: "Feedforward neural net"
) <feedforward-net>

During training, the network adjusts the weights of connections between neurons to minimize the loss function, which quantifies the difference between predicted outputs and actual targets.
This process often involves techniques such as backpropagation and gradient descent to iteratively reduce the loss.
By doing so, FNNs can learn complex patterns and relationships within data, enabling them to perform a wide range of tasks with high accuracy.
For additional information, see @russellArtificialIntelligenceModern2021.

=== Convolutional Neural Network
A Convolutional Neural Network (CNN) is a specialized artificial neural network primarily used for image recognition, classification, and computer vision tasks.
It employs convolutional layers that automatically learn hierarchical patterns and features from input images.
These convolutional layers consist of filters with a specific kernel size that slide across the input image, performing convolutions to extract local features.
CNNs typically consist of multiple layers, including convolutional, pooling, and fully connected layers.
The convolutional layers detect low-level features, while subsequent layers combine these features to recognize higher-level patterns.
Pooling layers downsample the feature maps, reducing the spatial dimensions of the data and increasing computational efficiency.
Finally, fully connected layers process the extracted features to make predictions or classifications.
During training, CNNs adjust the parameters of the filters through backpropagation, optimizing them to minimize the difference between predicted outputs and ground truth labels.
This process enables CNNs to effectively learn and generalize from large datasets.
Their ability to learn relevant features from raw input data and their hierarchical architecture make them well-suited for handling complex tasks.
For additional information see @russellArtificialIntelligenceModern2021.

=== Adversarial Attack using Fast Gradient Sign Method <terms-and-definitions-fgsm>
The Fast Gradient Sign Method (FGSM) is a white-box adversarial attack.
White-box adversarial attacks on neural networks operate under the premise that the attacker has complete knowledge of the model's architecture and weights.
This method, introduced by Ian Goodfellow et al. @goodfellowExplainingHarnessingAdversarial2015, operates under the premise that by applying a small, carefully calculated change in the direction of the gradient of the loss with respect to the input data, one can generate a new adversarial sample which is almost indistinguishable from the original but is misclassified by the neural network.
The perturbation is determined by taking the sign of the gradient of the loss with respect to the input features and then multiplying it by a small scalar $epsilon$ (epsilon) to ensure the modification is subtle.
Mathmatically this results in the expression in @adversarial-sample-expression:

#figure(
  grid(
    columns: 1,
    gutter: 2mm,
    $ "adversarial_sample" = x + epsilon dot "sign"(nabla_x J(Theta, x, y)) $,
    v(1pt), // adds space between math expression and explanation
    (align(left, text[where:])),
    (align(left, text[
      - $x$: original input
      - $y$: original input label
      - $epsilon$: keeps perturbations small
      - $J$: Loss function
      - $Theta$: Model parameters
    ])),
    v(1pt) // adds space between explanation and caption
  ),
  caption: "Creating an adversarial sapmle."
) <adversarial-sample-expression>

The FGSM is designed to be fast and computationally efficient, making it not only a powerful tool for analyzing the robustness of neural networks but also a significant concern for applications reliant on machine learning for security-sensitive tasks.

= Approach <approach>
The methods mentioned in @related-work are used for fingerprinting, meaning they can predict which results originate from which quantum computer, but they cannot distinguish between a QC or a simulator.
This work attempts to develop an approach that performs this differentiation.
In order to achieve this, only the measurement results of the quantum circuits are considered.
Therefore, this paper uses machine learning techniques to decide whether a quantum circuit was run on a quantum computer or simulated on a classical computer based on the circuit's measurement results.

== Data for Training
The measurement results from a quantum computer are taken from @martinaLearningQuantumNoiseFingerprint2023.
The reason is that no access to a quantum computer was available during the creation of this paper.
The QC measumerent data has been obtained by running the circuit described in @circuit on 7 different IBM quantum machines (Athens, Santiago, Casablanca, Yorktown, Bogota, Quito, Lima).
Each circuit measurement in the dataset can be trayced back to the quantum computer it was executed on.
The simulation data for this work was created by simulating the identical quantum circuits from @martinaLearningQuantumNoiseFingerprint2023 with Qiskit @Qiskit2024.

=== Circuit <circuit>
The entire circuit looks like @circuit-measurement-step-9.
In order to measure the circuit at different points, this circuit is executed until different points (steps), and a measurement of the qubits $q_2$ and $q_3$ is carried out after each step.
Due to the wavefunction collapse, a new circuit has to be executed and measured for each measurement step.
The entire process is shown in @circuit-measurement-step-1 up to @circuit-measurement-step-9.
#figure(
  image("images/walker-step-1.svg"),
  caption: "Circuit which corresponds to measurement step 1."
) <circuit-measurement-step-1>
#v(10pt)
#figure(
  image("images/walker-step-2.svg"),
  caption: "Circuit which corresponds to measurement step 2."
) <circuit-measurement-step-2>
#v(10pt)
#figure(
  image("images/walker-step-3.svg"),
  caption: "Circuit which corresponds to measurement step 3."
) <circuit-measurement-step-3>
#v(10pt)
#figure(
  image("images/walker-step-4.svg"),
  caption: "Circuit which corresponds to measurement step 4."
) <circuit-measurement-step-4>
#v(10pt)
#figure(
  image("images/walker-step-5.svg"),
  caption: "Circuit which corresponds to measurement step 5."
) <circuit-measurement-step-5>
#v(10pt)
#figure(
  image("images/walker-step-6.svg"),
  caption: "Circuit which corresponds to measurement step 6."
) <circuit-measurement-step-6>
#v(10pt)
#figure(
  image("images/walker-step-7.svg"),
  caption: "Circuit which corresponds to measurement step 7."
) <circuit-measurement-step-7>
#v(10pt)
#figure(
  image("images/walker-step-8.svg"),
  caption: "Circuit which corresponds to measurement step 8."
) <circuit-measurement-step-8>
#v(10pt)
#figure(
  image("images/walker-step-9.svg"),
  caption: "Circuit which corresponds to measurement step 9. Complete circuit with four qubits. Only the lower two qubits are being measured at the end. Grey separators mark points at which measurements can take place."
) <circuit-measurement-step-9>
#v(10pt)

This results in 9 measurement points for this circuit.
Each circuit run has been performed with 8000 shots.
The measurement results of one circuit run with 8000 shots look like @measurement-data-table.

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
Seven different Qiskit simulators are utilized to obtain the simulated data.
Only one backend calculates a noise-free result because the noise causes the variance, but different simulator implementations deliver similar results.
In order to obtain a comparable order of magnitude of simulated data to that of QC-generated data, six additional simulators with noise are used.
All six backends are each utilizing a different noise model based on calibration data from real IBM quantum computers @Fake_provider.
The following fake backends were used: Vigo, Athens, Santiago, Lima, Belem, Cairo.
// TODO ist das als Begründung ok?
Three of these fake backends are based on configurations of quantum computers which were used for creating training data in order to account for a adversarial cloud provider trying to mimic some specific quantum computer.

== Machine Learning Approaches <machine-learning-approaches>
The basic approach makes use of machine learning algorithms to distinguish whether a quantum circuit was executed on a QC or a simulator.
Different ML algorithms were trained using raw measurement data as a first approach.
The complete data set for a measurement point (step) over 8000 shots (i.e., 8000 individual values) was used as input in each case.
The individual steps are considered entirely independently of each other.
In particular, 8000 input neurons had to be used for the artificial neural net.

As a second approach, the data was preprocessed before machine learning algorithms were applied.
For this purpose, the probability values per step were calculated for the four possible result values ($00_2$, $01_2$, $10_2$, $11_2$).
Only these probability values are used as input for the ML algorithms.
When considering a step > 1, the probability values of the previous steps were also used.
This means that step 1 has four input values, step 2 has 8 (the four unchanged values from step 1 and the four additional probabilities from step 2), step 3 has 12, and so on (see @probability-calculation-table-step-1 and @probability-calculation-table-steps-1-and-2).
This preprocessing approach is based on the data preparation in @martinaLearningQuantumNoiseFingerprint2023.
// TODO Figure schöner machen.
#figure(
  grid(
    columns: 1,
    gutter: 5mm,
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
The number of shots which were combined into one package containing the probability shall be refered to as 'window size'.
In the following machine learning approaches, in case no window size is mentioned, these models where trained and evaluated with data preprocessed with a window size of 2000.
This value has been taken from @svm-window-size-vs-step-range, @fnn-window-size-vs-step-range, and @cnn-window-size-vs-step-range because it shows a high accuracy even with a low amount of measurement steps accross models, allowing for an easier comparison.
The three following machine learning models have been chosen because the SVM has used in @martinaLearningNoiseFingerprint2022 and had high accuracy distinguishing different quantum computers.
The feedforward neural net is a standard neural net model which is simple but effective in learning patterns in data.
The last model, the CNN, has been chosen due to its ability to recognize patterns with its sliding filters.

=== Support Vector Machine

To optimize the selection of the support vector machine algorithm for training, 20% of the dataset is allocated for preliminary evaluation.
This evaluation process involves comparing the performance, specifically accuracy, of multiple potential SVM algorithms: linear, polynomial, and radial basis function.
During this phase, the algorithm demonstrating superior accuracy is then selected for further training.
This makes it possible to achieve high accuracies even for complicated input data while trying to keep the computational cost low.
The chosen algorithm undergoes training on 60% of the input data, and its performance is subsequently assessed using the remaining 20% of the data to ensure its efficacy and reliability.
The selection process for the SVM algorithm is similar to @martinaLearningNoiseFingerprint2022.

=== Feedforward Neural Net <approach-ffnn>
The feedforward neural net was trained on 80% of the dataset, 20% were used for evaluationg the accuracy of the model.
The input layer of the neural network was designed to be variable, accommodating between 4 to 36 neurons, depending on the number of measurement steps that are included in the dataset.
This flexibility was needed to be able to compare different amounts of measurement steps, see @fnn-window-size-vs-step-range.
The architecture included two dense hidden layers containing 45 and 20 neurons, respectively, utilizing the hyperbolic tangent (tanh) activation function.
Increasing the amount of neurons didn't yield any noticable increase in accuracy, the number of neurons was determined by utilizing the keras tuner and manual trial and error afterwards.
The output layer was constructed with a single neuron, employing a sigmoid activation function to produce a probability output between 0 and 1, indicative of the data source being a simulator or a quantum computer, respectively.

For the training process, the Adam optimizer was selected.
The loss during training was quantified using binary cross-entropy, the standard choice for binary classification problems.
Training was conducted over five epochs with a batch size of 32, balancing computational efficiency and the model's ability to learn from the training data.
Observations indicated that extending the training beyond five epochs did not significantly improve accuracy, suggesting an optimal learning plateau had been reached within the given epoch span.
After training, the model's accuracy was evaluated by using the previously unseen test data.
This configuration led to the model's successful differentiation between the two data sources, see @evaluation-ffnn.

=== Convolutional Neural Net
A convolutional neural network model was developed, utilizing a dataset divided into 80% for training and 20% for testing.
The input layer of the model was designed to be adaptable, accommodating a variable number of neurons ranging from 4 to 36, depending on the number of measurement steps incorporated in the dataset, similar to @approach-ffnn.
The first layer contains 30 1-dimensional convolutional filters, each with a kernel size of 3, using the Rectified Linear Unit (ReLU) activation function.
Following the convolutional layer, a 1-dimensional max pooling operation was applied, reducing the dimensionality of the data.
After the max pooling, the network architecture includes a flattening step, transforming the pooled feature maps into a single, linear vector.
This flattened vector was then fed into two additional hidden layers, comprising 64 and 32 neurons, each employing the ReLU activation function to further process and refine the features extracted from the input data.
Increasing the amount of neurons or the number of convolutional filters didn't result in a noticable increase in accuracy.
For finding a general structure, the keras tuner was utilized.
Afterwards the values where finally adjusted by hand per trial and error.
The final stage of the model was an output layer consisting of a single neuron utilizing a sigmoid activation function.
This setup is particularly suited for binary classification tasks, as it produces a probability output in the range of 0 to 1, indicative of the class membership of the input data.
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
Through this attack it was possible to get the model to label meusarements generated by a simulator as quantum computer generated.
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
  caption: "Support vector machine: Comparison of the accuracy for different window sizes and measurement step ranges. Circuit run-data from all quantum computers and all simulators was used."
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
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated."
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
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated."
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
  caption: "Feedforward neural net: Comparison of the accuracy for different window sizes and measurement step ranges. Circuit run-data from all quantum computers and all simulators was used."
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
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated."
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
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated."
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
  caption: "Convolutional neural net: Comparison of the accuracy for different window sizes and measurement step ranges for the convolutional neural net. Circuit run-data from all quantum computers and all simulators was used."
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
  caption: "A single quantum computer is excluded from the training dataset. Only this excluded quantum computer is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four quantum computers and uses exclusively the excluded quantum computers for evaluating the accuracy. Every possible permutation of quantum computers gets excluded (the order is not taken into account) and the average of all training runs is calculated."
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
  caption: "A single simulator backend is excluded from the training dataset. Only measurement data generated by this excluded simulator is used for evaluating the accuracy."
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
  caption: "Excludes at least one and up to four simulator backends and uses exclusively measurements generated by the excluded simulators for evaluating the accuracy. Every possible permutation of simulator backends gets excluded (the order is not taken into account) and the average of all runs is calculated."
)

== Adversarial Machine Learning with Fast Gradient Sign Method <evaluation-fgsm>
By converting 1400 samples generated by simulators into adversarial samples in such a fasion that they are recognized as 'generated by a quantum computer'.
The result can be seen in @adversarial-accuracy.
When epsilon is zero the adversarial sample equals the original input sample.
The graph shows that with increased $epsilon$ values, the accuracy gets worse due to the increased perturbation in the adversarial sample.

#let adversarial_accuracy_data = csv("data/walker_adversarial_attack_simulator_to_quantum.csv")
#figure(
  cetz.canvas(length: 1.5cm, {
    import cetz.draw: *
    import cetz.plot
    plot.plot(size: (10,5), x-tick-step: none, y-tick-step: none, 
      x-ticks: (adversarial_accuracy_data.map(((epsilon,acc)) => float(epsilon))),
      x-decimals: 3,
      x-label: "Epsilon",
      y-min: 0, y-max: 1,
      y-ticks: (0, 0.25, 0.5, 0.75, 0.9, 1),
      y-label: "Accuraccy",
    {
      plot.add(adversarial_accuracy_data.map(((epsilon,acc)) => (float(epsilon), float(acc))))
    })
  }),
  caption: "Comparison of the models accuracy on adversarial samples with different epsilon values. 1400 samples were converted to adversarial samples for this graph. The larger the epsilon value gets, the larger the perturbation in the adversarial sample."
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

== Limitations
The main limitation of this work is, that classification can only be performed with the circuit from  @circuit.
This is due to the fact, that different quantum circuits result in different distributions of measurement results.
Despite this limitation, it is possible to utilize this approach for simulator detection.
In order to achieve this, the circuit from @circuit gets sent to the (possibly adversarial) quantum cloud provider.
The results get classified in order to determine whether the circuit has been run on a quantum computer or simulated on a classical computer.
It would be possible for the quantum cloud provider to recognize this specific circuit, route the circuit to a legit quantum computer provider, and forward the results to the end user.
To prevent this, the circuit could be embedded into the circuit which the user wants to execute.

Additionally, as shown in @evaluation-fgsm, it is possible to forge adversarial samples which get classified with the incorrect label.
One way to prevent such a white-box adversarial attack is to keep the trained neural net hidden.

= Future Work <future-work>
One possible improvement would be to showcase that this approach can distinguish between simulators and quantum computers for other quantum circuits than the one used in this work (@circuit).
Moreover it would be interesting to explore how adding additional samples from different (and possibly more modern) quantum computers would influence the accuracy.
Also, it could be interesting to perform further, more advanced adversarial attacks on the neural net, such as a trying to perform a adversarial patch attack @brownAdversarialPatch2018.

= Conclusion <conclusion>
//in dieser arbeit wurde gezeigt, dass mit aktuellen mitteln des machine learnings es möglich ist, für einen bestehenden quantum circuit es mit hoher wahrcsheinlcihket zu unterscheiden, ob qc oder simulator.
// eine direkte Anwendbarkeit der hier erstellten netze für andere quantum circuits ist nicht möglich.
// der gezeigte lösungsweg kann jedoch wahrcsheinlcih (see @future-work) für andere circuits angewandt werden.
// wenn die in @limitations gezeigten grenzen beachtet werden, erscheint der hier gezeigte weg als praktikabler indikator, für die Art der Circuit ausführung.

#pagebreak()

#bibliography("Sources.bib")