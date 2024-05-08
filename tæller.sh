#!/bin/zsh
# shellcheck shell=bash

BASEDIR=$(dirname $0)

# define default filter file
filter="$BASEDIR/google.txt"

# allow user to specify an alternative filter file
#   ./tæller.sh meta.txt
if [ -n "$1" ];
then
    filter="$1"
fi


sniff() {
    if [ ! -f "$filter" ];
    then
        echo "'$filter' filter file does not exist" >&2
        exit 1
    fi

    sudo tcpdump --immediate-mode -nql -F "$filter" 2>&1
}

debounce() {
    # limit to 10 beeps per second

    last_line="none"

    while read -r line;
    do
        if [ "$last_line" = "${line:0:10}" ];
        then
            continue;
        fi

        last_line="${line:0:10}"
        echo "$last_line"
    done
}

beep() {
    while read -r;
    do
        # visual output
        printf "[32;1m.[0m"

        # the bell is too slow
        # printf \\x07

        # this works, thanks to https://osxdaily.com/2016/03/31/play-dtmf-tones-mac/
#        afplay --volume 0.05 /System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/telephony/dtmf-pound.caf &
        afplay --volume 0.05 $BASEDIR/GeigerCounter.wav &
    done
}

sniff | debounce | beep

