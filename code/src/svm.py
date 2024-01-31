import numpy as np
from sklearn import svm
import tensorflow as tf


def train(clf, train_features, train_labels, test_features, test_labels):
    print("Training SVM...")
    clf.fit(train_features, train_labels)

    print(f"Testing Accuracy of SVM on {len(test_labels)} test samples ...")
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
    return acc_train, acc_test


def generate_accuracy_statistics(dataset_paths):
    for dataset_path in dataset_paths:
        # Get the total number of elements in the dataset
        num_elements = tf.data.experimental.cardinality(dataset).numpy()

        # Calculate the number of elements for training and testing
        train_size = int(0.8 * num_elements)

        # Create training and testing datasets
        train_dataset = dataset.take(train_size)
        test_dataset = dataset.skip(train_size)

        train_features, train_labels = tuple(zip(*train_dataset))
        test_features, test_labels = tuple(zip(*test_dataset))
        train_features = np.array(train_features).tolist()
        train_labels = np.array(train_labels).tolist()
        test_features = np.array(test_features).tolist()
        test_labels = np.array(test_labels).tolist()
        for algNum, (algName, algFun) in enumerate([
            ["Linear SVM (LinearSVC)", svm.LinearSVC()],
            ["Linear SVM", svm.SVC(kernel='linear', decision_function_shape='ovr')],
            ["Poly d.2 SVM", svm.SVC(kernel='poly', degree=2, decision_function_shape='ovr')],
            ["Poly d.3 SVM", svm.SVC(kernel='poly', degree=3, decision_function_shape='ovr')],
            ["Poly d.4 SVM", svm.SVC(kernel='poly', degree=4, decision_function_shape='ovr')],
            ["RBF SVM", svm.SVC(kernel='rbf', decision_function_shape='ovr')],
        ]):
            (acc_train, acc_test) = train(algFun, train_features, train_labels, test_features, test_labels)
            toPrint = f"{algName}:\nTest acc.: {acc_test}; Train acc.: {acc_train};\n"
            print(toPrint)


if __name__ == "__main__":
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
    train_features = np.array(train_features).tolist()
    train_labels = np.array(train_labels).tolist()
    test_features = np.array(test_features).tolist()
    test_labels = np.array(test_labels).tolist()
    for algNum, (algName, algFun) in enumerate([
        ["Linear SVM (LinearSVC)", svm.LinearSVC()],
        ["Linear SVM", svm.SVC(kernel='linear', decision_function_shape='ovr')],
        ["Poly d.2 SVM", svm.SVC(kernel='poly', degree=2, decision_function_shape='ovr')],
        ["Poly d.3 SVM", svm.SVC(kernel='poly', degree=3, decision_function_shape='ovr')],
        ["Poly d.4 SVM", svm.SVC(kernel='poly', degree=4, decision_function_shape='ovr')],
        ["RBF SVM", svm.SVC(kernel='rbf', decision_function_shape='ovr')],
    ]):
        (acc_train, acc_test) = train(algFun, train_features, train_labels, test_features, test_labels)
        toPrint = f"{algName}:\nTest acc.: {acc_test}; Train acc.: {acc_train};\n"
        print(toPrint)
