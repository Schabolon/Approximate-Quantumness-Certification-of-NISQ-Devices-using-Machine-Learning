import keras_tuner as kt
import tensorflow as tf
from tensorflow import keras

from dataset import CustomDataset


def __model_builder(hp):
    model = keras.Sequential()

    # first layer
    hp_first_layer_units = hp.Int('first_layer_units', min_value=32, max_value=4096, step=32)
    hp_first_layer_activation = hp.Choice('first_layer_activation', values=['relu', 'sigmoid', 'tanh'])
    model.add(
        # TODO adjust input shape dynamically
        tf.keras.layers.Dense(units=hp_first_layer_units, input_shape=(8000,), activation=hp_first_layer_activation)),

    # second layer
    # Choose an optimal value between 32-512
    hp_second_layer_units = hp.Int('second_layer_units', min_value=32, max_value=512, step=32)
    hp_second_layer_activation = hp.Choice('second_layer_activation', values=['relu', 'sigmoid', 'tanh'])
    model.add(keras.layers.Dense(units=hp_second_layer_units, activation=hp_second_layer_activation))
    model.add(keras.layers.Dense(1, activation='sigmoid'))

    # third layer
    hp_third_layer_units = hp.Int('third_layer_units', min_value=32, max_value=512, step=32)
    hp_third_layer_activation = hp.Choice('third_layer_activation', values=['relu', 'sigmoid', 'tanh'])
    model.add(keras.layers.Dense(units=hp_third_layer_units, activation=hp_third_layer_activation))

    # fourth layer
    hp_fourth_layer_units = hp.Int('fourth_layer_units', min_value=32, max_value=512, step=32)
    hp_fourth_layer_activation = hp.Choice('fourth_layer_activation', values=['relu', 'sigmoid', 'tanh'])
    model.add(keras.layers.Dense(units=hp_fourth_layer_units, activation=hp_fourth_layer_activation))

    # Dropout should allow for more epochs without overfiting
    hp_dropout_rate = hp.Choice('dropout_rate', values=[0.0, 0.1, 0.2])
    model.add(keras.layers.Dropout(rate=hp_dropout_rate))

    # output layer
    model.add(keras.layers.Dense(1, activation='sigmoid'))

    # Tune the learning rate for the optimizer
    # Choose an optimal value from 0.01, 0.001, or 0.0001
    hp_learning_rate = hp.Choice('learning_rate', values=[1e-2, 1e-3, 1e-4])

    model.compile(optimizer=keras.optimizers.Adam(learning_rate=hp_learning_rate),
                  loss='binary_crossentropy',
                  metrics=['accuracy'])

    return model


# Hyper parameter tuning -> changing the model (number of neurons, activation function, optimizier, ...)
def tune_and_evaluate_model(custom_dataset: CustomDataset):
    train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

    tuner = kt.Hyperband(__model_builder,
                         objective='val_accuracy',
                         max_epochs=10,
                         factor=3)
    stop_early = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=5)
    tuner.search(train_features, train_labels, epochs=15, validation_split=0.2, callbacks=[stop_early])

    # Get the optimal hyperparameters
    best_hps = tuner.get_best_hyperparameters(num_trials=1)[0]

    print(f"""
        The hyperparameter search is complete.
        Number of units in the first densely-connected layer is {best_hps['first_layer_units']} with activation function {best_hps['first_layer_activation']}.
        Number of units in the second densely-connected layer is {best_hps['second_layer_units']} with activation function {best_hps['second_layer_activation']}.
        Number of units in the third densely-connected layer is {best_hps['third_layer_units']} with activation function {best_hps['third_layer_activation']}.
        Number of units in the fourth densely-connected layer is {best_hps['fourth_layer_units']} with activation function {best_hps['fourth_layer_activation']}.
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
