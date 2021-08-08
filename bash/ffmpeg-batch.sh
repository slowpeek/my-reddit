#!/usr/bin/env bash

# Author: /u/kevors
# Permalink: https://github.com/slowpeek/my-reddit/blob/master/bash/ffmpeg-batch.sh

set -eu

say () {
    echo "== $*"
}

on_sigint () {
    if [[ -n ${partial-} ]]; then
        say "remove partially encoded $partial"
        rm "$partial"
    fi

    exit 1
}

trap on_sigint SIGINT

audio_codec () {
    local args=(
        -loglevel error
        -select_streams a:0
        -show_entries 'stream=codec_name'
        -of 'default=nw=1:nk=1'
    )

    ffprobe "${args[@]}" "$1" 2>/dev/null || echo
}

while read -r -d '' path; do
    out=${path%.*}.mp4

    if [[ -e $out ]]; then
        say "skip existing $out"
        continue
    fi

    ac=$(audio_codec "$path")

    if [[ -z $ac ]]; then
        say "cant figure out audio codec for $path"
        continue
    fi

    [[ $ac == aac ]] && ac=copy || ac=aac

    args=(
        -hide_banner
        -i "$path"
        -c:v libx264 -crf 23 -preset medium
        -c:a "$ac"
        -movflags +faststart
    )

    partial=$out st=0
    ffmpeg "${args[@]}" "$out" </dev/null || st=$?
    partial=

    if [[ $st != 0 ]]; then
        say "ffmpeg exit code $st for $path"
        continue
    fi

    say "done $path"
done < <(find . -type f -iname \*.mkv -print0)
