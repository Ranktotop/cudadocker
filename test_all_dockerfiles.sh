#!/bin/bash
set -euo pipefail

# -------- Configuration --------
# Liste der auszuführenden Builds (Format: "CUDA_VERSION IMAGE_NAME")
SCRIPTS=(
    "12.8 base"
    "12.8 ffmpeg_nvenc"
    "12.8 tensorrt"
    "12.8 torch_2_8_0"
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
    "12.5 torch_2_6_0"
    "12.5 torch_2_6_0_cudnn_8_9_7"
)

# Name des auszuführenden Scripts
BUILD_SCRIPT="./test_dockerfile.sh"

# -------- Logging --------
log_info() { 
    echo "[BATCH-INFO] $1"; 
}

log_error() { 
    echo "[BATCH-ERROR] $1" >&2; 
}

log_success() { 
    echo "[BATCH-SUCCESS] $1"; 
}

log_debug() {
    if [ "${DEBUG:-false}" = true ]; then
        echo "[BATCH-DEBUG] $1"
    fi
}

# -------- Funktionen --------
check_build_script() {
    log_debug "Checking build script: $BUILD_SCRIPT"
    
    if [ ! -f "$BUILD_SCRIPT" ]; then
        log_error "Build-Script nicht gefunden: $BUILD_SCRIPT"
        exit 1
    fi
    
    if [ ! -x "$BUILD_SCRIPT" ]; then
        log_error "Build-Script ist nicht ausführbar: $BUILD_SCRIPT"
        echo "Führe aus: chmod +x $BUILD_SCRIPT"
        exit 1
    fi
    
    log_debug "Build script check passed"
}

# Sicherere Arithmetik-Funktion
safe_increment() {
    local var_name=$1
    local current_val
    current_val=$(eval echo \$$var_name)
    local new_val=$((current_val + 1))
    eval "$var_name=$new_val"
    log_debug "Incremented $var_name from $current_val to $new_val"
}

run_single_build() {
    local params="$1"
    local cuda_version=""
    local image_name=""
    
    log_debug "Processing build parameters: $params"
    
    # Parameter aufteilen
    read -r cuda_version image_name <<< "$params"
    
    if [ -z "$cuda_version" ] || [ -z "$image_name" ]; then
        log_error "Ungültige Parameter: '$params'. Erwartet: 'CUDA_VERSION IMAGE_NAME'"
        return 1
    fi
    
    log_info "Starte Build für: CUDA $cuda_version, Image $image_name"
    log_debug "About to execute: $BUILD_SCRIPT $cuda_version $image_name"
    
    # Build ausführen - explizite Fehlerbehandlung
    local build_exit_code=0
    if "$BUILD_SCRIPT" "$cuda_version" "$image_name"; then
        build_exit_code=$?
        log_debug "Build script returned exit code: $build_exit_code"
        log_success "Build erfolgreich: $cuda_version $image_name"
        return 0
    else
        build_exit_code=$?
        log_debug "Build script returned exit code: $build_exit_code"
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
    log_info "Gesamt: $total Builds"
    log_success "Erfolgreich: $successful Builds"
    log_error "Fehlgeschlagen: $failed Builds"
    echo "=========================================================="
}

# -------- Optionen --------
CONTINUE_ON_ERROR=false
DRY_RUN=false
DEBUG=false

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --continue-on-error  Weiter machen bei Fehlern (Standard: stopp bei erstem Fehler)"
    echo "  -d, --dry-run           Nur anzeigen was ausgeführt würde, ohne tatsächlich zu bauen"
    echo "  -v, --debug             Verbose debug output"
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
        -v|--debug)
            DEBUG=true
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
    log_info "Debug mode: $DEBUG"
    
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
    log_debug "Initial counters - successful: $successful_builds, failed: $failed_builds"
    
    for i in "${!SCRIPTS[@]}"; do
        local current_build=$((i+1))
        local params="${SCRIPTS[$i]}"
        
        echo ""
        log_info "[$current_build/$total_builds] Starte: $params"
        log_debug "Loop iteration $i, current_build: $current_build"
        log_debug "Before build - successful: $successful_builds, failed: $failed_builds"
        
        if run_single_build "$params"; then
            log_debug "Build was successful, incrementing successful_builds"
            safe_increment "successful_builds"
            log_debug "After increment - successful: $successful_builds"
        else
            log_debug "Build failed, incrementing failed_builds"
            safe_increment "failed_builds"
            log_debug "After increment - failed: $failed_builds"
            
            if [ "$CONTINUE_ON_ERROR" = false ]; then
                log_error "Build fehlgeschlagen. Stoppe (verwende -c um fortzufahren)."
                show_summary "$total_builds" "$successful_builds" "$failed_builds"
                exit 1
            else
                log_info "Setze mit nächstem Build fort..."
            fi
        fi
        
        log_debug "Completed loop iteration $i, moving to next..."
        log_debug "Current status - successful: $successful_builds, failed: $failed_builds"
    done
    
    log_debug "All builds completed, showing summary"
    show_summary "$total_builds" "$successful_builds" "$failed_builds"
    
    if [ $failed_builds -eq 0 ]; then
        log_success "Alle Builds erfolgreich abgeschlossen!"
        exit 0
    else
        log_error "Einige Builds sind fehlgeschlagen."
        exit 1
    fi
}

# Trap für unerwartete Exits
trap 'log_error "Script terminated unexpectedly at line $LINENO"' ERR

main "$@"