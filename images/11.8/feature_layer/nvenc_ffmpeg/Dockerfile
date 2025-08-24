# ranktotop/cudadocker:11.8_nvenc-layer
# syntax=docker/dockerfile:1.6

########## Stage 1: Builder (alles drin, bleibt hier) ##########
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 AS build
ARG FFMPEG_REF=n6.1 # oder master/Commit pinnen
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential pkg-config yasm nasm cmake ninja-build \
    libx264-dev libx265-dev libvpx-dev libfdk-aac-dev \
    libvorbis-dev libopus-dev libfreetype6-dev libfontconfig1-dev libass-dev \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# nv-codec-headers (benötigt für NVENC Build)
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nvch && \
    make -C /tmp/nvch && make -C /tmp/nvch install

# FFmpeg holen & bauen (mit NVENC, dynamisch gelinkt)
RUN git clone https://github.com/FFmpeg/FFmpeg.git /src/ffmpeg && \
    cd /src/ffmpeg && git checkout "${FFMPEG_REF}" && \
    ./configure \
    --prefix=/opt/ffmpeg \
    --enable-gpl --enable-nonfree \
    --enable-libx264 --enable-libx265 --enable-libvpx \
    --enable-libfdk-aac --enable-libvorbis --enable-libopus \
    --enable-libass --enable-fontconfig --enable-libfreetype \
    --enable-nvenc \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64/stubs" && \
    make -j"$(nproc)" && make install && \
    strip /opt/ffmpeg/bin/ffmpeg /opt/ffmpeg/bin/ffprobe || true

# Runtime-Ordner vorbereiten
RUN mkdir -p /layer/usr/local/bin /layer/usr/local/lib

# Binaries rüber
RUN cp -a /opt/ffmpeg/bin/ffmpeg /opt/ffmpeg/bin/ffprobe /layer/usr/local/bin/

# Abhängige .so (außer NVIDIA-Treiberlibs) einsammeln:
#  - Wir kopieren *systemweite* Shared Libs in ihre Originalpfade unter /layer/...
#  - NVIDIA-Treiberlibs (libcuda/libnvidia-encode/libnvcuvid) NICHT kopieren -> kommen vom Host zur Laufzeit.
RUN bash -euxo pipefail <<'SH'
collect() {
  bin="$1"
  ldd "$bin" | awk '/=>/ {print $3} /^\/lib/ {print $1}' \
  | grep -E '^/' \
  | grep -vE 'libcuda\.so|libnvidia-encode\.so|libnvcuvid\.so' \
  | sort -u
}
mkdir -p /layer
for f in /opt/ffmpeg/bin/ffmpeg /opt/ffmpeg/bin/ffprobe; do
  collect "$f" | while read -r so; do
    dst="/layer$(dirname "$so")"
    mkdir -p "$dst"
    cp -a "$so" "$dst/"
  done
done

# Falls FFmpeg eigene .so unter /opt/ffmpeg/lib erzeugt hat, mitnehmen:
if [ -d /opt/ffmpeg/lib ]; then
  mkdir -p /layer/usr/local/lib
  cp -a /opt/ffmpeg/lib/* /layer/usr/local/lib/ || true
fi
SH

# Paranoia: keine STUBS in /layer
RUN ! (find /layer -type f -name 'libcuda.so*' -path '*stubs*' | grep .)

########## Stage 2: Artefakt-Layer (minimale Nutzlast) ##########
FROM scratch
COPY --from=build /layer/ /
LABEL org.opencontainers.image.title="FFmpeg NVENC layer" \
    com.ranktotop.cuda="11.8" \
    com.ranktotop.ffmpeg="${FFMPEG_REF}"
