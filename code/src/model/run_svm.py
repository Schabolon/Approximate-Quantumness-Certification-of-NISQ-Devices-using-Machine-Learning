import logging
from typing import Optional

import numpy as np
from sklearn import svm

from dataset import CustomDataset
from model.ml_wrapper import MLWrapper


class RunSVM(MLWrapper):

    def __init__(self):
        super().__init__("svm")

    @staticmethod
    def __train_and_evaluate(clf: svm.SVC, train_features, train_labels, test_features, test_labels) -> tuple[float, float]:
        """
        :param clf:
        :param train_features:
        :param train_labels:
        :param test_features:
        :param test_labels:
        :return: test accuracy and training accuracy.
        """
        logging.debug("Training SVM...")
        clf.fit(train_features, train_labels)
        logging.debug("Finished training SVM.")

        logging.debug(f"Testing Accuracy of SVM on {len(test_labels)} test samples ...")
        predictions_test = clf.predict(test_features)
        number_of_correct_predictions = 0
        for i in range(len(test_labels)):
            if test_labels[i] == predictions_test[i]:
                number_of_correct_predictions += 1
        acc_test = number_of_correct_predictions / len(test_labels)

        # Testing on training data
        predictions_train = clf.predict(train_features)
        number_of_correct_predictions = 0
        for i in range(len(train_labels)):
            if train_labels[i] == predictions_train[i]:
                number_of_correct_predictions += 1
        acc_train = number_of_correct_predictions / len(train_labels)
        return acc_test, acc_train

    @staticmethod
    def train_and_evaluate(custom_dataset: CustomDataset, test_dataset: Optional[CustomDataset] = None) -> float:
        if test_dataset is not None:
            test_features = test_dataset.features
            test_labels = test_dataset.labels
            # sets val_features and val_labels. (because test data is already provided)
            train_features, train_labels, val_features, val_labels = custom_dataset.get_test_train_split()
        else:
            train_features, train_labels, val_features, val_labels, test_features, test_labels = custom_dataset.get_test_train_validation_split()

        logging.info("Choosing the best SVM model by using validation data ...")
        max_accuracy = -1
        best_fun: svm.SVC
        best_alg_name = ""
        for alg_num, (alg_name, alg_fun) in enumerate([
            ["Linear SVM (LinearSVC)", svm.LinearSVC()],
            ["Poly d.2 SVM", svm.SVC(kernel='poly', degree=2)],
            ["Poly d.3 SVM", svm.SVC(kernel='poly', degree=3)],
            ["Poly d.4 SVM", svm.SVC(kernel='poly', degree=4)],
            ["RBF SVM", svm.SVC(kernel='rbf')],
        ]):
            # Uses the validation part of the dataset to find the algorithm which seems to fit best.
            acc_test, acc_train = RunSVM.__train_and_evaluate(alg_fun, val_features, val_labels, test_features, test_labels)
            logging.debug(f"SVM-Algorithm: {alg_name}")
            logging.debug(f"Test acc.: {acc_test}; (Train acc.: {acc_train})")
            if acc_test > max_accuracy:
                max_accuracy = acc_test
                best_fun = alg_fun
                best_alg_name = alg_name

        # Train best algorithm
        logging.info(f"Training best SVM algorithm {best_alg_name} on training data ...")
        acc_test, acc_train = RunSVM.__train_and_evaluate(best_fun, train_features, train_labels, test_features, test_labels)
        logging.info(f"SVM-Algorithm: {best_alg_name}")
        logging.info(f"Test acc.: {acc_test}; (Train acc.: {acc_train})")

        return max_accuracy
