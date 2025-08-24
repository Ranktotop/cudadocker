#!/usr/bin/env bash
set -euo pipefail

echo "[CHECK] Torch-Layer (venv) – GPU REQUIRED"

fail() { echo "[FAIL] $1"; exit 1; }

# 0) venv vorhanden?
[ -x /opt/venv/bin/python ] || fail "/opt/venv/bin/python fehlt"

# 1) Torch & Zusatzmodule importieren und GPU durchsetzen
/opt/venv/bin/python - <<'PY'
import sys, importlib

def ok_import(m):
    importlib.import_module(m)
    print("[OK] import", m)

try:
    ok_import("torch")
    import torch
    print(f"[OK] torch {torch.__version__} (built for CUDA {torch.version.cuda})")
except Exception as e:
    print("[FAIL] torch Import:", e); sys.exit(1)

# Zusatzpakete
for m in ("torchvision","torchaudio","torch_audiomentations","torch_pitch_shift","torchmetrics"):
    try:
        ok_import(m)
    except Exception as e:
        print(f"[FAIL] Import {m}: {e}"); sys.exit(1)

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

# Nur Info: cuDNN
try:
    print("[INFO] cudnn available:", torch.backends.cudnn.is_available())
    print("[INFO] cudnn version:", torch.backends.cudnn.version())
except Exception as e:
    print("[INFO] cudnn info:", e)

# Pfad zur Torch-Lib für den Shell-Teil ausgeben
import os
libdir = os.path.join(os.path.dirname(torch.__file__), "lib")
print("TORCH_LIBDIR=", libdir)
PY

# 2) Torch-Shared-Libs vorhanden & ladbar (Präsenzcheck)
TORCH_LIB_DIR="$(
  /opt/venv/bin/python - <<'PY'
import os, torch
print(os.path.join(os.path.dirname(torch.__file__), "lib"))
PY
)"

[ -d "$TORCH_LIB_DIR" ] || fail "Torch lib dir fehlt: $TORCH_LIB_DIR"
echo "[OK] Torch lib dir: $TORCH_LIB_DIR"
ls -1 "$TORCH_LIB_DIR" | head -n 8 | sed 's/^/[INFO] lib: /'

# 3) (optional) nvidia-smi nur informativ
if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[INFO] nvidia-smi:"
  nvidia-smi -L || true
fi

echo "[SUCCESS] Torch-Layer OK (GPU sichtbar)"
