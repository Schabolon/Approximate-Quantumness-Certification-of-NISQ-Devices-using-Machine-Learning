"""
First attempt.

Data:
- Use Walker-Circuit (all steps from 1-9 mixed)
- no data pre-processing
- directly using the results from the 8000 shots as input

Machine Learning Model:
- using a simple feed-forward-network
"""

import tensorflow as tf

# Trainingsdata: (label, data). Split into train and test.
# dataset = tf.data.Dataset.load("../data/mixed_datasets/walker_dataset")
# dataset = tf.data.Dataset.load("../data/datasets/vs_datasets/walker_ibmq_athens_vs_aersimulator_density_matrix_dataset")


def train_model(dataset):
    # Get the total number of elements in the dataset
    num_elements = tf.data.experimental.cardinality(dataset).numpy()

    # Calculate the number of elements for training and testing
    train_size = int(0.8 * num_elements)

    # Create training and testing datasets
    train_dataset = dataset.take(train_size)
    test_dataset = dataset.skip(train_size)

    # TODO try to use a CNN (maybe filter recognize time dependence?)
    # Hyper parameter tuning -> changing the model (number of neurons, activation function, optimizier, ...)
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(1000, input_shape=(8000,), activation='sigmoid'),
        tf.keras.layers.Dense(1000, activation='sigmoid'),
        tf.keras.layers.Dense(500, activation='sigmoid'),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid') # use 'sigmoid' for output activation, squishes the values between 0 and 1.
    ])

    model.compile(optimizer='adam',
                  loss=tf.keras.losses.BinaryCrossentropy(from_logits=False),
                  metrics=['accuracy'])

    history = model.fit(train_dataset.batch(32), epochs=5, verbose=1)
    """
    acc = history.history['accuracy']
    val_acc = history.history['val_accuracy']

    loss = history.history['loss']
    val_loss = history.history['val_loss']

    plt.figure(figsize=(8, 8))
    plt.subplot(2, 1, 1)
    plt.plot(acc, label='Training Accuracy')
    plt.plot(val_acc, label='Validation Accuracy')
    plt.legend(loc='lower right')
    plt.ylabel('Accuracy')
    plt.ylim([min(plt.ylim()), 1])
    plt.title('Training and Validation Accuracy')

    plt.subplot(2, 1, 2)
    plt.plot(loss, label='Training Loss')
    plt.plot(val_loss, label='Validation Loss')
    plt.legend(loc='upper right')
    plt.ylabel('Cross Entropy')
    plt.ylim([0, 1.0])
    plt.title('Training and Validation Loss')
    plt.xlabel('epoch')
    plt.show()
    """

    test_loss, test_acc = model.evaluate(test_dataset.batch(32), verbose=1)

    print('\nTest accuracy:', test_acc)

    return test_loss, test_acc


if __name__ == "__main__":
    dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{simulators.get_all_simulator_names()[0]}"
                                   f"_vs_{quantum_computers.quantum_computer_names[1]}_dataset")
    (test_loss, test_acc) = train_model(dataset)
    exit(0)

    with (open('../results_quantum_vs_quantum.csv', 'w', newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        first_row = ['ibm quantum computer / ibm quantum computer']
        first_row.extend(config.quantum_computer_names_no_split)
        csv_writer.writerow(first_row)

        for quantum_computer_name in config.quantum_computer_names_no_split:
            results = []
            for name2 in config.quantum_computer_names_no_split:
                dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{quantum_computer_name}_vs_{name2}_dataset")
                (test_loss, test_acc) = train_model(dataset)
                results.append(test_acc)
            results.insert(0, quantum_computer_name)
            csv_writer.writerow(results)
