#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

# encode
ffmpeg ${FFMPEG_GLOBAL_OPTS} \
  \
  -i "${INPUT_FILE}" \
  \
  -c:v libx264 \
    -profile:v main \
    -crf:v 23 -bufsize:v 2250k -maxrate:v 2500k \
    -g:v 100000 -keyint_min:v 50000 -force_key_frames:v "expr:gte(t,n_forced*2)" \
    -x264opts no-open-gop=1 \
  \
  -c:a aac \
    -b:a 128k \
  \
  -movflags +faststart \
  \
  -y "${SCRIPT_DIR}/webroot/video.mp4"
