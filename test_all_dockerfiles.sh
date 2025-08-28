#!/bin/bash
set -euo pipefail

# -------- Configuration --------
# Liste der auszuführenden Builds (Format: "CUDA_VERSION IMAGE_NAME")
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

# Name des auszuführenden Scripts
BUILD_SCRIPT="./test_dockerfile.sh"

# -------- Logging --------
log_info()  { echo "[BATCH-INFO] $1"; }
log_error() { echo "[BATCH-ERROR] $1"; }
log_success() { echo "[BATCH-SUCCESS] $1"; }

# -------- Funktionen --------
check_build_script() {
    if [ ! -f "$BUILD_SCRIPT" ]; then
        log_error "Build-Script nicht gefunden: $BUILD_SCRIPT"
        exit 1
    fi
    
    if [ ! -x "$BUILD_SCRIPT" ]; then
        log_error "Build-Script ist nicht ausführbar: $BUILD_SCRIPT"
        echo "Führe aus: chmod +x $BUILD_SCRIPT"
        exit 1
    fi
}

run_single_build() {
    local params="$1"
    local cuda_version=""
    local image_name=""
    
    # Parameter aufteilen
    read -r cuda_version image_name <<< "$params"
    
    if [ -z "$cuda_version" ] || [ -z "$image_name" ]; then
        log_error "Ungültige Parameter: '$params'. Erwartet: 'CUDA_VERSION IMAGE_NAME'"
        return 1
    fi
    
    log_info "Starte Build für: CUDA $cuda_version, Image $image_name"
    
    # Build ausführen
    if $BUILD_SCRIPT "$cuda_version" "$image_name"; then
        log_success "Build erfolgreich: $cuda_version $image_name"
        return 0
    else
        log_error "Build fehlgeschlagen: $cuda_version $image_name"
        return 1
    fi
}

show_summary() {
    local total=$1
    local successful=$2
    local failed=$3
    
    echo ""
    echo "==================== ZUSAMMENFASSUNG ===================="
    log_info "Gesamt:      $total Builds"
    log_success "Erfolgreich: $successful Builds"
    log_error "Fehlgeschlagen: $failed Builds"
    echo "=========================================================="
}

# -------- Optionen --------
CONTINUE_ON_ERROR=false
DRY_RUN=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --continue-on-error  Weiter machen bei Fehlern (Standard: stopp bei erstem Fehler)"
    echo "  -d, --dry-run           Nur anzeigen was ausgeführt würde, ohne tatsächlich zu bauen"
    echo "  -h, --help              Diese Hilfe anzeigen"
    echo ""
    echo "Konfigurierte Builds:"
    for script in "${SCRIPTS[@]}"; do
        echo "  - $script"
    done
}

# -------- Argument parsing --------
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continue-on-error)
            CONTINUE_ON_ERROR=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unbekannte Option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# -------- Main --------
main() {
    log_info "Batch Build Script gestartet"
    log_info "Build-Script: $BUILD_SCRIPT"
    log_info "Anzahl Builds: ${#SCRIPTS[@]}"
    log_info "Continue on error: $CONTINUE_ON_ERROR"
    log_info "Dry run: $DRY_RUN"
    
    if [ "$DRY_RUN" = true ]; then
        echo ""
        log_info "DRY RUN - Folgende Builds würden ausgeführt:"
        for i in "${!SCRIPTS[@]}"; do
            echo "  $((i+1)). ${SCRIPTS[$i]}"
        done
        exit 0
    fi
    
    check_build_script
    
    local total_builds=${#SCRIPTS[@]}
    local successful_builds=0
    local failed_builds=0
    
    echo ""
    log_info "Starte $total_builds Builds..."
    
    for i in "${!SCRIPTS[@]}"; do
        local current_build=$((i+1))
        local params="${SCRIPTS[$i]}"
        
        echo ""
        log_info "[$current_build/$total_builds] Starte: $params"
        
        if run_single_build "$params"; then
            ((successful_builds++))
        else
            ((failed_builds++))
            
            if [ "$CONTINUE_ON_ERROR" = false ]; then
                log_error "Build fehlgeschlagen. Stoppe (verwende -c um fortzufahren)."
                show_summary "$total_builds" "$successful_builds" "$failed_builds"
                exit 1
            else
                log_info "Setze mit nächstem Build fort..."
            fi
        fi
    done
    
    show_summary "$total_builds" "$successful_builds" "$failed_builds"
    
    if [ $failed_builds -eq 0 ]; then
        log_success "Alle Builds erfolgreich abgeschlossen!"
        exit 0
    else
        log_error "Einige Builds sind fehlgeschlagen."
        exit 1
    fi
}

main "$@"