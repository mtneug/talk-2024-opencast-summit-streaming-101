#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

INGEST_HOST=${INGEST_HOST:-localhost:8080}

ffmpeg ${FFMPEG_GLOBAL_OPTS} \
  \
  -re -stream_loop -1 -i "${INPUT_FILE}" \
  -fflags genpts \
  \
  -filter_complex "
    [0:v]scale=1280x720,
         drawbox=x=0:y=0:w=700:h=50:c=black@.6:t=fill,
         drawtext=x=  5:y=5:fontsize=54:fontcolor=white:text='%{pts\:gmtime\:$(date +%s)\:%Y-%m-%d}',
         drawtext=x=345:y=5:fontsize=54:fontcolor=white:timecode='$(date -u '+%H\:%M\:%S')\:00':rate=25:tc24hmax=1,
         split
         [main0][main1];
    [main0]drawtext=x=(w-text_w)-5:y=5:fontsize=54:fontcolor=white:text='720p':box=1:boxcolor=black@.6:boxborderw=5
           [v720p];
    [main1]drawtext=x=(w-text_w)-5:y=5:fontsize=54:fontcolor=white:text='360p':box=1:boxcolor=black@.6:boxborderw=5,
           scale=640x360
           [v360p]
  " \
  -map [v720p] \
  -map [v360p] \
  \
  -c:v libx264 \
    -preset:v veryfast \
    -tune zerolatency \
    -profile:v main \
    -crf:v:0 23 -bufsize:v:0 2250k -maxrate:v:0 2500k \
    -crf:v:1 23 -bufsize:v:1  540k -maxrate:v:1  600k \
    -g:v 100000 -keyint_min:v 50000 -force_key_frames:v "expr:gte(t,n_forced*2)" \
    -x264opts no-open-gop=1 \
    -bf 2 -b_strategy 2 -refs 1 \
    -rc-lookahead 24 \
    -export_side_data prft \
    -field_order progressive -colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range tv \
    -pix_fmt yuv420p \
  -c:a aac \
    -b:a 128k \
  \
  -f dash \
    -use_timeline 0 \
    -use_template 1 \
      -init_seg_name 'init-stream$RepresentationID$.$ext$' \
      -media_seg_name 'chunk-stream$RepresentationID$-$Number$.$ext$' \
    -adaptation_sets \
      "id=0,seg_duration=8,frag_type=duration,frag_duration=1,streams=v
       id=1,seg_duration=8,frag_type=duration,frag_duration=1,streams=a" \
    -utc_timing_url "https://time.akamai.com?iso&amp;ms" \
    \
    -streaming 1 \
    -ldash 1 \
    -target_latency 3 \
    -min_playback_rate 0.96 \
    -max_playback_rate 1.04 \
    \
    -dash_segment_type mp4 \
    -format_options "movflags=+cmaf" \
    -write_prft 1 \
    \
    -method POST \
    -http_persistent 1 \
    -timeout 2 \
    -ignore_io_errors 1 \
    -http_opts "
      chunked_post=1:
      send_expect_100=1:
      headers='DASH-IF-Ingest: 1.1':
      headers='Host: localhost:8080':
      icy=0:
      reconnect=1:
      reconnect_at_eof=1:
      reconnect_on_network_error=1:
      reconnect_on_http_error=4xx,5xx:
      reconnect_delay_max=2" \
  "http://$INGEST_HOST/dash/example.str/manifest.mpd"
