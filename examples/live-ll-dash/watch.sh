#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

open "https://reference.dashif.org/dash.js/nightly/samples/dash-if-reference-player/index.html?mpd=http%3A%2F%2Flocalhost%3A8080%2Fdash%2Fexample.str%2Fmanifest.mpd&muted=true+&debug.logLevel=5&streaming.delay.liveDelayFragmentCount=NaN&streaming.delay.liveDelay=NaN&streaming.buffer.initialBufferLevel=NaN&streaming.liveCatchup.maxDrift=NaN&streaming.liveCatchup.playbackRate.min=NaN&streaming.liveCatchup.playbackRate.max=NaN"
