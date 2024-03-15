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
  -f rtsp \
  -rtsp_transport udp \
  "rtsp://${UNICAST_HOST}:8554/live.sdp"
