#!/bin/bash
set -euo pipefail

# -------- logging --------
log_info()    { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error()   { echo "[ERROR] $1"; }

# -------- config --------
REPO_NAME="cudadocker"                 # Projektordner-Name für Root-Detection
DOCKERFILE_REL="images/11.8/base/Dockerfile"
CHECK_REL="images/11.8/base/checks.sh" # ausgelagertes Run-Command
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
CHECK_PATH="$ROOT_DIR/$CHECK_REL"
CONTEXT_DIR="$(dirname "$DOCKERFILE_PATH")"
IMAGE_TAG="$REPO_NAME:11.8_base"

[ -f "$DOCKERFILE_PATH" ] || { log_error "Dockerfile nicht gefunden: $DOCKERFILE_PATH"; exit 1; }
[ -f "$CHECK_PATH" ]      || { log_error "Check-Skript nicht gefunden: $CHECK_PATH"; exit 1; }

log_info "Projekt-Root: $ROOT_DIR"
log_info "Dockerfile:   $DOCKERFILE_PATH"
log_info "Check-Skript: $CHECK_PATH"

# -------- build --------
log_info "Baue Image ($IMAGE_TAG)..."
DOCKER_BUILDKIT=1 docker build --progress=plain -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" "$CONTEXT_DIR" || { log_error "Build fehlgeschlagen"; exit 1; }
log_info "Build OK."

# -------- single-run test --------
log_info "Starte Runtime-Checks..."
# -i ist wichtig, damit STDIN (die Check-Datei) durchgereicht wird
docker run --rm -i "$IMAGE_TAG" bash -s < "$CHECK_PATH" || { log_error "❌ Checks fehlgeschlagen."; exit 1; }

log_info "✅ Alle Checks bestanden."