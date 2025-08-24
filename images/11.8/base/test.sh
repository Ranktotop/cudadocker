#!/usr/bin/env bash
set -euo pipefail

# Default: dein Dockerfile unter images/11.8/base/Dockerfile
DOCKERFILE="${1:-images/11.8/base/Dockerfile}"
IMAGE="cudadocker:118_base"
CONTEXT="$(dirname "$DOCKERFILE")"

echo "=== Building image from $DOCKERFILE ==="
docker build -q -f "$DOCKERFILE" -t "$IMAGE" "$CONTEXT"

echo "=== Testing CUDA Runtime and cuDNN ==="
docker run --rm "$IMAGE" bash -lc '
set -e
echo "[CHECK] cuDNN version..."
dpkg -s libcudnn8 | grep -q "Version: 8.7.0.84-1+cuda11.8" && echo "[OK] cuDNN 8.7 pinned"

echo "[CHECK] Loading core CUDA libs..."
python3 - <<PY
import sys, ctypes

def check_libs(candidates):
    for name in candidates:
        try:
            ctypes.CDLL(name)
            print(f"[OK] {name}")
            return
        except OSError:
            pass
    print(f"[FAIL] none of {candidates} could be loaded")
    sys.exit(1)

check_libs(["libcudart.so", "libcudart.so.11.0"])
check_libs(["libcublas.so", "libcublas.so.11"])
check_libs(["libcudnn.so.8", "libcudnn.so"])
print("[SUCCESS] All required CUDA/cuDNN libs loaded")
PY
'

echo "✅ All checks passed for image built from $DOCKERFILE"
