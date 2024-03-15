#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

docker run --rm \
  -v "${ROOT_DIR}/examples/live-ll-dash/server.yml:/etc/nagare-media/ingest/config.yaml:ro" \
  -p 8080:8080 \
  ghcr.io/nagare-media/ingest:dev
