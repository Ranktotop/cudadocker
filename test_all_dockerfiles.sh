#!/usr/bin/env bash
# batch runner
set -uo pipefail
[[ "${DEBUG:-0}" == 1 ]] && set -x

SCRIPTS=(
  "11.8 base"
  "11.8 ffmpeg_nvenc"
  "11.8 ffmpeg_nvenc_ndi"
  "11.8 tensorflow"
  "11.8 tensorrt"
  "11.8 torch_2_0_1"
  "11.8 torch_2_5_1"
  "12.5 base"
  "12.5 base_cudnn_8_9_7"
  "12.5 ffmpeg_nvenc"
  "12.5 ffmpeg_nvenc_ndi"
  "12.5 tensorflow"
  "12.5 tensorflow_cudnn_8_9_7"
  "12.5 tensorrt"
  "12.5 torch"
  "12.5 torch_cudnn_8_9_7"
)

BUILD_SCRIPT="./test_dockerfile.sh"

log_info()      { echo "[BATCH-INFO] $*"; }
log_error()     { echo "[BATCH-ERROR] $*" >&2; }
log_success()   { echo "[BATCH-SUCCESS] $*"; }

CONTINUE_ON_ERROR=false
DRY_RUN=false

show_usage() {
  cat <<EOF
Usage: $0 [-c] [-d]
  -c, --continue-on-error  bei Fehlern weitermachen
  -d, --dry-run            nur anzeigen, was gebaut würde
EOF
}

while (($#)); do
  case "$1" in
    -c|--continue-on-error) CONTINUE_ON_ERROR=true ;;
    -d|--dry-run)           DRY_RUN=true ;;
    -h|--help)              show_usage; exit 0 ;;
    *) log_error "Unbekannte Option: $1"; show_usage; exit 1 ;;
  esac
  shift
done

check_build_script() {
  if [[ ! -f "$BUILD_SCRIPT" ]]; then
    log_error "Build-Script nicht gefunden: $BUILD_SCRIPT"; exit 1
  fi
}

run_single_build() {
  local params="$1"
  local cuda_version image_name
  IFS=' ' read -r cuda_version image_name <<<"$params"

  if [[ -z "${cuda_version:-}" || -z "${image_name:-}" ]]; then
    log_error "Ungültige Parameter: '$params'"; return 2
  fi

  log_info "Starte Build für: CUDA ${cuda_version}, Image ${image_name}"

  # --- wichtig: Exit-on-error AUS für den Call ---
  set +e
  bash "$BUILD_SCRIPT" "$cuda_version" "$image_name"
  local rc=$?
  set -e
  # ----------------------------------------------

  if [[ $rc -eq 0 ]]; then
    log_success "Build OK: ${cuda_version} ${image_name}"
  else
    log_error   "Build FAIL ($rc): ${cuda_version} ${image_name}"
  fi
  return "$rc"
}

show_summary() {
  local total=$1 ok=$2 fail=$3
  echo
  echo "==================== ZUSAMMENFASSUNG ===================="
  log_info     "Gesamt:        $total"
  log_success  "Erfolgreich:   $ok"
  log_error    "Fehlgeschlagen:$fail"
  echo "=========================================================="
}

main() {
  log_info "Batch Build Script gestartet"
  log_info "Build-Script: $BUILD_SCRIPT"
  log_info "Anzahl Builds: ${#SCRIPTS[@]}"
  log_info "Continue on error: $CONTINUE_ON_ERROR"
  log_info "Dry run: $DRY_RUN"

  if $DRY_RUN; then
    echo; log_info "DRY RUN:"
    printf '  %s\n' "${SCRIPTS[@]}"; exit 0
  fi

  check_build_script

  local total=${#SCRIPTS[@]} ok=0 fail=0
  echo;
