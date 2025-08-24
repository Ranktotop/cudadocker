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
# Erwartet: cuDNN 8.7.3 für CUDA 12.5, installiert als Paket "libcudnn8"
if dpkg -s libcudnn8 2>/div/null | grep -q "Version: 8.7.3"; then
  echo "[OK] libcudnn8 ist 8.7.3 (cuDNN 8.7.3)"
else
  echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn8 Version 8.7.3.*-1+cuda12.5)"
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
ok &= load_any(["libcudart.so","libcudart.so.12"])
ok &= load_any(["libcublas.so","libcublas.so.12"])
ok &= load_any(["libcudnn.so.8","libcudnn.so"])
sys.exit(0 if ok else 1)
PY
