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

# ---------- logging ----------
log_info()  { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1"; }

# ---------- Configuration ----------
REPO_NAME="cudadocker"                                # Git Repo-Name für Root-Detection
IMAGE_TAG="$REPO_NAME:${CUDA_VERSION}_${IMAGE_NAME}"  # e.g. cudadocker:11.8_base
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}

# ---------- Project root detection ----------
find_project_root() {
    # 1) Respect pre-set ROOT_DIR if valid
    if [ -n "${ROOT_DIR:-}" ] && [ -d "$ROOT_DIR" ]; then
        echo "$ROOT_DIR"; return 0
    fi
    # 2) Try git repo root
    if command -v git >/dev/null 2>&1; then
        if GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
            if [ -d "$GIT_ROOT" ]; then
                echo "$GIT_ROOT"; return 0
            fi
        fi
    fi
    # 3) Walk upwards until we hit a directory named $REPO_NAME
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ "$(basename "$dir")" = "$REPO_NAME" ]; then
            echo "$dir"; return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}
ROOT_DIR="$(find_project_root)" || {
    log_error "Konnte Projektwurzel '$REPO_NAME' nicht finden. Setze ROOT_DIR manuell (export ROOT_DIR=/pfad/zu/$REPO_NAME)."
    exit 1
}
cd "$ROOT_DIR"

# ---------- Paths ----------
DOCKERFILE_PATH="$ROOT_DIR/images/$CUDA_VERSION/$IMAGE_NAME/Dockerfile"
CHECKFILE_PATH="$ROOT_DIR/images/$CUDA_VERSION/$IMAGE_NAME/checks.sh"
CONTEXT_DIR="$(dirname "$DOCKERFILE_PATH")"

[ -f "$DOCKERFILE_PATH" ] || { log_error "Dockerfile nicht gefunden unter: $DOCKERFILE_PATH"; exit 1; }
[ -f "$CHECKFILE_PATH" ]  || { log_error "Check-Skript nicht gefunden unter: $CHECKFILE_PATH"; exit 1; }

log_info "Repository:   $REPO_NAME"
log_info "Image-Tag:    $IMAGE_TAG"
log_info "Projekt-Root: $ROOT_DIR"
log_info "Dockerfile:   $DOCKERFILE_PATH"
log_info "Check-Skript: $CHECKFILE_PATH"

# ---------- Env checks ----------
check_env_vars() {
    if [ -z "${DOCKERHUB_USERNAME:-}" ]; then
        log_error "DOCKERHUB_USERNAME environment variable is not set!"
        echo "Please set: export DOCKERHUB_USERNAME=your-dockerhub-username"
        exit 1
    fi
    if [ -z "${DOCKERHUB_TOKEN:-}" ]; then
        log_error "DOCKERHUB_TOKEN environment variable is not set!"
        echo "Please set: export DOCKERHUB_TOKEN=your-dockerhub-token"
        exit 1
    fi
}

# Resolve Docker Hub namespace (org overrides username)
get_namespace() {
    if [ -n "${DOCKERHUB_ORG:-}" ]; then
        echo "$DOCKERHUB_ORG"
    else
        echo "$DOCKERHUB_USERNAME"
    fi
}

# Login to DockerHub
login_dockerhub() {
    log_info "Logging into Docker Hub..."
    if echo "$DOCKERHUB_TOKEN" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin >/dev/null 2>&1; then
        log_info "Successfully logged into Docker Hub"
    else
        log_error "Failed to login to Docker Hub"
        exit 1
    fi
}

# Build Docker image
build_docker_image() {
    log_info "Building Docker image: ${IMAGE_TAG}"
    DOCKER_BUILDKIT=1 docker build --progress=plain \
        -f "$DOCKERFILE_PATH" -t "$IMAGE_TAG" "$CONTEXT_DIR" \
        || { log_error "Build fehlgeschlagen"; exit 1; }
    log_info "Build OK."
}

# Test Docker image
test_docker_image() {
    log_info "Starte Runtime-Checks..."
    docker run --rm --gpus all --entrypoint /bin/bash -i "$IMAGE_TAG" -s < "$CHECKFILE_PATH" \
        || { log_error "❌ Checks fehlgeschlagen."; exit 1; }
    log_info "✅ Alle Checks bestanden."
}

# Tag & Push Docker image to Docker Hub
push_docker_image() {
    local ns="$1"
    local target="${ns}/${IMAGE_TAG}"
    log_info "Tagging as: $target"
    docker tag "$IMAGE_TAG" "$target"
    log_info "Pushing: $target"
    docker push "$target" || { log_error "Failed to push image"; exit 1; }
    log_info "Successfully pushed image"
}

# Cleanup local images
cleanup_images() {
    local ns="$1"
    local target="${ns}/${IMAGE_TAG}"
    log_info "Cleaning up local Docker images..."
    docker rmi "$target" 2>/dev/null || true
    docker rmi "$IMAGE_TAG" 2>/dev/null || true
    log_info "Cleanup completed"
}

# ---------- Main ----------
main() {
    log_info "Starting manual Docker build, test and push for $IMAGE_TAG"

    check_env_vars
    login_dockerhub
    NS="$(get_namespace)"
    log_info "Docker Hub namespace: $NS"

    build_docker_image
    test_docker_image
    push_docker_image "$NS"
    cleanup_images "$NS"

    log_info "Done: pushed $NS/$IMAGE_TAG"
}

main "$@"
