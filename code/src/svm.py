import numpy as np
from sklearn import svm
import tensorflow as tf

from data_sources import quantum_computers


def train(clf, train_features, train_labels, test_features, test_labels):
    print("Training SVM...")
    clf.fit(train_features, train_labels)

    print("Testing Accuracy of SVM ...")
    predictions = clf.predict(test_features)
    number_of_correct_predictions = 0
    for i in range(len(test_labels)):
        if test_labels[i] == predictions[i]:
            number_of_correct_predictions += 1
    acc = number_of_correct_predictions / len(test_labels)
    return acc


# Linear SVM
if __name__ == "__main__":
    dataset = tf.data.Dataset.load(f"../data/datasets/vs_datasets/walker_{quantum_computers.quantum_computer_names[0]}"
                                   f"_vs_{quantum_computers.quantum_computer_names[1]}_dataset")

    dataset = dataset.shuffle(10000)

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
        acc = train(algFun, train_features, train_labels, test_features, test_labels)
        toPrint = f"\n{algName}:\nTest acc.: {acc}\n"
        print(toPrint)
