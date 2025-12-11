#!/usr/bin/env bash
set -e

echo "[CHECK] cuDNN (erwartet 9.3.0.* + CUDA 12.x)"
dpkg -s libcudnn9-cuda-12 2>/dev/null | grep -q "Version: 9.3.0" \
  && echo "[OK] cuDNN 9.3 korrekt gepinnt" \
  || { echo "[FAIL] cuDNN nicht korrekt gepinnt (erwartet libcudnn9-cuda-12 9.3.0.*)"; dpkg -s libcudnn9-cuda-12 || true; exit 1; }

echo "[CHECK] TensorRT Paketversionen (10.9.0.34-1+cuda12.8)"
for p in \
  libnvinfer10 \
  libnvinfer-plugin10 \
  libnvinfer-bin \
  libnvonnxparsers10 \
  libnvinfer-lean10 \
  libnvinfer-vc-plugin10 \
  libnvinfer-dispatch10
do
  dpkg -s "$p" 2>/dev/null | grep -q "Version: 10.9.0.34-1+cuda12.8" \
    && echo "[OK] $p" \
    || { echo "[FAIL] $p Version falsch/fehlt (erwartet 10.9.0.34-1+cuda12.8)"; dpkg -s "$p" || true; exit 1; }
done

echo "[CHECK] Bibliotheken ladbar"
python3 - <<'PY'
import ctypes, sys
def check(names):
    for n in names:
        try:
            ctypes.CDLL(n)
            print("[OK]", n)
            break
        except OSError:
            pass
    else:
        print("[FAIL] none of", names, "could be loaded"); sys.exit(1)

check(["libnvinfer.so.10","libnvinfer.so"])
check(["libnvinfer_plugin.so.10","libnvinfer_plugin.so"])
check(["libnvonnxparser.so.10","libnvonnxparser.so"])
print("[SUCCESS] TensorRT libs laden")
PY

echo "[CHECK] trtexec vorhanden"
# 1) Im PATH?
if command -v trtexec >/dev/null 2>&1; then
  BIN="$(command -v trtexec)"
  VER_LINE="$(trtexec --help 2>&1 | head -n 1 || true)"
  echo "[OK] trtexec gefunden: $BIN"
  [ -n "$VER_LINE" ] && echo "[INFO] $VER_LINE"
# 2) Fallback: Standardpfad des Pakets
elif [ -x /usr/src/tensorrt/bin/trtexec ]; then
  /usr/src/tensorrt/bin/trtexec --help >/dev/null 2>&1 || true
  echo "[OK] trtexec gefunden: /usr/src/tensorrt/bin/trtexec"
# 3) Fehlermeldung
else
  echo "[FAIL] trtexec fehlt (kommt i.d.R. mit libnvinfer-bin)"; exit 1
fi
