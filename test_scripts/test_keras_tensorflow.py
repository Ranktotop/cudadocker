import tensorflow as tf
from keras.models import load_model
from keras.preprocessing import image
import numpy as np
import logging
import os
import cv2

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

logging.info("=== TensorFlow und Keras Xception Modell Test ===")
# Überprüfe, ob eine GPU verfügbar ist und die CUDA- und cuDNN-Versionen
logging.info(f"CUDA verfügbar (TensorFlow): {len(gpus) > 0}")
logging.info(f"CUDA Version (TensorFlow): {tf.sysconfig.get_build_info().get('cuda_version', 'Unknown')}")
logging.info(f"cuDNN Version (TensorFlow): {tf.sysconfig.get_build_info().get('cudnn_version', 'Unknown')}")

# Lade das gleiche Keras-Modell wie im Produktionsskript
try:
    # Ersetze 'path_to_model.hdf5' durch den tatsächlichen Pfad zu deinem Modell
    model_path = '/home/appuser/gputest/test_scripts/_mini_XCEPTION.102-0.66.hdf5'  # Pfad zum Xception-Modell
    keras_model = load_model(model_path, compile=False)
    logging.info("Keras-Modell erfolgreich geladen.")
except Exception as e:
    logging.error(f"Fehler beim Laden des Keras-Modells: {str(e)}")
    exit(1)

# Erstelle oder lade ein Beispielbild
try:
    # Beispielbild laden oder erstellen
    # Um den Prozess genau zu spiegeln, könntest du ein echtes Bild verwenden
    # Beispiel: img = cv2.imread('path_to_image.jpg')

    # Für diesen Test verwenden wir ein zufälliges Gesicht
    img = cv2.imread('/home/appuser/gputest/test_scripts/testimage.jpg')  # Ersetze durch einen tatsächlichen Pfad

    if img is None:
        logging.error("Bild konnte nicht geladen werden.")
        exit(1)

    # Simuliere das gleiche Vorverarbeitungsverfahren wie im Produktionsskript
    # 1. Extrahiere das Gesicht aus dem Bild (hier das gesamte Bild oder einen Ausschnitt)
    # Hier kannst du die gleichen Koordinaten verwenden, falls vorhanden, oder das gesamte Bild nehmen
    face = img  # In diesem Test verwenden wir das gesamte Bild als "Gesicht"

    # 2. Konvertiere zu Graustufen
    face = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)

    # 3. Skaliere auf 64x64
    face = cv2.resize(face, (64, 64))

    # 4. Konvertiere zu einem Array
    face = image.img_to_array(face)

    # 5. Erweitere die Dimensionen
    face = np.expand_dims(face, axis=0)

    # 6. Normalisiere die Pixelwerte
    face /= 255

    logging.info("Bild erfolgreich vorverarbeitet.")

except Exception as e:
    logging.error(f"Fehler bei der Bildvorverarbeitung: {str(e)}")
    exit(1)

# Führe die Vorhersage aus
try:
    preds = keras_model.predict(face)
    logging.info(f"Vorhersage erfolgreich: {preds}")
except Exception as e:
    logging.error(f"Fehler bei der Vorhersage mit dem Keras-Modell: {str(e)}")
