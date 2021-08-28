#!/usr/bin/env bash

# Author: /u/kevors
# Reddit: https://www.reddit.com/r/bash/comments/pcwis5/:/ham86eu
# Permalink: https://github.com/slowpeek/my-reddit/blob/master/bash/dig-update.sh

set -eu

bye () {
    printf 'error: %s\n' "$1" >&2
    exit 1
}

stamp () {
    printf '%s: %s\n' "$1" "$(date +%H:%M:%S)"
}

query () {
    dig -t mx "$1" +noall +answer +nottlid 2>/dev/null || bye 'dig fail'
}

[[ -n ${1:-} ]] || bye 'domain arg is required'
domain=$1

org=$(query "$domain") || exit
[[ -n $org ]] || bye 'empty dig response'

printf 'Original record ---\n%s\n\n' "$org"

new=$org
pause=5

# Progress bar vars.
pr=0 pr_len=10
t_crdl=$(tput -S <<< $'cr\ndl1')

stamp 'Running since'

while [[ $new == "$org" ]]; do
    for ((i=0; i<pause; i++)); do
        sleep 1

        if ((++pr > pr_len)); then
            pr=0
            echo -n "$t_crdl"
        else
            echo -n .
        fi
    done

    new=$(query "$domain") || exit
done >&2

echo -n "$t_crdl"
stamp 'Updated at'

printf '\nUpdated record ---\n%s\n' "$new"

echo -e '\nDiff ---'
diff -u <(printf '%s\n' "$org") <(printf '%s\n' "$new") | tail -n+3
