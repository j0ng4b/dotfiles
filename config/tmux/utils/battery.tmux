#!/bin/env sh

root=$(cd $(dirname $0); pwd)

battery() {
    runner="$root/../scripts/scripter"
    capacity=$(sh -c "$runner battery status" | jq --raw-output '.capacity')

    echo "$capacity% "
}

battery

