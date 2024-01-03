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
dataset = tf.data.Dataset.load("../data/mixed_datasets/walker_dataset")

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
