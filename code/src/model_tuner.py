import keras_tuner as kt
import numpy as np
import tensorflow as tf
from tensorflow import keras


def model_builder(hp):
    model = keras.Sequential()

    # first layer
    hp_first_layer_units = hp.Int('first_layer_units', min_value=32, max_value=4096, step=32)
    hp_first_layer_activation = hp.Choice('first_layer_activation', values=['relu', 'sigmoid', 'tanh'])
    model.add(
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
    hp_dropout_rate = hp.Choice('dropout-rate', values=[0, 0.1, 0.2])
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


if __name__ == '__main__':
    dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{simulators.get_all_simulator_names()[0]}"
                                   f"_vs_{quantum_computers.quantum_computer_names[1]}_dataset")

    # Get the total number of elements in the dataset
    num_elements = tf.data.experimental.cardinality(dataset).numpy()

    # Calculate the number of elements for training and testing
    train_size = int(0.8 * num_elements)

    # Create training and testing datasets
    train_dataset = dataset.take(train_size)
    test_dataset = dataset.skip(train_size)

    train_features, train_labels = tuple(zip(*train_dataset))
    test_features, test_labels = tuple(zip(*test_dataset))

    train_features = np.array(train_features)
    train_labels = np.array(train_labels)
    test_features = np.array(test_features)
    test_labels = np.array(test_labels)

    tuner = kt.Hyperband(model_builder,
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
    The optimal learning rate for the optimizer is {best_hps.get('learning_rate')}.
    """)

    # Train the model
    # Build the model with the optimal hyperparameters and train it on the data for 10 epochs
    model = tuner.hypermodel.build(best_hps)
    history = model.fit(train_features, train_labels, epochs=15, validation_split=0.2)

    val_acc_per_epoch = history.history['val_accuracy']
    best_epoch = val_acc_per_epoch.index(max(val_acc_per_epoch)) + 1
    print('Best epoch: %d' % (best_epoch,))

    hypermodel = tuner.hypermodel.build(best_hps)

    # Retrain the model
    hypermodel.fit(train_features, train_labels, epochs=best_epoch, validation_split=0.2)
    eval_result = hypermodel.evaluate(test_features, test_labels)
    print("[test loss, test accuracy]:", eval_result)
