#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
calendar_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/calendar
calendar_lock=$calendar_cache_dir/lock

if [ ! -d "$calendar_cache_dir" ]; then
    mkdir -p "$calendar_cache_dir"

    echo "unlocked" > $calendar_lock
fi

case $1 in
    close)
        if [ "$(cat $calendar_lock)" = "locked" ]; then
            echo "unlocked" > $calendar_lock
            eww close calendar
        fi
        ;;

    toggle)
        if [ "$(cat $calendar_lock)" = "unlocked" ]; then
            echo "locked" > $calendar_lock
            eww open calendar

            # Close others windows
            sh -c "$root/weather.sh close-window"
        else
            echo "unlocked" > $calendar_lock
            eww close calendar
        fi
        ;;
esac

