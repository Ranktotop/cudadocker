#################################
####### register logging ########
#################################
import logging
import os

# Setze den LD_LIBRARY_PATH vor allen anderen Imports
os.environ['LD_LIBRARY_PATH'] = '/usr/local/cuda/lib64'

logging.basicConfig(
    level=logging.INFO,  # Legt die niedrigste Protokollierungsstufe fest
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format der Log-Nachrichten
    datefmt='%d.%m.%Y %H:%M:%S',  # Format des Datums und der Uhrzeit
    handlers=[
        logging.FileHandler("/home/appuser/gputest/logs/app.log"),  # Loggt Nachrichten in eine Datei
        logging.StreamHandler()  # Loggt Nachrichten in die Konsole
    ]
)

#################################
####### Importiere Module #######
#################################
import sys
import cv2
import keras  # Importiere keras direkt für die Versionsabfrage
from ultralytics import YOLO
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
from collections import defaultdict

import tensorflow as tf

# Begrenze den Speicherverbrauch der GPU durch TensorFlow
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        # Aktiviert das Speicherwachstum
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        logging.info("Speicherwachstum für GPU aktiviert.")
    except RuntimeError as e:
        logging.error(f"Fehler beim Setzen der Speicherwachstumsoption: {str(e)}")
else:
    logging.error("Keine GPU verfügbar.")

# Ausgabe von Versionen und Umgebungsvariablen
logging.info(f"TensorFlow Version: {tf.__version__}")
logging.info(f"Keras Version: {keras.__version__}")  # Korrekt abgefragt über das direkte Importieren von keras
logging.info(f"LD_LIBRARY_PATH: {os.environ.get('LD_LIBRARY_PATH')}")
logging.info(f"CUDA Version: {tf.sysconfig.get_build_info().get('cuda_version', 'Unknown')}")
logging.info(f"cuDNN Version: {tf.sysconfig.get_build_info().get('cudnn_version', 'Unknown')}")

#################################
##### Lade Modelle ##############
#################################
try:
    # Pfade zu den Modellen anpassen
    yolo_model_path = '/home/appuser/gputest/test_scripts/yolov8x-face-lindevs.pt'
    xception_model_path = '/home/appuser/gputest/test_scripts/_mini_XCEPTION.102-0.66.hdf5'

    # Lade YOLO-Modell
    yolo_model = YOLO(yolo_model_path)
    logging.info("YOLO-Modell erfolgreich geladen.")

    # Lade Xception-Modell
    keras_model = load_model(xception_model_path, compile=False)
    logging.info("Xception-Modell erfolgreich geladen.")
except Exception as e:
    logging.error(f"Fehler beim Laden der Modelle: {str(e)}")
    exit(1)

#################################
##### Prozess simulieren ########
#################################
try:
    # Lade ein Beispielbild
    img = cv2.imread('/home/appuser/gputest/test_scripts/testimage.jpg')  # Pfad anpassen
    if img is None:
        logging.error("Bild konnte nicht geladen werden.")
        exit(1)

    # Führe YOLO-Vorhersage durch
    results = yolo_model.predict(img, conf=0.5)

    emotions = ["angry", "disgust", "scared", "happy", "sad", "surprised", "neutral"]
    emotion_data = []

    for result in results:
        for box in result.boxes:
            # Extrahiere das Gesicht aus dem Bild
            x1, y1, x2, y2 = int(box.xyxy[0][0]), int(box.xyxy[0][1]), int(box.xyxy[0][2]), int(box.xyxy[0][3])
            face = img[y1:y2, x1:x2]
            face = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
            face = cv2.resize(face, (64, 64))
            face = image.img_to_array(face)
            face = np.expand_dims(face, axis=0)
            face /= 255

            # Führe Emotionserkennung durch
            preds = keras_model.predict(face)
            emotion_score = np.max(preds)
            emotion_label = emotions[preds.argmax()]

            # Speichere Emotionsdaten
            emotion_data.append((emotion_label, emotion_score, (x1, y1, x2, y2)))

            # Optional: Zeichne Rahmen und Text auf das Bild
            cv2.rectangle(img, (x1, y1), (x2, y2), (255, 0, 0), 2)
            text = f"{emotion_label} ({emotion_score:.2f})"
            cv2.putText(img, text, (x1, y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 2)

    logging.info(f"Emotionserkennung erfolgreich: {emotion_data}")

    # Optional: Zeige das Bild an
    # cv2.imshow("Ergebnisse", img)
    # cv2.waitKey(0)
except Exception as e:
    logging.error(f"Fehler bei der Emotionserkennung: {str(e)}")
    exit(1)
