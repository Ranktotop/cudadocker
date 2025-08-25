#!/usr/bin/env bash
set -e

echo "[CHECK] CUDA_HOME gesetzt & gültig?"

fail() { echo "[FAIL] $1"; exit 1; }

# Vorhanden?
[ -n "${CUDA_HOME:-}" ] || fail "CUDA_HOME ist nicht gesetzt"
# Verzeichnis existiert?
[ -d "$CUDA_HOME" ]     || fail "CUDA_HOME existiert nicht: $CUDA_HOME"

# Symlink-Auflösung nur informativ
RESOLVED_CUDA="$(readlink -f "$CUDA_HOME" || echo "$CUDA_HOME")"
echo "[OK] CUDA_HOME: $CUDA_HOME -> $RESOLVED_CUDA"

echo "[CHECK] cuDNN-Version..."
# Erwartet: cuDNN 8.9.7 für CUDA 12.5, installiert als Paket "libcudnn8"
if dpkg -s libcudnn8 2>/dev/null | grep -q "Version: 8.9.7"; then
  echo "[OK] libcudnn8 ist 8.9.7 (cuDNN 8.9.7)"
else
  echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn8 Version 8.9.7.*)"
  dpkg -s libcudnn8 || true
  exit 1
fi

# 4) nvidia-smi
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[INFO] nvidia-smi:"
  nvidia-smi -L || true
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
ok &= load_any(["libcudart.so","libcudart.so.12"])
ok &= load_any(["libcublas.so","libcublas.so.12"])
ok &= load_any(["libcudnn.so.8","libcudnn.so"])
sys.exit(0 if ok else 1)
PY
