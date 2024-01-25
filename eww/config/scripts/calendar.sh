#!/usr/bin/env sh

## Cache
calendar_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/calendar
calendar_lock=$calendar_cache_dir/lock
calendar_status=$calendar_cache_dir/status

if [ ! -d "$calendar_cache_dir" ]; then
    mkdir -p "$calendar_cache_dir"

    echo "unlocked" > $calendar_lock
    echo "closed" > $calendar_status
fi

case $1 in
    toggle)
        if [ "$(cat $calendar_lock)" = "unlocked" ]; then
            echo "locked" > $calendar_lock

            # Only open when window is closed
            if [ "$(cat $calendar_status)" = "closed" ]; then
                echo "opened" > $calendar_status
                eww open calendar
            fi
        else
            echo "unlocked" > $calendar_lock

            # Only close when window is opened
            if [ "$(cat $calendar_status)" = "opened" ]; then
                echo "closed" > $calendar_status
                eww close calendar
            fi
        fi
        ;;
esac

