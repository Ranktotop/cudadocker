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

import torch
import tensorflow as tf
import subprocess

logging.info("############### BASIC INFO ###############")
logging.info('CUDA verfügbar:')
logging.info(f"  PyTorch: {torch.cuda.is_available()}")
logging.info(f"  TensorFlow: {len(tf.config.list_physical_devices('GPU')) > 0}")
logging.info('\nCUDA Version:')
logging.info(f"  PyTorch: {torch.version.cuda}")
logging.info(f"  TensorFlow: {tf.sysconfig.get_build_info().get('cuda_version', 'Unknown')}")
logging.info('\ncuDNN Version:')
logging.info(f"  PyTorch: {torch.backends.cudnn.version()}")
logging.info(f"  TensorFlow: {tf.sysconfig.get_build_info().get('cudnn_version', 'Unknown')}")
logging.info('\nAnzahl der verfügbaren GPUs:')
logging.info(f"  PyTorch: {torch.cuda.device_count()}")
logging.info(f"  TensorFlow: {len(tf.config.list_physical_devices('GPU'))}")
logging.info('\nName der verwendeten GPU:')
logging.info(f"  PyTorch: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'Keine GPU gefunden'}")
logging.info(f"  TensorFlow: {tf.config.list_physical_devices('GPU')[0].name if len(tf.config.list_physical_devices('GPU')) > 0 else 'Keine GPU gefunden'}")

logging.info("############ TEST PYTORCH AND YOLO ############")
command = [
        "/gputest/.venv/bin/python", 
        "/gputest/test_scripts/test_pytorch_yolo.py"
    ]
try:
    subprocess.run(command, check=True)
    logging.info(f"Finished pytorch/yolo test successfully")
except subprocess.CalledProcessError as e:
    logging.error(f"Finished pytorch/yolo test with error {str(e)}")
    exit(1)

logging.info("############ TEST TENSORFLOW AND KERAS ############")
command = [
        "/gputest/.venv/bin/python", 
        "/gputest/test_scripts/test_keras_tensorflow.py"
    ]
try:
    subprocess.run(command, check=True)
    logging.info(f"Finished tensorflow/keras test successfully")
except subprocess.CalledProcessError as e:
    logging.error(f"Finished tensorflow/keras test with error {str(e)}")
    exit(1)

logging.info("############ TEST TORCHAUDIO ############")
command = [
        "/gputest/.venv/bin/python", 
        "/gputest/test_scripts/test_torchaudio.py"
    ]
try:
    subprocess.run(command, check=True)
    logging.info(f"Finished torchaudio test successfully")
except subprocess.CalledProcessError as e:
    logging.error(f"Finished torchaudio test with error {str(e)}")
    exit(1)