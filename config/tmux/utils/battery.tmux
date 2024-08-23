#!/bin/env sh

root=$(cd $(dirname $0); pwd)

battery() {
    runner="$root/../scripts/script-runner"

    icon=$(sh -c "$runner battery icon")
    capacity=$(sh -c "$runner battery capacity")

    echo "$capacity% $icon "
}

battery

