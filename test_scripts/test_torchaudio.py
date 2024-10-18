#################################
####### register logging ########
#################################
import logging
logging.basicConfig(
    level=logging.INFO,  # Legt die niedrigste Protokollierungsstufe fest
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format der Log-Nachrichten
    datefmt='%d.%m.%Y %H:%M:%S',  # Format des Datums und der Uhrzeit
    handlers=[
        logging.FileHandler("/home/appuser/gputest/logs/app.log"),  # Loggt Nachrichten in eine Datei
        logging.StreamHandler()  # Loggt Nachrichten in die Konsole
    ]
)

import torchaudio
import torch

logging.info("=== Torchaudio Test ===")
# Überprüfe, ob CUDA verfügbar ist
logging.info("CUDA verfügbar (Torchaudio):", torch.cuda.is_available())
logging.info("CUDA Version (Torchaudio):", torch.version.cuda)
logging.info("cuDNN Version (Torchaudio):", torch.backends.cudnn.version())

# Teste, ob ein einfacher Audio-Tensor auf die GPU geladen werden kann
try:
    audio_tensor = torch.randn(16000)  # Erstelle einen simulierten Audiotensor
    audio_tensor = audio_tensor.to('cuda' if torch.cuda.is_available() else 'cpu')
    logging.info("Torchaudio nutzt die GPU.")
except RuntimeError as e:
    logging.error("Torchaudio konnte nicht auf die GPU zugreifen:", e)
