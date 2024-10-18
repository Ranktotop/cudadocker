import tensorflow as tf
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
import logging
import os

#################################
####### register logging ########
#################################
logging.basicConfig(
    level=logging.INFO,  # Legt die niedrigste Protokollierungsstufe fest
    format='%(asctime)s - %(levelname)s - %(message)s',  # Format der Log-Nachrichten
    datefmt='%d.%m.%Y %H:%M:%S',  # Format des Datums und der Uhrzeit
    handlers=[
        logging.FileHandler("/gputest/logs/app.log"),  # Loggt Nachrichten in eine Datei
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
        logging.error("Fehler beim Setzen der Speicherwachstumsoption:", e)

logging.info("=== TensorFlow und Keras Convolutional Layer Test ===")
# Überprüfe, ob eine GPU verfügbar ist und die CUDA- und cuDNN-Versionen
logging.info("CUDA verfügbar (TensorFlow):", len(gpus) > 0)
logging.info("CUDA Version (TensorFlow):", tf.sysconfig.get_build_info().get('cuda_version', 'Unknown'))
logging.info("cuDNN Version (TensorFlow):", tf.sysconfig.get_build_info().get('cudnn_version', 'Unknown'))

# Erstelle ein einfaches Keras-Modell mit Convolutional Layers zum Testen der GPU-Nutzung
logging.info("\nErstelle und teste ein Keras-Modell mit Convolutional Layers:")
keras_model = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(64, 64, 3)),
    MaxPooling2D((2, 2)),
    Flatten(),
    Dense(64, activation='relu'),
    Dense(10, activation='softmax')
])

# Kompiliere das Keras-Modell
keras_model.compile(optimizer='adam', loss='categorical_crossentropy')

# Erstelle Dummy-Daten für die Eingabe
import numpy as np
dummy_input = np.random.rand(1, 64, 64, 3)

# Teste, ob das Modell auf der GPU Vorhersagen machen kann
try:
    with tf.device('/GPU:0'):
        preds = keras_model.predict(dummy_input)
    logging.info("Keras nutzt die GPU für Convolutional Layers.")
except RuntimeError as e:
    logging.error("Keras konnte nicht auf die GPU zugreifen:", e)
except Exception as e:
    logging.error("Ein Fehler ist aufgetreten:", e)
