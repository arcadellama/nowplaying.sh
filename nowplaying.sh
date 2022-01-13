#!/bin/sh

# nowplaying.sh – A simple, POSIX-compliant shell script to print the
# "Now Playing" status of a local Plex Server to stdout.
#
# Copyright 2022 Justin Teague <arcadellama@posteo.net>
#
########################################################################
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHE
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
########################################################################

PRGNAM="nowplaying.sh"
PRG_VERSION="0.1"

PLEX_HOST="${PLEX_HOST:-}"      # Plex server IP(s), separated by space
MAX_WIDTH=${MAX_WIDTH:-100}     # Set the maximum width of print
TERM_MARGIN=${TERM_MARGIN:-8}   # Set the margin for term

## Functions

print_help() {
cat <<EOF
nowplaying.sh – a simple, POSIX-compliant script to print the "Now Playing"
                status to stdout.

    Usage: '"$PRGNAM" -s "<IP Address of Plex Server>'"

                -s  IP address(es) of Plex Server in quotes, separated
                    by spaces.

EOF
}
print_separator() {
    __charcount="$1"
    __separator="."
    __tput="$(command -v tput)"
    __columns="$("$__tput" cols)"
    __space=0

    if [ "$__columns" -gt "$MAX_WIDTH" ]; then
       __columns="$MAX_WIDTH"
    fi

    __space=$(((__columns - TERM_MARGIN) - __charcount))

    while [ "$__space" -gt 0 ]; do
        printf "%s" "$__separator"
        __space=$((__space - 1))
    done
}

print_nowplaying() {
    __count="$1"
    __album="$2"
    __track="$3"
    __title="$4"
    __user="$5"
    __type="$6"
    printf "  " 
    printf "%s. " "$__count"
    case "$__type" in
        episode)
            printf "%s\:\n\t%s " "$__album" "$__track"
            print_separator "$((4+${#__track}+${#__user}))"
            ;;
          track)
            printf "%s\:\n\t%s " "$__album" "$__track"
            print_separator "$((4+${#__track}+${#__user}))"
            ;;
          movie)
            printf "%s " "$__title"
            print_separator "$((${#__count}+${#__title}+${#__user}))"
            ;;
    esac

    printf " %s\n" "$__user"
}

get_host() {
    set -- ${PLEX_HOST}
    for __host in "$@"; do
        if ping -c1 -t1 "$__host" >/dev/null ; then
            printf "%s" "$__host"
            return 0
        fi
    done 
    exit 0
}

get_element() {
    echo "${2}" | grep -Eo "${1}=\"[a-zA-Z0-9?!&()#:;.,-_ ]*\"" | \
        cut -d '=' -f 2 | tr -d '"' | sed -e "s/\&\#39\;/'/g"
}

get_plexml() {
    curl -s http://"$(get_host)":32400/status/sessions
}

parse_plexml() {
    __title=""
    __user=""
    __album=""
    __track=""
    __type=""
    #__series=""
    #__episode=""

    __count=0
    while IFS= read -r line; do
        case "$(get_element "type" "$line")" in
          episode)
                  __type="episode"
                  __album="$(get_element "grandparentTitle" "$line")"
                  __track="$(get_element "title" "$line")"
                  #__title="$(printf "%s:\n\t%s" "${__album}" "${__track}")"
                  continue ;;
          track)
              __type="track"
              __album="$(get_element "grandparentTitle" "$line")"
              __track="$(get_element "title" "$line")"
              #__title="$(printf "%s:\n\t%s" "${__album}" "${__track}")"
              continue ;;
          movie)
              __type="movie"
              __title="$(get_element "title" "$line")"
              continue ;;
        esac

        if echo "$line" | grep -q 'User id'; then
            __user="$(get_element "title" "$line")"
            if [ "$__count" -eq 0 ]; then
                printf "Now Playing on Plex:\n"
                __count="$((__count+1))"
            fi
            print_nowplaying "$__count" "$__album" "$__track" \
                "$__title" "$__user" "$__type"
            __count="$((__count+1))"

            continue
        fi

    done << EOF
    "$(get_plexml)"
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in 
        -s)
            PLEX_HOST="$2"
            shift 2 ;;
        -h)
            print_help
            exit 0 ;;
    esac
done

parse_plexml

#exit 0
