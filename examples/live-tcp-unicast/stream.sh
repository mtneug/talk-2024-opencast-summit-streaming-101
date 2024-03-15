#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

# stream
ffmpeg ${FFMPEG_GLOBAL_OPTS} \
  \
  -re -stream_loop -1 -i "${INPUT_FILE}" \
  -fflags genpts \
  \
  -c copy \
  \
  -bsf:v h264_mp4toannexb \
  \
  -f mpegts \
  "tcp://${UNICAST_HOST}:${UNICAST_PORT}"
