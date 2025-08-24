#!/usr/bin/env bash
set -e

echo "[CHECK] CUDA_HOME/CUB_HOME gesetzt & gültig?"

fail() { echo "[FAIL] $1"; exit 1; }

# 1) Umgebungsvariablen vorhanden & Verzeichnisse existieren
[ -n "${CUDA_HOME:-}" ] || fail "CUDA_HOME ist nicht gesetzt"
[ -d "$CUDA_HOME" ]     || fail "CUDA_HOME existiert nicht: $CUDA_HOME"
[ -n "${CUB_HOME:-}" ]  || fail "CUB_HOME ist nicht gesetzt"
[ -d "$CUB_HOME" ]      || fail "CUB_HOME existiert nicht: $CUB_HOME"

# 2) CUDA Symlink-Auflösung zeigen (sollte auf .../cuda-11.8 zeigen)
RESOLVED_CUDA="$(readlink -f "$CUDA_HOME" || echo "$CUDA_HOME")"
echo "[OK] CUDA_HOME: $CUDA_HOME -> $RESOLVED_CUDA"

# 3) Wichtige Header prüfen (existieren wirklich)
[ -f "$CUDA_HOME/include/cuda.h" ] || fail "cuda.h fehlt unter $CUDA_HOME/include"
[ -d "$CUB_HOME/cub" ]             || fail "CUB-Verzeichnis fehlt unter $CUB_HOME/cub"
[ -f "$CUB_HOME/cub/cub.cuh" ]     || fail "cub.cuh fehlt (CUB nicht vollständig?)"

echo "[OK] Header vorhanden (cuda.h, cub/cub.cuh)"

# 4) Zentrale Laufzeit-Libs ladbar? (Driver-lib NICHT testen)
python3 - <<'PY'
import ctypes, sys
def ok(lib):
    try:
        ctypes.CDLL(lib); print("[OK] ladbar:", lib); return True
    except OSError:
        print("[FAIL] nicht ladbar:", lib); return False

oks = 0
oks += ok("libcudart.so")
oks += ok("libcudnn.so.8")
sys.exit(0 if oks==2 else 1)
PY

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
