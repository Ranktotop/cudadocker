#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] TensorFlow-PKG (ohne venv) – GPU REQUIRED"

fail() { echo "[FAIL] $1"; exit 1; }

# 0) Pfade prüfen
TF_ROOT="/opt/python/tf"
[ -d "$TF_ROOT" ] || fail "TF_ROOT fehlt: $TF_ROOT"
[ -d "$TF_ROOT/tensorflow" ] || fail "TensorFlow-Paket fehlt: $TF_ROOT/tensorflow"

# 0.1) cuDNN 8.9.3 aus dem Base prüfen (Package)
echo "[CHECK] cuDNN (erwartet 8.9.3.* + CUDA 12.x)"
dpkg -s libcudnn9-cuda-12 2>/dev/null | grep -q "Version: 8.9.3" \
  && echo "[OK] cuDNN 8.9.3 korrekt gepinnt" \
  || { echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn9-cuda-12 8.9.3.*)"; dpkg -s libcudnn9-cuda-12 || true; exit 1; }

# 1) Laufzeitpfade setzen (nur für diesen Check)
export PYTHONPATH="$TF_ROOT:${PYTHONPATH:-}"

# 2) Import + GPU erzwingen + Mini-Op
python3 - <<'PY'
import sys, os
print("[OK] python", sys.version.split()[0])

# NumPy-Version prüfen (TF 2.14 erwartet <2)
try:
    import numpy as np
    from packaging import version
    if version.parse(np.__version__).major >= 2:
        print(f"[FAIL] numpy=={np.__version__} (>=2) – erwarte <2"); sys.exit(1)
    else:
        print(f"[OK] numpy {np.__version__} (<2)")
except Exception as e:
    print("[FAIL] numpy Import/Check:", e); sys.exit(1)

# TensorFlow importieren
try:
    import tensorflow as tf
    print("[OK] tensorflow", tf.__version__)
except Exception as e:
    print("[FAIL] tensorflow Import:", e); sys.exit(1)

# GPU MUSS sichtbar sein
gpus = tf.config.list_physical_devices('GPU')
if not gpus:
    print("[FAIL] Keine GPU sichtbar. Container mit '--gpus all' starten."); sys.exit(2)
print(f"[OK] GPUs sichtbar: {len(gpus)} ->", [g.name for g in gpus])

# Mini-GPU-Test
try:
    with tf.device('/GPU:0'):
        import numpy as _np
        a = tf.constant(_np.random.randn(512,512).astype('float32'))
        b = tf.constant(_np.random.randn(512,512).astype('float32'))
        c = tf.matmul(a, b)
        _ = c.numpy().mean()
    print("[OK] tf.matmul auf GPU erfolgreich")
except Exception as e:
    print("[FAIL] GPU-Op fehlgeschlagen:", e); sys.exit(3)

# Info: Build (CUDA/cuDNN) – nur Info, kein Fail
try:
    from tensorflow.python.platform import build_info as tfbi
    bi = tfbi.build_info
    print("[INFO] build cuda:", bi.get('cuda_version'), "cudnn:", bi.get('cudnn_version'))
except Exception as e:
    try:
        import tensorflow as tf
        print("[INFO] sysconfig build:", tf.sysconfig.get_build_info())
    except Exception as e2:
        print("[INFO] build info nicht verfügbar:", e, "|", e2)
PY

# 3) (optional) ein paar Dateien listen (nur Info)
if [ -d "$TF_ROOT/tensorflow/python" ]; then
  echo "[INFO] Beispiel .so/.py in tensorflow/python:"
  ls -1 "$TF_ROOT"/tensorflow/python | head -n 8 | sed 's/^/[INFO]   /' || true
fi

# 4) optional: nvidia-smi
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[INFO] nvidia-smi:"
  nvidia-smi -L || true
fi

echo "[SUCCESS] TensorFlow-PKG OK (GPU sichtbar)"
