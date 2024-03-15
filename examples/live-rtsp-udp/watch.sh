#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

# watch
ffplay ${FFPLAY_GLOBAL_OPTS} \
  \
  -rtsp_flags listen \
  -rtsp_transport udp \
  "rtsp://${UNICAST_HOST}:8554/live.sdp"
