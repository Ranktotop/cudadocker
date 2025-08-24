#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Torch-PKG (ohne venv) – GPU REQUIRED"

fail() { echo "[FAIL] $1"; exit 1; }

# 0) Pfade prüfen
TORCH_ROOT="/opt/python/torch"
[ -d "$TORCH_ROOT" ] || fail "TORCH_ROOT fehlt: $TORCH_ROOT"
[ -d "$TORCH_ROOT/torch/lib" ] || fail "Torch .so-Verzeichnis fehlt: $TORCH_ROOT/torch/lib"

# 1) Laufzeitpfade setzen (nur für diesen Check)
export PYTHONPATH="$TORCH_ROOT:${PYTHONPATH:-}"
export LD_LIBRARY_PATH="$TORCH_ROOT/torch/lib:${LD_LIBRARY_PATH:-}"

# 2) Imports + GPU erzwingen
python3 - <<'PY'
import sys, importlib, os

def ok_import(m):
    importlib.import_module(m)
    print("[OK] import", m)

print("[OK] python", sys.version.split()[0])

# Torch
ok_import("torch")
import torch
print(f"[OK] torch {torch.__version__} (built for CUDA {torch.version.cuda})")

# Zusatzpakete
for m in ("torchvision","torchaudio","torch_audiomentations","torch_pitch_shift","torchmetrics"):
    ok_import(m)

# NumPy kompatibel?
import numpy as np
from packaging import version
if version.parse(np.__version__).major >= 2:
    print(f"[FAIL] numpy=={np.__version__} (>=2) – erwarte <2"); sys.exit(1)
else:
    print(f"[OK] numpy {np.__version__} (<2)")

# GPU MUSS sichtbar sein
if not torch.cuda.is_available():
    print("[FAIL] torch.cuda.is_available = False. Container mit '--gpus all' starten.")
    sys.exit(2)

dc = torch.cuda.device_count()
if dc < 1:
    print(f"[FAIL] Keine CUDA-Geräte sichtbar (count={dc}). Container mit '--gpus all' starten.")
    sys.exit(3)

name = torch.cuda.get_device_name(0)
cap  = torch.cuda.get_device_capability(0)
print(f"[OK] device count: {dc}")
print(f"[OK] device 0: {name} capability {cap}")

# Mini CUDA-Test (Matmul)
try:
    x = torch.randn(512,512, device="cuda"); y = torch.randn(512,512, device="cuda")
    z = (x @ y).mean().item()
    print("[OK] CUDA matmul ok; mean:", z)
except Exception as e:
    print("[FAIL] CUDA Matmul:", e); sys.exit(4)

# Info: cuDNN
try:
    print("[INFO] cudnn available:", torch.backends.cudnn.is_available())
    print("[INFO] cudnn version:", torch.backends.cudnn.version())
except Exception as e:
    print("[INFO] cudnn info:", e)

# Pfad-Info
import torch as _t
libdir = os.path.join(os.path.dirname(_t.__file__), "lib")
print("TORCH_LIBDIR=", libdir)
PY

# 3) lib-Verzeichnis kurz listen
echo "[OK] Torch lib dir: $TORCH_ROOT/torch/lib"
ls -1 "$TORCH_ROOT/torch/lib" | head -n 8 | sed 's/^/[INFO] lib: /'

# 4) optional: nvidia-smi
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[INFO] nvidia-smi:"
  nvidia-smi -L || true
fi

echo "[SUCCESS] Torch-PKG OK (GPU sichtbar)"
