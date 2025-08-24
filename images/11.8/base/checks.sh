#!/usr/bin/env bash
set -e

echo "[CHECK] cuDNN-Version..."
if dpkg -s libcudnn8 2>/dev/null | grep -q "Version: 8.7.0.84-1+cuda11.8"; then
  echo "[OK] libcudnn8 ist 8.7.0.84-1+cuda11.8"
else
  echo "[FAIL] libcudnn8 nicht korrekt gepinnt (erwartet 8.7.0.84-1+cuda11.8)"
  dpkg -s libcudnn8 || true
  exit 1
fi

echo "[CHECK] CUDA/BLAS/cuDNN Libraries ladbar..."
python3 - <<'PY'
import sys, ctypes
def load_any(names):
    for n in names:
        try:
            ctypes.CDLL(n)
            print("[OK]", n)
            return True
        except OSError:
            pass
    print("[FAIL] none of", names, "could be loaded")
    return False

ok = True
ok &= load_any(["libcudart.so","libcudart.so.11.0"])
ok &= load_any(["libcublas.so","libcublas.so.11"])
ok &= load_any(["libcudnn.so.8","libcudnn.so"])
sys.exit(0 if ok else 1)
PY
