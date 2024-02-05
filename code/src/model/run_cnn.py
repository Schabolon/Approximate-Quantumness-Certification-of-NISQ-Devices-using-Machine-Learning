import logging

import tensorflow as tf
from tensorflow.keras import layers, models

from dataset import CustomDataset


def evaluate_model(custom_dataset: CustomDataset):
    train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

    model = models.Sequential()
    model.add(layers.InputLayer(input_shape=(8000, 1)))
    model.add(layers.Conv1D(32, 3, activation='relu'))
    model.add(layers.MaxPooling1D())
    model.add(layers.Conv1D(64, 3, activation='relu'))
    model.add(layers.MaxPooling1D())
    model.add(layers.Conv1D(64, 3, activation='relu'))
    # Dense Layer
    model.add(layers.Flatten())
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(1, activation='sigmoid'))

    model.compile(optimizer='adam', loss=tf.keras.losses.BinaryCrossentropy(from_logits=False), metrics=['accuracy'])

    logging.debug("Training CNN ...")
    model.fit(train_features, train_labels, epochs=5, validation_data=(test_features, test_labels), verbose=1)
    logging.debug("Evaluating CNN ...")
    test_loss, test_acc = model.evaluate(test_features, test_labels, verbose=2)
    logging.info(test_acc)

    return test_acc
