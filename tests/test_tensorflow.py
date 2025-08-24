import pytest

# Import TensorFlow and Keras, skipping if not installed
tf = pytest.importorskip("tensorflow")
keras = pytest.importorskip("keras")


def test_tensorflow_cuda_available():
    """TensorFlow should detect at least one GPU."""
    gpus = tf.config.list_physical_devices("GPU")
    assert gpus, "No GPU devices available for TensorFlow"
