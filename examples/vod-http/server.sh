#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

docker run --rm \
  -v "${SCRIPT_DIR}/webroot:/webroot:ro" \
  -v "${SCRIPT_DIR}/nginx.conf:/etc/nginx/nginx.conf:ro" \
  -p 8080:8080 \
  nginx:alpine
