#!/bin/bash
set -euo pipefail

# -------- usage / args (no defaults) --------
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <CUDA_VERSION> <IMAGE_NAME>"
  echo "Example: $0 11.8 base"
  exit 1
fi
CUDA_VERSION="$1"
IMAGE_NAME="$2"

# -------- logging --------
log_info()    { echo "[INFO] $1"; }
log_error()   { echo "[ERROR] $1"; }

# -------- config --------
REPO_NAME="cudadocker"                                # Projektordner-Name für Root-Detection
DOCKERFILE_REL="images/$CUDA_VERSION/$IMAGE_NAME/Dockerfile"
CHECK_REL="images/$CUDA_VERSION/$IMAGE_NAME/checks.sh"
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}

# -------- project root detection --------
find_project_root() {
  if [ -n "${ROOT_DIR:-}" ] && [ -d "$ROOT_DIR" ]; then echo "$ROOT_DIR"; return 0; fi
  if command -v git >/dev/null 2>&1; then
    if GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then echo "$GIT_ROOT"; return 0; fi
  fi
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ "$(basename "$dir")" = "$REPO_NAME" ]; then echo "$dir"; return 0; fi
    dir="$(dirname "$dir")"
  done
  return 1
}

ROOT_DIR="$(find_project_root)" || { log_error "Projektwurzel '$REPO_NAME' nicht gefunden. Setze ggf. ROOT_DIR."; exit 1; }
DOCKERFILE_PATH="$ROOT_DIR/$DOCKERFILE_REL"
CHECK_PATH="$ROOT_DIR/$CHECK_REL"
CONTEXT_DIR="$(dirname "$DOCKERFILE_PATH")"
IMAGE_TAG="$REPO_NAME:${CUDA_VERSION}_${IMAGE_NAME}"

[ -f "$DOCKERFILE_PATH" ] || { log_error "Dockerfile nicht gefunden: $DOCKERFILE_PATH"; exit 1; }
[ -f "$CHECK_PATH" ]      || { log_error "Check-Skript nicht gefunden: $CHECK_PATH"; exit 1; }

log_info "Projekt-Root: $ROOT_DIR"
log_info "Dockerfile:   $DOCKERFILE_PATH"
log_info "Check-Skript: $CHECK_PATH"
log_info "Image-Tag:    $IMAGE_TAG"

# -------- build (volle Logs) --------
log_info "Baue Image ($IMAGE_TAG)..."
DOCKER_BUILDKIT=1 docker build --progress=plain -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" "$CONTEXT_DIR" || { log_error "Build fehlgeschlagen"; exit 1; }
log_info "Build OK."

# -------- single-run test --------
log_info "Starte Runtime-Checks..."
docker run --rm -i "$IMAGE_TAG" bash -s < "$CHECK_PATH" || { log_error "❌ Checks fehlgeschlagen."; exit 1; }

log_info "✅ Alle Checks bestanden."
