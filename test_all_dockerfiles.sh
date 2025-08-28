#!/usr/bin/env bash
# batch runner for test_dockerfile.sh
# ASCII-only, LF line endings required

set -euo pipefail

# -------- config --------
BUILD_SCRIPT="${BUILD_SCRIPT:-./test_dockerfile.sh}"

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

# -------- logging (ASCII) --------
log_i(){ printf '[INFO] %s\n' "$*"; }
log_w(){ printf '[WARN] %s\n' "$*" >&2; }
log_e(){ printf '[ERROR] %s\n' "$*" >&2; }
log_s(){ printf '[SUCCESS] %s\n' "$*"; }

# -------- opts --------
CONTINUE=false
DRY=false

usage() {
  cat <<'EOF'
Usage: ./test_all_dockerfiles.sh [OPTIONS]
  -c, --continue-on-error   continue on errors
  -d, --dry-run             print planned builds only
  -h, --help                show this help
EOF
}

while (($#)); do
  case "$1" in
    -c|--continue-on-error) CONTINUE=true ;;
    -d|--dry-run)           DRY=true ;;
    -h|--help)              usage; exit 0 ;;
    *) log_e "unknown option: $1"; usage; exit 1 ;;
  esac
  shift
done

# -------- helpers --------
check_build_script() {
  if [[ ! -f "$BUILD_SCRIPT" ]]; then
    log_e "build script not found: $BUILD_SCRIPT"
    exit 1
  fi
}

run_one() {
  local params="$1"
  local cuda="" image=""

  # split exactly two fields
  read -r cuda image <<<"$params"

  if [[ -z "$cuda" || -z "$image" ]]; then
    log_e "bad params: [$params] (need: CUDA_VERSION IMAGE_NAME)"
    return 2
  fi

  log_i "start build: cuda=$cuda image=$image"

  # run child and capture exit code without killing the loop
  set +e
  bash "$BUILD_SCRIPT" "$cuda" "$image"
  local rc=$?
  set -e

  if [[ $rc -eq 0 ]]; then
    log_s "build ok: $cuda $image"
  else
    log_e "build failed ($rc): $cuda $image"
  fi
  return $rc
}

summary() {
  local total="$1" ok="$2" fail="$3"
  echo
  echo "================ summary ================"
  log_i "total:       $total"
  log_s "ok:          $ok"
  log_e "failed:      $fail"
  echo "========================================="
}

# -------- main --------
main() {
  # enforce C locale to avoid encoding surprises
  export LC_ALL=C LANG=C

  log_i "batch started"
  log_i "build script: $BUILD_SCRIPT"
  log_i "build count: ${#SCRIPTS[@]}"
  log_i "continue on error: $CONTINUE"
  log_i "dry run: $DRY"

  if $DRY; then
    echo
    log_i "dry-run list:"
    for s in "${SCRIPTS[@]}"; do
      echo "  $s"
    done
    exit 0
  fi

  check_build_script

  local total=${#SCRIPTS[@]} ok=0 fail=0
  echo
  log_i "starting $total builds..."

  local idx=0
  for params in "${SCRIPTS[@]}"; do
    ((idx++))
    echo
    log_i "[$idx/$total] $params"

    if run_one "$params"; then
      ((ok++))
    else
      ((fail++))
      if ! $CONTINUE; then
        log_e "stop on first failure (use -c to continue)"
        summary "$total" "$ok" "$fail"
        exit 1
      else
        log_w "continue after failure"
      fi
    fi
  done

  summary "$total" "$ok" "$fail"
  if ((fail==0)); then
    log_s "all builds completed"
    exit 0
  else
    log_e "some builds failed"
    exit 1
  fi
}

main "$@"
