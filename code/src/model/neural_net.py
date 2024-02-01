"""
Neural Net: a simple feed-forward-network.
"""
import logging
import tensorflow as tf

from tensorflow.keras import layers, models
from dataset import CustomDataset


def evaluate_neural_net(custom_dataset: CustomDataset):
    train_features, train_labels, test_features, test_labels = custom_dataset.get_dataset_separated()

    model = tf.keras.Sequential([
        layers.InputLayer(input_shape=(8000,)),
        layers.Dense(1000, activation='tanh'),
        layers.Dense(500, activation='tanh'),
        layers.Dense(128, activation='relu'),
        # use 'sigmoid' for output activation, squishes the values between 0 and 1.
        layers.Dense(1, activation='sigmoid')
    ])

    model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False), metrics=['accuracy'])

    model.fit(train_features, train_labels, epochs=5, verbose=1, batch_size=32, validation_data=(test_features, test_labels))

    test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=1)

    logging.debug(f"Neural Net test accuracy: {test_acc}")

    return test_acc
