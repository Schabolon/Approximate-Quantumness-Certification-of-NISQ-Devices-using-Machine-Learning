import logging
from typing import Optional

import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models

from dataset import CustomDataset
from model.ml_wrapper import MLWrapper


class RunCNN(MLWrapper):

    def __init__(self):
        super().__init__("cnn")

    @staticmethod
    def train_and_evaluate(custom_dataset: CustomDataset, test_dataset: Optional[CustomDataset] = None):
        if test_dataset is not None:
            test_features = test_dataset.features
            test_labels = test_dataset.labels
            train_features = custom_dataset.features
            train_labels = custom_dataset.labels
        else:
            train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

        model = models.Sequential()
        model.add(layers.InputLayer(input_shape=(len(train_features[1]), 1)))
        model.add(layers.Conv1D(40, 3, activation='relu'))
        model.add(layers.MaxPooling1D())

        # Dense Layer
        model.add(layers.Flatten())

        model.add(layers.Dense(64, activation='relu'))
        model.add(layers.Dense(32, activation='relu'))
        model.add(layers.Dense(1, activation='sigmoid'))

        model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False), metrics=['accuracy'])

        logging.debug("Training CNN ...")
        model.fit(train_features, train_labels, epochs=5, validation_data=(test_features, test_labels), verbose=1)
        logging.debug("Evaluating CNN ...")
        test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=2)
        logging.info(test_acc)

        return test_acc
