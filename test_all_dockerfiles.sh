#!/usr/bin/env bash
set -euo pipefail

# -------- Configuration --------
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

# -------- Logging --------
log_info()      { echo "[BATCH-INFO] $*"; }
log_error()     { echo "[BATCH-ERROR] $*" >&2; }
log_success()   { echo "[BATCH-SUCCESS] $*"; }

# -------- Helpers --------
check_build_script() {
  if [[ ! -f "$BUILD_SCRIPT" ]]; then
    log_error "Build-Script nicht gefunden: $BUILD_SCRIPT"
    exit 1
  fi
  if [[ ! -x "$BUILD_SCRIPT" ]]; then
    log_error "Build-Script ist nicht ausführbar: $BUILD_SCRIPT"
    echo "Führe aus: chmod +x $BUILD_SCRIPT" >&2
    # Wir rufen es gleich explizit mit 'bash' auf; nicht-exekutabel ist dann egal,
    # aber die Meldung ist trotzdem hilfreich.
  fi
}

run_single_build() {
  local params="$1"
  local cuda_version image_name
  # Params splitten (genau 2 Felder)
  read -r cuda_version image_name <<<"$params"

  if [[ -z "${cuda_version:-}" || -z "${image_name:-}" ]]; then
    log_error "Ungültige Parameter: '$params' (erwartet: 'CUDA_VERSION IMAGE_NAME')"
    return 2
  fi

  log_info "Starte Build für: CUDA $cuda_version, Image $image_name"

  # --- WICHTIG: -e kurzzeitig ausschalten, Rückgabecode manuell lesen ---
  set +e
  bash "$BUILD_SCRIPT" "$cuda_version" "$image_name"
  local rc=$?
  set -e
  # ----------------------------------------------------------------------

  if [[ $rc -eq 0 ]]; then
    log_success "Build erfolgreich: $cuda_version $image_name"
  else
    log_error "Build fehlgeschlagen ($rc): $cuda_version $image_name"
  fi
  return "$rc"
}

show_summary() {
  local total=$1 ok=$2 fail=$3
  echo
  echo "==================== ZUSAMMENFASSUNG ===================="
  log_info     "Gesamt:        $total Builds"
  log_success  "Erfolgreich:   $ok Builds"
  log_error    "Fehlgeschlagen:$fail Builds"
  echo "=========================================================="
}

# -------- Optionen --------
CONTINUE_ON_ERROR=false
DRY_RUN=false

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -c, --continue-on-error  Weiter machen bei Fehlern (Standard: Stopp bei erstem Fehler)
  -d, --dry-run            Nur anzeigen, was ausgeführt würde
  -h, --help               Hilfe

Konfigurierte Builds:
$(printf '  - %s\n' "${SCRIPTS[@]}")
EOF
}

# -------- Argument parsing --------
while (($#)); do
  case "$1" in
    -c|--continue-on-error) CONTINUE_ON_ERROR=true ;;
    -d|--dry-run)           DRY_RUN=true ;;
    -h|--help)              show_usage; exit 0 ;;
    *)                      log_error "Unbekannte Option: $1"; show_usage; exit 1 ;;
  esac
  shift
done

# -------- Main --------
main() {
  log_info "Batch Build Script gestartet"
  log_info "Build-Script: $BUILD_SCRIPT"
  log_info "Anzahl Builds: ${#SCRIPTS[@]}"
  log_info "Continue on error: $CONTINUE_ON_ERROR"
  log_info "Dry run: $DRY_RUN"

  if $DRY_RUN; then
    echo
    log_info "DRY RUN - Folgende Builds würden ausgeführt:"
    printf '  %s\n' "${SCRIPTS[@]}"
    exit 0
  fi

  check_build_script

  local total=${#SCRIPTS[@]}
  local ok=0
  local fail=0

  echo
  log_info "Starte $total Builds..."

  local idx=0
  for params in "${SCRIPTS[@]}"; do
    ((idx++))
    echo
    log_info "[$idx/$total] Starte: $params"

    if run_single_build "$params"; then
      ((ok++))
    else
      ((fail++))
      if ! $CONTINUE_ON_ERROR; then
        log_error "Build fehlgeschlagen. Stoppe (verwende -c um fortzufahren)."
        show_summary "$total" "$ok" "$fail"
        exit 1
      else
        log_info "Setze mit nächstem Build fort..."
      fi
    fi
  done

  show_summary "$total" "$ok" "$fail"
  if ((fail == 0)); then
    log_success "Alle Builds erfolgreich abgeschlossen!"
  else
    log_error "Einige Builds sind fehlgeschlagen."
    exit 1
  fi
}

main "$@"
