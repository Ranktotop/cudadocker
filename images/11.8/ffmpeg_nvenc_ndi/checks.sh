#!/usr/bin/env bash
set -e

echo "[CHECK] ffmpeg-ndi vorhanden?"
ffmpeg-ndi -hide_banner -version

echo "[CHECK] NDI-Library gelinkt?"
ldd "$(command -v ffmpeg-ndi)" | grep -qi 'libndi' \
  && echo "[OK] libndi verlinkt" \
  || { echo "[FAIL] libndi nicht verlinkt"; exit 1; }

echo "[CHECK] Build-Flags (NDI/NVENC/HTTPS/Codecs)..."
BUILD="$(ffmpeg-ndi -hide_banner -buildconf 2>/dev/null || true)"
for flag in \
  --enable-libndi_newtek \
  --enable-nvenc --enable-nvdec --enable-cuda --enable-libnpp \
  --enable-gnutls \
  --enable-libx264 --enable-libx265 --enable-libvpx \
  --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libvorbis \
  --enable-libass --enable-libfreetype --enable-libfontconfig
do
  if grep -q -- "$flag" <<<"$BUILD"; then
    echo "[OK] $flag"
  else
    echo "[FAIL] fehlend: $flag"; exit 1
  fi
done

echo "[CHECK] NDI-Library gelinkt?"
ldd "$(command -v ffmpeg-ndi)" | grep -qi 'libndi' && echo "[OK] libndi verlinkt" || { echo "[FAIL] libndi nicht verlinkt"; exit 1; }

echo "[CHECK] Protokolle: https?"
ffmpeg-ndi -hide_banner -protocols | grep -q '\bhttps\b' && echo "[OK] https" || { echo "[FAIL] https fehlt"; exit 1; }

echo "[SUCCESS] NDI-FFmpeg Checks bestanden."
