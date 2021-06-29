#!/bin/bash

# Author: /u/kevors
# Reddit: https://www.reddit.com/r/bash/comments/oa7srl/:/h3gda9u/
# Permalink: https://github.com/slowpeek/my-reddit/blob/master/bash/file-selector.sh

file_selector() {
    local origin=${1%${1##*[^/]}} menu=() sel up
    local cwd=$origin PS3

    # Reset result
    FILE_SELECTOR_RESULT=

    while true; do
        clear -x
	    printf '%s\n' "${cwd:-/}"

        PS3=$'-----\nq Quit'

        up=n
        # Restrict the user to the original $1
        if [[ $cwd != "$origin" ]]; then
            up=y
            PS3+='    u Up'
        fi

        PS3+=$'\n-----\nPlease, select: '

        # Test for empty dir
        if read -r < <(find "${cwd:-/}" -maxdepth 0 -type d ! -empty); then
            readarray -t menu < <(find "$cwd"/* -maxdepth 0 -printf '%y%f%y\n' |\
                                      sed 's~^[^d]~z~;s~[^d]$~~;s~d$~/~' | sort | cut -c2-)

            printf '%d items\n\n' "${#menu[@]}"

	        select sel in "${menu[@]}"; do
                break
            done
        else
            read -r -p $'empty\n\n'"$PS3"
            sel=
        fi

        case $REPLY in
            [qQ])
                # Quit, nothing selected
                return 1
                ;;
            [uU])
                # Go up if allowed
                [[ $up == n ]] || cwd=${cwd%/*}
                ;;
            *)
                case $sel in
                    '')
                    ;;
                    */)
                        # Dir selected, descend
			            cwd+=/"${sel::-1}"
                        ;;
                    *)
                        # Not dir selected, return the selection
			            FILE_SELECTOR_RESULT=$sel
                        return 0
                        ;;
                esac
        esac
    done
}


file_selector ~
echo "$FILE_SELECTOR_RESULT"
