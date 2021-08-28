#!/usr/bin/env bash

# Author: /u/kevors
# Reddit: https://www.reddit.com/r/bash/comments/pd59z5/:/haobv9s
# Permalink: https://github.com/slowpeek/my-reddit/blob/master/bash/bin-search.sh

set -eu

bin_search () {
    [[ $1 == a ]] || local -n a=$1
    local s=$2
    [[ $3 == r ]] || local -n r=$3

    # Special case
    if [[ ${a[0]} == "$s" ]]; then
        r=0
        return
    fi

    r=$((${#a[@]}-1))
    local l=0 x

    # The "go ahead and implement that in bash" thing
    while ((r-l > 1)); do
        ((x = (l+r)>>1))
        [[ ${a[x]} < "$s" ]] && l=$x || r=$x
    done

    # Finalize
    [[ ${a[r]} == "$s" ]] || {
        r=
        return 1
    }
}

readarray -t haystack < <(cd /usr/bin; compgen -G '*' | sort)

declare index found=0 not_found=0
for needle in "${haystack[@]}"; do
    if bin_search haystack "$needle" index; then
        ((++found))
        printf '%s found at index %s\n' "$needle" "$index"
    else
        ((++not_found))
        printf '%s not found\n' "$needle"
    fi
done

printf '\ntotal=%d found=%d not_found=%d\n' \
       "${#haystack[@]}" "$found" "$not_found"
