import pytest

# Import required modules, skipping if not available
torch = pytest.importorskip("torch")
torchaudio = pytest.importorskip("torchaudio")


def test_torchaudio_spectrogram():
    """Torchaudio should create a spectrogram from a random waveform."""
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    waveform = torch.randn(1, 16000, device=device)
    transform = torchaudio.transforms.Spectrogram().to(device)
    spec = transform(waveform)
    assert spec.device == device
    assert spec.ndim == 3
