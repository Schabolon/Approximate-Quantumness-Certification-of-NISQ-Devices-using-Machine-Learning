"""
Neural Net: a simple feed-forward-network.
"""
import logging
import tensorflow as tf

from dataset import CustomDataset


def evaluate_neural_net(custom_dataset: CustomDataset):
    train_dataset, test_dataset = custom_dataset.get_dataset_test_train_split()

    model = tf.keras.Sequential([
        tf.keras.layers.Dense(1000, input_shape=(8000,), activation='sigmoid'),
        tf.keras.layers.Dense(1000, activation='sigmoid'),
        tf.keras.layers.Dense(500, activation='sigmoid'),
        tf.keras.layers.Dense(128, activation='relu'),
        # use 'sigmoid' for output activation, squishes the values between 0 and 1.
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])

    model.compile(optimizer='adam',
                  loss=tf.keras.losses.BinaryCrossentropy(from_logits=False),
                  metrics=['accuracy'])

    model.fit(train_dataset.batch(32), epochs=5, verbose=1)

    test_loss, test_acc = model.evaluate(test_dataset.batch(32), verbose=1)

    logging.debug(f"Neural Net test accuracy: {test_acc}")

    return test_acc
