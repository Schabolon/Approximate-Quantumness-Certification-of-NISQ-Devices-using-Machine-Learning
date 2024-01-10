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

quantum_computer_machines = ['ibmq_athens', 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A',
                             'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D',
                             'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G',
                             'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J',
                             'ibmq_santiago', 'ibmq_casablanca', 'ibmq_casablanca-bis', 'ibmq_5_yorktown',
                             'ibmq_bogota', 'ibmq_lima', 'ibmq_quito']

simulator_names = ["aersimulator_density_matrix", "aersimulator_matrix_product_state", "aersimulator_statevector",
                   "qasmsimulator_default", "aersimulator_default", "statevectorsimulator_default"]

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
        first_row.extend(simulator_names)
        csv_writer.writerow(first_row)

        for machine in quantum_computer_machines:
            results = []
            for simulator in simulator_names:
                dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{machine}_vs_{simulator}_dataset")
                (test_loss, test_acc) = train_model(dataset)
                results.append(test_acc)
            results.insert(0, machine)
            csv_writer.writerow(results)
