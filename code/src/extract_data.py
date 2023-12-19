import pickle
import glob
import os
import tensorflow as tf

if __name__ == "__main__":
    data_pairs = []
    # Add quantum computer runs
    machines = ["ibmq_athens"]
    for machine in machines:
        for filename in sorted(glob.glob(os.path.join("../data/quantum_computer/walker", '{}-'.format(machine) + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append(("quantum_computer", memory_int))

    # Add simulated runs
    names = ["aersimulator_density_matrix"]
    for name in names:
        for filename in sorted(
                glob.glob(os.path.join("../data/simulated/walker", '{}-'.format(name) + ('[0-9]' * 6) + '.p'))):
            results = pickle.load(open(filename, 'rb'))
            for t in range(len(results['results'])):
                memory_int = list(map(lambda x: int(x, 16), results['results'][t]['data']['memory']))
                data_pairs.append(("simulated", memory_int))

    labels, features = zip(*data_pairs)
    features = tf.constant(features, dtype=tf.int32) #TODO sollte ein float verwendet werden? (muss auf Werte zwischen 0 und 1 normiert werden?)
    labels = tf.constant(labels, dtype=tf.string)

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices((features, labels))

    dataset = dataset.shuffle(buffer_size=len(features))

    dataset.save("../data/mixed_datasets/walker_dataset")
