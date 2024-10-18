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

from ultralytics import YOLO
import torch

print("=== PyTorch und YOLO Test ===")
# Überprüfe, ob CUDA verfügbar ist
print("CUDA verfügbar (PyTorch):", torch.cuda.is_available())
print("CUDA Version (PyTorch):", torch.version.cuda)
print("cuDNN Version (PyTorch):", torch.backends.cudnn.version())

# Lade das YOLO-Modell
yolo_model = YOLO('yolov8n.pt')

# Führe eine Vorhersage auf einem Beispielbild durch
yolo_results = yolo_model('https://ultralytics.com/images/zidane.jpg')

# Ausgabe der verwendeten Hardware und Vorhersageergebnisse
print("Verwendetes Gerät (YOLO):", yolo_model.device)
yolo_results.show()  # Zeigt das Bild mit den Vorhersagen an
