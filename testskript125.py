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
