#!/bin/bash
set -euo pipefail

# -------- logging --------
log_info()    { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error()   { echo "[ERROR] $1"; }

# -------- config --------
REPO_NAME="cudadocker"                 # Projektordner-Name für Root-Detection
DOCKERFILE_REL="images/11.8/base/Dockerfile"
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}

# -------- project root detection --------
find_project_root() {
  # 1) ROOT_DIR respektieren (falls gesetzt)
  if [ -n "${ROOT_DIR:-}" ] && [ -d "$ROOT_DIR" ]; then
    echo "$ROOT_DIR"; return 0
  fi
  # 2) git repo root
  if command -v git >/dev/null 2>&1; then
    if GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
      echo "$GIT_ROOT"; return 0
    fi
  fi
  # 3) nach oben laufen bis Verzeichnisname == REPO_NAME
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ "$(basename "$dir")" = "$REPO_NAME" ]; then
      echo "$dir"; return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

ROOT_DIR="$(find_project_root)" || { log_error "Projektwurzel '$REPO_NAME' nicht gefunden. Setze ggf. ROOT_DIR."; exit 1; }
DOCKERFILE_PATH="$ROOT_DIR/$DOCKERFILE_REL"
CONTEXT_DIR="$(dirname "$DOCKERFILE_PATH")"
IMAGE_TAG="cuda-base-test:latest"

[ -f "$DOCKERFILE_PATH" ] || { log_error "Dockerfile nicht gefunden: $DOCKERFILE_PATH"; exit 1; }

log_info "Projekt-Root: $ROOT_DIR"
log_info "Dockerfile:   $DOCKERFILE_PATH"

# -------- build --------
log_info "Baue Image ($IMAGE_TAG)..."
docker build -q -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" "$CONTEXT_DIR" || { log_error "Build fehlgeschlagen"; exit 1; }
log_info "Build OK."

# -------- single-run test --------
log_info "Starte Runtime-Checks (cuDNN 8.7 & CUDA-Libs)..."
docker run --rm "$IMAGE_TAG" bash -lc '
set -e
echo "[CHECK] cuDNN-Version..."
if dpkg -s libcudnn8 2>/dev/null | grep -q "Version: 8.7.0.84-1+cuda11.8"; then
  echo "[OK] libcudnn8 ist 8.7.0.84-1+cuda11.8"
else
  echo "[FAIL] libcudnn8 nicht korrekt gepinnt (erwartet 8.7.0.84-1+cuda11.8)"
  dpkg -s libcudnn8 || true
  exit 1
fi

echo "[CHECK] CUDA/BLAS/cuDNN Libraries ladbar..."
python3 - <<PY
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
' || { log_error "❌ Checks fehlgeschlagen."; exit 1; }

log_info "✅ Alle Checks bestanden."
