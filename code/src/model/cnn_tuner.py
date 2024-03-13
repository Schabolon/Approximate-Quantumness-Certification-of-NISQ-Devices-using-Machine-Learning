from typing import Tuple

import keras_tuner as kt
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models

from dataset import CustomDataset


class CNNTuner:

    dataset: CustomDataset
    input_shape: Tuple[any]

    def __init__(self, custom_dataset: CustomDataset):
        train_features, _, _, _ = custom_dataset.get_test_train_split()
        self.input_shape = (len(train_features[1]), 1)
        self.dataset = custom_dataset

    def __model_builder(self, hyperparameters):
        model = keras.Sequential()

        # input layer
        model.add(tf.keras.layers.InputLayer(input_shape=self.input_shape))

        # convolutional layer
        hp_conv_filters = hyperparameters.Int('conv_filters', min_value=1, max_value=50, step=1)
        hp_conv_kernel_size = hyperparameters.Int('conv_kernel_size', min_value=2, max_value=4, step=1)
        model.add(layers.Conv1D(hp_conv_filters, hp_conv_kernel_size, activation='relu'))
        model.add(layers.MaxPooling1D())

        model.add(layers.Flatten())

        # first layer
        hp_first_layer_units = hyperparameters.Int('first_layer_units', min_value=1, max_value=100, step=5)
        hp_first_layer_activation = hyperparameters.Choice('first_layer_activation', values=['relu', 'sigmoid', 'tanh'])
        model.add(tf.keras.layers.Dense(units=hp_first_layer_units, activation=hp_first_layer_activation)),

        # second layer
        hp_second_layer_units = hyperparameters.Int('second_layer_units', min_value=1, max_value=50, step=5)
        hp_second_layer_activation = hyperparameters.Choice('second_layer_activation',
                                                            values=['relu', 'sigmoid', 'tanh'])
        model.add(keras.layers.Dense(units=hp_second_layer_units, activation=hp_second_layer_activation))

        # Dropout should allow for more epochs without over-fitting
        hp_dropout_rate = hyperparameters.Choice('dropout_rate', values=[0.0, 0.1, 0.2])
        model.add(keras.layers.Dropout(rate=hp_dropout_rate))

        # output layer
        model.add(keras.layers.Dense(1, activation='sigmoid'))

        # Tune the learning rate for the optimizer
        # Choose an optimal value from 0.01, 0.001, or 0.0001
        hp_learning_rate = hyperparameters.Choice('learning_rate', values=[1e-2, 1e-3, 1e-4])

        model.compile(optimizer=keras.optimizers.Adam(learning_rate=hp_learning_rate),
                      loss='binary_crossentropy',
                      metrics=['accuracy'])

        return model

    # Hyperparameter tuning -> changing the model (number of neurons, activation function, optimizer, ...)
    def tune_and_evaluate_model(self):
        train_features, train_labels, test_features, test_labels = self.dataset.get_test_train_split()

        tuner = kt.Hyperband(self.__model_builder,
                             objective='val_accuracy',
                             max_epochs=15,
                             directory='../hyperparameter-tuner',
                             project_name='cnn')
        stop_early = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=5)
        tuner.search(train_features, train_labels, epochs=15, validation_split=0.2, callbacks=[stop_early])

        # Get the optimal hyperparameters
        best_hps = tuner.get_best_hyperparameters()[0]

        print(f"""
            The hyperparameter search is complete.
            Number of convolutional filters {best_hps['conv_filters']} with kernel size {best_hps['conv_kernel_size']}.
            Number of units in the first densely-connected layer is {best_hps['first_layer_units']} with activation function {best_hps['first_layer_activation']}.
            Number of units in the second densely-connected layer is {best_hps['second_layer_units']} with activation function {best_hps['second_layer_activation']}.
            Best dropout rate is {best_hps['dropout_rate']}
            The optimal learning rate for the optimizer is {best_hps.get('learning_rate')}.
            """)

        # Figure out the optimum amount of epochs
        # Build the model with the optimal hyperparameters and train it on the data for 15 epochs
        model = tuner.hypermodel.build(best_hps)
        history = model.fit(train_features, train_labels, epochs=15, validation_split=0.2)
        val_acc_per_epoch = history.history['val_accuracy']
        best_epoch = val_acc_per_epoch.index(max(val_acc_per_epoch)) + 1
        print('Best epoch: %d' % (best_epoch,))

        # Train the model
        # Retrain the model with the optimum amount of epochs
        hypermodel = tuner.hypermodel.build(best_hps)
        hypermodel.fit(train_features, train_labels, epochs=best_epoch, validation_split=0.2)
        test_loss, test_acc = hypermodel.evaluate(test_features, test_labels)
        print("[test loss, test accuracy]:", test_loss, test_acc)

        return test_acc
