import logging
from typing import Optional

import keras
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras import layers, models

from dataset import CustomDataset
from model.early_stop_callback import EarlyStopCallback
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
        history = model.fit(train_features, train_labels, epochs=100, validation_data=(test_features, test_labels),
                            verbose=1, callbacks=[EarlyStopCallback(), keras.callbacks.EarlyStopping(monitor='val_loss', patience=3)])

        # Save history to file:
        # convert the history.history dict to a pandas DataFrame:
        #hist_df = pd.DataFrame(history.history)
        # save to csv:
        #hist_csv_file = 'history_cnn.csv'
        #with open(hist_csv_file, mode='w') as f:
        #    hist_df.to_csv(f)

        logging.debug("Evaluating CNN ...")
        test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=2)
        logging.info(test_acc)

        return test_acc
