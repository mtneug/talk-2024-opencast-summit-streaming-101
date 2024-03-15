#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

docker run --rm \
  -v "${SCRIPT_DIR}/webroot:/webroot:ro" \
  -v "${ROOT_DIR}/examples/Caddyfile:/etc/caddy/Caddyfile:ro" \
  -p 8080:8080 \
  caddy:2.7-alpine
