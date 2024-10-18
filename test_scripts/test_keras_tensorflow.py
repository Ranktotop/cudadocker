import tensorflow as tf
from keras.models import Sequential
from keras.layers import Dense
import logging

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
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print("Speicherwachstum für GPU aktiviert.")
    except RuntimeError as e:
        print("Fehler beim Setzen der Speicherwachstumsoption:", e)

print("=== TensorFlow und Keras Test ===")
# Überprüfe, ob eine GPU verfügbar ist und die CUDA- und cuDNN-Versionen
print("CUDA verfügbar (TensorFlow):", len(gpus) > 0)
print("CUDA Version (TensorFlow):", tf.sysconfig.get_build_info().get('cuda_version', 'Unknown'))
print("cuDNN Version (TensorFlow):", tf.sysconfig.get_build_info().get('cudnn_version', 'Unknown'))

# Erstelle ein einfaches Keras-Modell zum Testen der GPU-Nutzung
print("\nErstelle und teste ein einfaches Keras-Modell:")
keras_model = Sequential([
    Dense(64, activation='relu', input_shape=(1000,)),
    Dense(10, activation='softmax')
])

# Kompiliere das Keras-Modell
keras_model.compile(optimizer='adam', loss='categorical_crossentropy')

# Teste, ob das Modell auf die GPU verschoben werden kann
try:
    with tf.device('/GPU:0'):
        keras_model.predict(tf.random.normal([1, 1000]))
    print("Keras nutzt die GPU.")
except RuntimeError as e:
    print("Keras konnte nicht auf die GPU zugreifen:", e)
