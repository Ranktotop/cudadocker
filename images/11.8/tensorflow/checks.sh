#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] TensorFlow (venv) – GPU REQUIRED"
[ -x /opt/venv-tf/bin/python ] || { echo "[FAIL] /opt/venv-tf/bin/python fehlt"; exit 1; }

# Import + GPU erzwingen
/opt/venv-tf/bin/python - <<'PY'
import sys
import tensorflow as tf

print("[OK] python", sys.version.split()[0])
print("[OK] tensorflow", tf.__version__)

gpus = tf.config.list_physical_devices('GPU')
if not gpus:
    print("[FAIL] Keine GPU sichtbar. Container mit '--gpus all' starten."); sys.exit(2)

print(f"[OK] GPUs sichtbar: {len(gpus)} ->", [g.name for g in gpus])

# Mini-GPU-Test
try:
    with tf.device('/GPU:0'):
        import numpy as np
        a = tf.constant(np.random.randn(512,512).astype('float32'))
        b = tf.constant(np.random.randn(512,512).astype('float32'))
        c = tf.matmul(a, b)
        _ = c.numpy().mean()
    print("[OK] tf.matmul auf GPU erfolgreich")
except Exception as e:
    print("[FAIL] GPU-Op fehlgeschlagen:", e); sys.exit(3)

# Info: Build (CUDA/cuDNN), nicht als Fail-Kriterium
try:
    from tensorflow.python.platform import build_info as tfbi
    bi = tfbi.build_info
    print("[INFO] build cuda:", bi.get('cuda_version'), "cudnn:", bi.get('cudnn_version'))
except Exception as e:
    print("[INFO] build info nicht verfügbar:", e)
PY

echo "[SUCCESS] TensorFlow-Layer OK (GPU sichtbar)"
