import logging
import torch
import torchaudio

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%d.%m.%Y %H:%M:%S',
    handlers=[
        logging.FileHandler("/home/appuser/gputest/logs/app.log"),
        logging.StreamHandler()
    ]
)

logging.info("=== Torchaudio Test ===")

# Überprüfe, ob CUDA verfügbar ist
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
logging.info(f"CUDA verfügbar: {torch.cuda.is_available()}")
logging.info(f"Verwendetes Gerät: {device}")

try:
    # Generiere ein zufälliges Audiosignal (Wellenform)
    sample_rate = 16000
    duration = 1  # in Sekunden
    waveform = torch.randn(1, sample_rate * duration).to(device)

    # Wende eine torchaudio-Transformation an (z.B. Spektrogramm)
    spectrogram_transform = torchaudio.transforms.Spectrogram().to(device)
    spectrogram = spectrogram_transform(waveform)

    logging.info("Torchaudio nutzt die GPU für Transformationen.")
except Exception as e:
    logging.error(f"Fehler bei der Verwendung von torchaudio: {str(e)}")
