import tensorflow as tf


class EarlyStopCallback(tf.keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs=None):
        val_acc = logs["val_accuracy"]
        if val_acc >= 0.999 and epoch >= 5:
            self.model.stop_training = True
