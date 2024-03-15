#!/bin/bash

set -e

# load configuration variables
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_DIR="$( cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd )"
. "${ROOT_DIR}/examples/config"

# encode
ffmpeg ${FFMPEG_GLOBAL_OPTS} \
  \
  -re -stream_loop -1 -i "${INPUT_FILE}" \
  -fflags genpts \
  \
  -filter_complex "
    [0:v]drawtext=x=(w-text_w)-5:y=5:fontsize=54:fontcolor=white:text='720p':box=1:boxcolor=black@.6:boxborderw=5,scale=1280x720[v720p];
    [0:v]drawtext=x=(w-text_w)-5:y=5:fontsize=54:fontcolor=white:text='360p':box=1:boxcolor=black@.6:boxborderw=5,scale=640x360[v360p]
  " \
  -map [v720p] \
  -map [v360p] \
  -map 0:a \
  -map 0:a \
  \
  -c:v libx264 \
    -profile:v main \
    -crf:v:0 23 -bufsize:v:0 2250k -maxrate:v:0 2500k \
    -crf:v:1 23 -bufsize:v:1  540k -maxrate:v:1  600k \
    -g:v 100000 -keyint_min:v 50000 -force_key_frames:v "expr:gte(t,n_forced*2)" \
    -x264opts no-open-gop=1 \
    -bf 2 -b_strategy 2 -refs 1 \
    -rc-lookahead 24 \
  -c:a aac \
    -b:a:0 128k \
    -b:a:1 64k \
  \
  -f hls \
    \
    -hls_time 6 \
    -hls_list_size 0 \
    -hls_segment_type fmp4 \
    -hls_playlist_type event \
    -hls_start_number_source epoch \
    -hls_segment_options "movflags=+cmaf+dash+delay_moov+skip_sidx+skip_trailer" \
    -hls_flags +append_list+discont_start+program_date_time+independent_segments \
    \
    -var_stream_map "a:0,name:audio-128k,agroup:audio,default:yes a:1,name:audio-64k,agroup:audio v:0,name:video-720p,agroup:audio v:1,name:video-360p,agroup:audio" \
    \
    -hls_fmp4_init_filename "init-%v.mp4" \
    -hls_segment_filename "webroot/segment-%v-%010d.mp4" \
    -master_pl_name "master.m3u8" \
    "${SCRIPT_DIR}/webroot/%v.m3u8"
