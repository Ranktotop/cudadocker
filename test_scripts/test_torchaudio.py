#################################
####### register logging ########
#################################
import logging
logging.basicConfig(
    level=logging.INFO,  # Legt die niedrigste Protokollierungsstufe fest
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format der Log-Nachrichten
    datefmt='%d.%m.%Y %H:%M:%S',  # Format des Datums und der Uhrzeit
    handlers=[
        logging.FileHandler("/gputest/logs/app.log"),  # Loggt Nachrichten in eine Datei
        logging.StreamHandler()  # Loggt Nachrichten in die Konsole
    ]
)

import torchaudio
import torch

print("=== Torchaudio Test ===")
# Überprüfe, ob CUDA verfügbar ist
print("CUDA verfügbar (Torchaudio):", torch.cuda.is_available())
print("CUDA Version (Torchaudio):", torch.version.cuda)
print("cuDNN Version (Torchaudio):", torch.backends.cudnn.version())

# Teste, ob ein einfacher Audio-Tensor auf die GPU geladen werden kann
try:
    audio_tensor = torch.randn(16000)  # Erstelle einen simulierten Audiotensor
    audio_tensor = audio_tensor.to('cuda' if torch.cuda.is_available() else 'cpu')
    print("Torchaudio nutzt die GPU.")
except RuntimeError as e:
    print("Torchaudio konnte nicht auf die GPU zugreifen:", e)
