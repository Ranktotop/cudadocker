from ultralytics import YOLO
import torch
import logging

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

logging.info("=== PyTorch und YOLO Test ===")
# Überprüfe, ob CUDA verfügbar ist
logging.info("CUDA verfügbar (PyTorch):", torch.cuda.is_available())
logging.info("CUDA Version (PyTorch):", torch.version.cuda)
logging.info("cuDNN Version (PyTorch):", torch.backends.cudnn.version())

# Lade das YOLO-Modell
yolo_model = YOLO('yolov8n.pt')

# Führe eine Vorhersage auf einem Beispielbild durch
yolo_results = yolo_model('https://ultralytics.com/images/zidane.jpg')

# Ausgabe der verwendeten Hardware und Vorhersageergebnisse
logging.info("Verwendetes Gerät (YOLO):", yolo_model.device)

# Zeige die Ergebnisse an
for result in yolo_results:
    result.show()  # Zeigt das Bild mit den Vorhersagen an
