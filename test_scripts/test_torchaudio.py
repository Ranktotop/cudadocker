import logging
import torch
import torchaudio
import faulthandler

#################################
####### register logging ########
#################################
logging.basicConfig(
    level=logging.INFO,  # Legt die niedrigste Protokollierungsstufe fest
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format der Log-Nachrichten
    datefmt='%d.%m.%Y %H:%M:%S',  # Format des Datums und der Uhrzeit
    handlers=[
        logging.FileHandler("/home/appuser/gputest/logs/app.log"),  # Loggt Nachrichten in eine Datei
        logging.StreamHandler()  # Loggt Nachrichten in die Konsole
    ]
)

logging.info("=== Torchaudio Test ===")

# Überprüfe, ob CUDA verfügbar ist
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
logging.info(f"CUDA verfügbar: {torch.cuda.is_available()}")
logging.info(f"Verwendetes Gerät: {device}")

# Generiere ein zufälliges Audiosignal (Wellenform)
sample_rate = 16000
duration = 1  # in Sekunden
try:
    faulthandler.enable()
    logging.info("Erstelle zufällige Wellenform...")
    waveform = torch.randn(1, sample_rate * duration).to(device)
    logging.info("Wellenform erstellt.")

    logging.info("Erstelle Spektrogramm-Transformation...")
    spectrogram_transform = torchaudio.transforms.Spectrogram().to(device)
    logging.info("Transformation erstellt.")

    logging.info("Wende Transformation an...")
    spectrogram = spectrogram_transform(waveform)
    logging.info("Transformation angewendet.")

    logging.info("Torchaudio nutzt die GPU für Transformationen.")
    faulthandler.disable()
except Exception as e:
    logging.error(f"Fehler bei der Verwendung von torchaudio: {str(e)}")

