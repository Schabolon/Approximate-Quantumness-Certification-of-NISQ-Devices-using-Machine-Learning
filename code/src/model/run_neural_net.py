"""
Neural Net: a simple feed-forward-network.
"""
import logging
from typing import Optional

import numpy as np
import tensorflow as tf
from keras import Sequential

from tensorflow.keras import layers
from dataset import CustomDataset
from model.ml_wrapper import MLWrapper


class RunNeuralNet(MLWrapper):

    def __init__(self):
        super().__init__("neural_net")

    @staticmethod
    def __get_model__(input_shape: tuple) -> Sequential:
        model = tf.keras.Sequential([
            layers.InputLayer(input_shape=input_shape),
            layers.Dense(45, activation='tanh'),
            layers.Dense(20, activation='tanh'),
            # use 'sigmoid' for output activation, squishes the values between 0 and 1.
            layers.Dense(1, activation='sigmoid')
        ])

        model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False),
                      metrics=['accuracy'])
        return model

    @staticmethod
    def train_and_evaluate(custom_dataset: CustomDataset, test_dataset: Optional[CustomDataset] = None):
        if test_dataset is not None:
            test_features = test_dataset.features
            test_labels = test_dataset.labels
            train_features = custom_dataset.features
            train_labels = custom_dataset.labels
        else:
            train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

        model = RunNeuralNet.__get_model__((train_features.shape[1],))

        model.fit(train_features, train_labels, epochs=5, verbose=1, batch_size=32,
                  validation_data=(test_features, test_labels))

        test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=1)

        logging.debug(f"Neural Net test accuracy: {test_acc}")

        return test_acc

    @staticmethod
    def get_model_after_training(custom_dataset: CustomDataset) -> Sequential:
        train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

        model = RunNeuralNet.__get_model__((train_features.shape[1],))

        model.fit(train_features, train_labels, epochs=5, verbose=1, batch_size=32,
                  validation_data=(test_features, test_labels))

        test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=1)

        logging.debug(f"Neural Net test accuracy: {test_acc}")
        return model
