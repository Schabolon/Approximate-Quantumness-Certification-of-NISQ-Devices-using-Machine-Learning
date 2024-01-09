import pickle
import glob
import os
import tensorflow as tf

#TODO make data more-dimensional. Use all 9 runs as separate dimensions
if __name__ == "__main__":
    quantum_computer = 0
    simulated = 1

    data_pairs = []
    # Add quantum computer runs
    print("Processing quantum computer data ...")
    machines = ['ibmq_athens', 'ibmq_athens-splitA', 'ibmq_athens-splitB', 'ibmq_athens-split10A', 'ibmq_athens-split10B', 'ibmq_athens-split10C', 'ibmq_athens-split10D', 'ibmq_athens-split10E', 'ibmq_athens-split10F', 'ibmq_athens-split10G', 'ibmq_athens-split10H', 'ibmq_athens-split10I', 'ibmq_athens-split10J', 'ibmq_santiago', 'ibmq_casablanca', 'ibmq_casablanca-bis', 'ibmq_5_yorktown', 'ibmq_bogota', 'ibmq_lima', 'ibmq_quito']
    for machine in machines:
        for filename in sorted(glob.glob(os.path.join("../data/quantum_computer/walker", '{}-'.format(machine) + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append((quantum_computer, memory_int))

    # Add simulated runs
    print("Processing simulated data ...")
    names = ["aersimulator_density_matrix", "aersimulator_matrix_product_state", "aersimulator_statevector", "qasmsimulator_default", "aersimulator_default", "statevectorsimulator_default"]
    for name in names:
        for filename in sorted(
                glob.glob(os.path.join("../data/simulated/walker", '{}-'.format(name) + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append((simulated, memory_int))

    labels, features = zip(*data_pairs)
    features = tf.constant(features, dtype=tf.int32) #TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.int8)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save("../data/datasets/mixed_datasets/walker_dataset")
