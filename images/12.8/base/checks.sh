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
# Erwartet: cuDNN 9.10.2.21 für CUDA 12.x, installiert über cudnn-local-repo als Paket "libcudnn9-cuda-12"
if dpkg -s libcudnn9-cuda-12 2>/dev/null | grep -q "Version: 9.10.2.21"; then
  echo "[OK] libcudnn9-cuda-12 ist 9.10.2.21 (cuDNN 9.10.2.21)"
else
  echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn9-cuda-12 Version 9.10.2.21.*)"
  dpkg -s libcudnn9-cuda-12 || true
  exit 1
fi

# nvidia-smi
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
ok &= load_any(["libcudnn.so.9","libcudnn.so"])
sys.exit(0 if ok else 1)
PY
