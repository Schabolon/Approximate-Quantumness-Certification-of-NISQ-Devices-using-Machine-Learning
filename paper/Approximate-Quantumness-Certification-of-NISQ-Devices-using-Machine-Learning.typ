
= Introduction
- Herleitung des Themas anhand von "Betrug" im Cloud-Computing: Nutzer muss dem Cloud-Anbieter vertrauen -> Möglichkeit für den Endnutzer um festzustellen, ob tatsächlich ein QC für die Berechnung verwendet wurde.
- Trainingsdaten: Verwendet da kein eigener Zugriff auf QC möglich.
  - Erklärung der Trainingsdaten (z.B. 8000 Shots pro Durchlauf, ...)
  - Aufbau des Quantencircuits
- Wie wurden die am Daten der am Computer simulierten Quantumcircuits erstellt? (Verschiedene Simulatoren verwenden?)
  - möglicher Simulator: *OpenQASM backend*

= Machine Learning
1. "funktionierendes Modell erstellen"
  - Welche Library verwenden? (TensorFlow?, ...)
  - Zeitabhängigkeit relevant? -> Was eignet sich dafür gut?
    - Multilayer Perceptron?
    - Wie werden die Daten "eingegeben"?
      - ein Input-Neuron für jeden Shot?
      - Sliding-Window über den Input?
      - Wahrscheinlichkeiten? (Was wird im Paper bisher für SVM verwendet?)
  - Welche Activation Function?
  - Wie viele Layer sollten verwendet werden?
  - Wie viele Neuronen?
  - ...

= Adversarial Attack
TODO