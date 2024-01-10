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
import csv

import config


# Trainingsdata: (label, data). Split into train and test.
# dataset = tf.data.Dataset.load("../data/mixed_datasets/walker_dataset")
# dataset = tf.data.Dataset.load("../data/datasets/vs_datasets/walker_ibmq_athens_vs_aersimulator_density_matrix_dataset")


def train_model(dataset):
    # Get the total number of elements in the dataset
    num_elements = tf.data.experimental.cardinality(dataset).numpy()

    # Calculate the number of elements for training and testing
    train_size = int(0.8 * num_elements)
    test_size = num_elements - train_size

    # Create training and testing datasets
    train_dataset = dataset.take(train_size)
    test_dataset = dataset.skip(train_size)

    model = tf.keras.Sequential([
        tf.keras.layers.Dense(128, input_shape=(8000,), activation='relu'),
        tf.keras.layers.Dense(2)
    ])

    model.compile(optimizer='adam',
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])

    model.fit(train_dataset.batch(32), epochs=10, verbose=1)

    test_loss, test_acc = model.evaluate(test_dataset.batch(32), verbose=1)

    print('\nTest accuracy:', test_acc)

    return test_loss, test_acc


if __name__ == "__main__":
    with (open('../results.csv', 'w', newline='') as csvfile):
        csv_writer = csv.writer(csvfile, delimiter=',',
                                quotechar='|', quoting=csv.QUOTE_MINIMAL)
        first_row = ['ibm quantum computer / simulator']
        first_row.extend(config.get_all_simulator_names())
        csv_writer.writerow(first_row)

        for quantum_computer_name in config.quantum_computer_names:
            results = []
            for simulator_name in config.get_all_simulator_names():
                dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{quantum_computer_name}_vs_{simulator_name}_dataset")
                (test_loss, test_acc) = train_model(dataset)
                results.append(test_acc)
            results.insert(0, quantum_computer_name)
            csv_writer.writerow(results)
