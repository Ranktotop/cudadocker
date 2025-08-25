#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] TensorFlow-PKG (ohne venv) – GPU REQUIRED"

fail() { echo "[FAIL] $1"; exit 1; }

# 0) Pfade prüfen
TF_ROOT="/opt/python/tf"
[ -d "$TF_ROOT" ] || fail "TF_ROOT fehlt: $TF_ROOT"
[ -d "$TF_ROOT/tensorflow" ] || fail "TensorFlow-Paket fehlt: $TF_ROOT/tensorflow"

# 0.1) cuDNN 9.3 aus dem Base prüfen (Package)
echo "[CHECK] cuDNN (erwartet 8.9.7.* + CUDA 12.x)"
dpkg -s libcudnn8 2>/dev/null | grep -q "Version: 8.9.7.29-1+cuda12.2" \
  && echo "[OK] cuDNN 8.9.7 korrekt gepinnt" \
  || { echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn8 8.9.7.*)"; dpkg -s libcudnn8 || true; exit 1; }

# 1) Laufzeitpfade setzen (nur für diesen Check)
export PYTHONPATH="$TF_ROOT:${PYTHONPATH:-}"
# (optional fürs Debugging: TF Logs einschalten)
# export TF_CPP_MIN_LOG_LEVEL=0

# 2) Import + GPU erzwingen + Mini-Op
python3 - <<'PY'
import sys, os
from packaging import version

print("[OK] python", sys.version.split()[0])

# NumPy-Version prüfen (hier: <2, da im Build so gepinnt)
try:
    import numpy as np
    if version.parse(np.__version__).major >= 2:
        print(f"[FAIL] numpy=={np.__version__} (>=2) – erwarte <2"); sys.exit(1)
    else:
        print(f"[OK] numpy {np.__version__} (<2)")
except Exception as e:
    print("[FAIL] numpy Import/Check:", e); sys.exit(1)

# TensorFlow importieren und Version prüfen (2.16.1)
try:
    import tensorflow as tf
    print("[OK] tensorflow", tf.__version__)
    if not tf.__version__.startswith("2.16.1"):
        print("[FAIL] Unerwartete TF-Version – erwarte 2.16.1"); sys.exit(1)
except Exception as e:
    print("[FAIL] tensorflow Import:", e); sys.exit(1)

# Optional: Prüfen, ob TF mit CUDA gebaut wurde (nur Info)
try:
    built_cuda = tf.test.is_built_with_cuda()
    print("[INFO] TF built with CUDA:", built_cuda)
except Exception:
    pass

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
        _ = float(c.numpy().mean())
    print("[OK] tf.matmul auf GPU erfolgreich")
except Exception as e:
    print("[FAIL] GPU-Op fehlgeschlagen:", e); sys.exit(3)

# Build-Info (nur Info, kein
