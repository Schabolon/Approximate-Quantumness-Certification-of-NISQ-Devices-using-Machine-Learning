import keras_tuner as kt
import numpy as np
import tensorflow as tf
from tensorflow import keras

from data_sources import simulators, quantum_computers


def model_builder(hp):
    model = keras.Sequential()
    model.add(tf.keras.layers.Dense(1000, input_shape=(8000,), activation='relu')),

    # Tune the number of units in the first Dense layer
    # Choose an optimal value between 32-512
    hp_units = hp.Int('units', min_value=32, max_value=512, step=32)
    model.add(keras.layers.Dense(units=hp_units, activation='relu'))
    model.add(keras.layers.Dense(1, activation='sigmoid'))

    # Tune the learning rate for the optimizer
    # Choose an optimal value from 0.01, 0.001, or 0.0001
    hp_learning_rate = hp.Choice('learning_rate', values=[1e-2, 1e-3, 1e-4])

    model.compile(optimizer=keras.optimizers.Adam(learning_rate=hp_learning_rate),
                  loss=keras.losses.BinaryCrossentropy(from_logits=False),
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
                         factor=3,
                         directory='../tuner',
                         project_name='neural_network')
    stop_early = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=5)
    tuner.search(train_features, train_labels, epochs=15, validation_split=0.2, callbacks=[stop_early])

    # Get the optimal hyperparameters
    best_hps = tuner.get_best_hyperparameters(num_trials=1)[0]

    print(f"""
    The hyperparameter search is complete. The optimal number of units in the first densely-connected
    layer is {best_hps.get('units')} and the optimal learning rate for the optimizer is {best_hps.get('learning_rate')}.
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


