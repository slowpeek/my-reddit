#!/usr/bin/env bash

# https://github.com/slowpeek/my-reddit/bash-read-vs-head

size=$1
fn=$2

loop=1000

ticks=()
tick() {
    ticks+=("$(date +%s.%N)")
}

tick

for (( i=0; i<loop; i++ )); do
    read -r -N "$size" _
done < "$fn"

tick

for (( i=0; i<loop; i++ )); do
    head -c "$size" &>/dev/null
done < "$fn"

tick

printf ' %s' "$size" "${ticks[@]}"
echo
