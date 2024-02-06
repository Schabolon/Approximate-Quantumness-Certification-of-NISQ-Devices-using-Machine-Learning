import logging

from sklearn import svm

from dataset import CustomDataset
from model.ml_wrapper import MLWrapper


class RunSVM(MLWrapper):

    def __init__(self):
        super().__init__("svm")

    @staticmethod
    def __train_and_evaluate(clf, train_features, train_labels, test_features, test_labels) -> tuple[float, float]:
        """
        :param clf:
        :param train_features:
        :param train_labels:
        :param test_features:
        :param test_labels:
        :return: test accuracy and training accuracy.
        """
        logging.info("Training SVM...")
        clf.fit(train_features, train_labels)
        logging.info("Finished training SVM.")

        logging.info(f"Testing Accuracy of SVM on {len(test_labels)} test samples ...")
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
    def train_and_evaluate(custom_dataset: CustomDataset) -> float:
        train_features, train_labels, test_features, test_labels = custom_dataset.get_test_train_split()

        max_accuracy = -1
        # TODO use only 20% of the data for "validation" (which algorithm to choose)
        # TODO or get rid of multiple algorithms all together? (and only use RBF?)
        for alg_num, (alg_name, alg_fun) in enumerate([
            ["Linear SVM (LinearSVC)", svm.LinearSVC()],
            ["Linear SVM", svm.SVC(kernel='linear', decision_function_shape='ovr')],
            ["Poly d.2 SVM", svm.SVC(kernel='poly', degree=2, decision_function_shape='ovr')],
            ["Poly d.3 SVM", svm.SVC(kernel='poly', degree=3, decision_function_shape='ovr')],
            ["Poly d.4 SVM", svm.SVC(kernel='poly', degree=4, decision_function_shape='ovr')],
            ["RBF SVM", svm.SVC(kernel='rbf', decision_function_shape='ovr')],
        ]):
            acc_test, acc_train = RunSVM.__train_and_evaluate(alg_fun, train_features, train_labels, test_features, test_labels)
            logging.info(f"SVM-Algorithm: {alg_name}")
            logging.info(f"Test acc.: {acc_test}; (Train acc.: {acc_train})")
            if acc_test > max_accuracy:
                max_accuracy = acc_test

        return max_accuracy
