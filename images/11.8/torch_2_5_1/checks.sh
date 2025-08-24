#!/usr/bin/env bash
set -e

echo "[CHECK] Python & Torch import"
python3 - <<'PY'
import sys, torch
print("[OK] python", sys.version.split()[0])
print("[OK] torch", torch.__version__, "cuda:", torch.version.cuda)

# cuDNN-Infos (kann None sein)
try:
    print("[INFO] cudnn available:", torch.backends.cudnn.is_available())
    print("[INFO] cudnn version:", torch.backends.cudnn.version())
except Exception as e:
    print("[WARN] cudnn info:", e)

# Zusatzpakete
mods = ["torchvision","torchaudio","torch_audiomentations","torch_pitch_shift","torchmetrics"]
for m in mods:
    try:
        __import__(m)
        print("[OK] import", m)
    except Exception as e:
        print("[FAIL] import", m, "->", e); raise

# CUDA-Verfügbarkeit (nicht zwingend in CI/ohne --gpus all)
if torch.cuda.is_available():
    print("[OK] torch.cuda.is_available = True")
    print("[INFO] device count:", torch.cuda.device_count())
    print("[INFO] device 0:", torch.cuda.get_device_name(0))
    # Mini-Kernel-Test
    x = torch.randn(1024, 1024, device="cuda")
    y = torch.randn(1024, 1024, device="cuda")
    z = (x @ y).mean().item()
    print("[OK] matmul on CUDA, mean:", z)
else:
    print("[INFO] torch.cuda.is_available = False (ok ohne --gpus all)")
PY

# Prüfe, dass Torch-Libs im Pfad liegen (reine Präsenzprüfung, nicht zwingend vollständig)
TLP="/usr/local/lib/python3.10/dist-packages/torch/lib"
if [ -d "$TLP" ]; then
  echo "[OK] Torch lib dir: $TLP"
  ls -1 "$TLP" | head -n 5 | sed 's/^/[INFO] lib: /'
else
  echo "[FAIL] Torch lib dir fehlt: $TLP"; exit 1
fi

echo "[SUCCESS] Torch-Layer OK"
