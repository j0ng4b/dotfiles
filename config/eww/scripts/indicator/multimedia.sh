#!/usr/bin/env sh

get_status() {
    mic=$(wpctl get-volume @DEFAULT_SOURCE@ | sed -ne 's/.*\(MUTED\).*/\L\1/p')
    speaker=$(wpctl get-volume @DEFAULT_SINK@ | sed -ne 's/.*\(MUTED\).*/\L\1/p')

    if [ -z $speaker ]; then
        speaker=$(wpctl get-volume @DEFAULT_SINK@ | sed -ne 's/.*\([0-9]\.[0-9]\{2\}\).*/\1/p')
    fi

    echo "{\"speaker\": \"$speaker\", \"microphone\": \"$mic\"}"
}

case $1 in
    status)
        get_status
        ;;
esac

