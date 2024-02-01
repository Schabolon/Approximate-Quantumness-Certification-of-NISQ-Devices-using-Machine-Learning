import logging

import tensorflow as tf
from tensorflow.keras import Sequential
from tensorflow.keras.layers import LSTM, Dense
from tensorflow.keras import layers, models

from dataset import CustomDataset


def evaluate_model(custom_dataset: CustomDataset):
    train_features, train_labels, test_features, test_labels = custom_dataset.get_dataset_separated()

    # todo reshape input data to (samples, timesteps, features)
    # like this: data = data.reshape((1, len(data), 1))
    # and try to use this maybe? input_shape=(data.shape[1], data.shape[2])

    model = Sequential()
    model.add(layers.InputLayer(input_shape=(8000,)))
    model.add(LSTM(units=128, return_sequences=True))
    model.add(LSTM(units=64, return_sequences=True))
    model.add(LSTM(units=64, return_sequences=True))
    model.add(layers.Dense(1, activation='sigmoid'))

    model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False), metrics=['accuracy'])

    logging.debug("Training LSTM ...")
    model.fit(train_features, train_labels, epochs=5, batch_size=32, validation_data=(test_features, test_labels), verbose=1)
    logging.debug("Evaluating LSTM ...")
    test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=2)
    logging.info(test_acc)

    return test_acc
