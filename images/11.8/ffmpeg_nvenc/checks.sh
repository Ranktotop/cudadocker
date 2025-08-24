#!/usr/bin/env bash
set -e

echo "[CHECK] ffmpeg vorhanden?"
ffmpeg -hide_banner -version

echo "[CHECK] Build-Flags..."
REQ_FLAGS=( --enable-nvenc --enable-nvdec --enable-cuda --enable-cuda-nvcc \
            --enable-libnpp --enable-gnutls \
            --enable-librubberband \
            --enable-libx264 --enable-libx265 \
            --enable-libvpx --enable-libfdk-aac --enable-libvorbis --enable-libopus \
            --enable-libass --enable-libfreetype --enable-libfontconfig )
BUILD="$(ffmpeg -hide_banner -buildconf 2>/dev/null || true)"
for f in "${REQ_FLAGS[@]}"; do
  if grep -q -- "$f" <<<"$BUILD"; then
    echo "[OK] $f"
  else
    echo "[FAIL] fehlend: $f"; exit 1
  fi
done

echo "[CHECK] Filter rubberband vorhanden?"
ffmpeg -hide_banner -filters | grep -q '\brubberband\b' && echo "[OK] rubberband" || { echo "[FAIL] rubberband fehlt"; exit 1; }

echo "[CHECK] Encoder vorhanden?"
ffmpeg -hide_banner -encoders | grep -Eiq '(^|\s)h264_nvenc\b' && echo "[OK] h264_nvenc" || echo "[WARN] h264_nvenc nicht gelistet"
ffmpeg -hide_banner -encoders | grep -Eiq '(^|\s)hevc_nvenc\b' && echo "[OK] hevc_nvenc" || echo "[WARN] hevc_nvenc nicht gelistet"
ffmpeg -hide_banner -encoders | grep -Eiq '\blibx264\b'      && echo "[OK] libx264" || { echo "[FAIL] libx264 fehlt"; exit 1; }
ffmpeg -hide_banner -encoders | grep -Eiq '\blibx265\b'      && echo "[OK] libx265" || { echo "[FAIL] libx265 fehlt"; exit 1; }
ffmpeg -hide_banner -encoders | grep -Eiq '\blibvpx'         && echo "[OK] libvpx"  || { echo "[FAIL] libvpx fehlt";  exit 1; }
ffmpeg -hide_banner -encoders | grep -Eiq '\blibfdk_aac\b'   && echo "[OK] libfdk_aac" || { echo "[FAIL] libfdk_aac fehlt"; exit 1; }

echo "[CHECK] Protokolle (HTTPS via gnutls)?"
ffmpeg -hide_banner -protocols | grep -q '\bhttps\b' && echo "[OK] https" || { echo "[FAIL] https fehlt"; exit 1; }

echo "[CHECK] HW-Accel Liste (compile-time)"
ffmpeg -hide_banner -hwaccels | grep -Eiq '\bcuda\b' && echo "[OK] cuda hwaccel" || echo "[WARN] cuda hwaccel nicht gelistet"

echo "[SUCCESS] Alle NVENC/Codec-Checks bestanden."
