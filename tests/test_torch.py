import pytest

# Import torch, skipping the test if it is not installed
torch = pytest.importorskip("torch")


def test_torch_cuda_available():
    """Torch should report that CUDA is available."""
    assert torch.cuda.is_available(), "CUDA is not available for PyTorch"


def test_tensor_addition_on_device():
    """A simple tensor operation should run on the selected device."""
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    x = torch.randn(2, 2, device=device)
    y = x + 1
    assert y.device == device
