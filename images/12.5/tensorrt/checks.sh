#!/usr/bin/env bash
set -e

echo "[CHECK] cuDNN (erwartet 8.7.0.84-1+cuda11.8)"
dpkg -s libcudnn8 2>/dev/null | grep -q "Version: 8.7.0.84-1+cuda11.8" \
  && echo "[OK] cuDNN 8.7 korrekt gepinnt" \
  || { echo "[FAIL] cuDNN nicht korrekt gepinnt"; dpkg -s libcudnn8 || true; exit 1; }

echo "[CHECK] TensorRT Paketversionen (8.5.1-1+cuda11.8)"
for p in libnvinfer8 libnvinfer-plugin8 libnvparsers8 libnvonnxparsers8 libnvinfer-bin; do
  dpkg -s "$p" 2>/dev/null | grep -q "Version: 8.5.1-1+cuda11.8" \
    && echo "[OK] $p" \
    || { echo "[FAIL] $p Version falsch/fehlt"; dpkg -s "$p" || true; exit 1; }
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

check(["libnvinfer.so.8","libnvinfer.so"])
check(["libnvinfer_plugin.so.8","libnvinfer_plugin.so"])
check(["libnvonnxparser.so.8","libnvonnxparser.so"])
check(["libnvparsers.so.8","libnvparsers.so"])
print("[SUCCESS] TensorRT libs laden")
PY

echo "[CHECK] trtexec vorhanden"
# 1) Im PATH?
if command -v trtexec >/dev/null 2>&1; then
  BIN="$(command -v trtexec)"
  # Versionzeile nur informativ ausgeben, Exitcode ignorieren
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