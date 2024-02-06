"""
Neural Net: a simple feed-forward-network.
"""
import logging
import tensorflow as tf

from tensorflow.keras import layers
from dataset import CustomDataset
from model.ml_wrapper import MLWrapper


class RunNeuralNet(MLWrapper):

    def __init__(self):
        super().__init__("neural_net")

    @staticmethod
    def train_and_evaluate(custom_dataset: CustomDataset):
        train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

        model = tf.keras.Sequential([
            layers.InputLayer(input_shape=(train_features.shape[1], )),
            layers.Dense(10, activation='tanh'),
            layers.Dense(5, activation='tanh'),
            # layers.Dense(128, activation='relu'),
            # use 'sigmoid' for output activation, squishes the values between 0 and 1.
            layers.Dense(1, activation='sigmoid')
        ])

        model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False), metrics=['accuracy'])

        model.fit(train_features, train_labels, epochs=5, verbose=1, batch_size=32, validation_data=(test_features, test_labels))

        test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=1)

        logging.debug(f"Neural Net test accuracy: {test_acc}")

        return test_acc
