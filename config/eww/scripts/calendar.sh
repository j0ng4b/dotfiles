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
    open)
        if [ "$(cat $calendar_lock)" = "unlocked" ]; then
            echo "locked" > $calendar_lock
            eww open calendar
        fi
        ;;

    close)
        if [ "$(cat $calendar_lock)" = "locked" ]; then
            echo "unlocked" > $calendar_lock
            eww close calendar
            eww update month_offset=0
        fi
        ;;

    toggle)
        if [ "$(cat $calendar_lock)" = "unlocked" ]; then
            echo "locked" > $calendar_lock
            eww open calendar
        else
            echo "unlocked" > $calendar_lock
            eww close calendar
            eww update month_offset=0
        fi
        ;;

    month)
        offset=$(eww get month_offset)
        name=$(date --date="$(date +%Y-%m-15) $offset month" +'%B' | sed 's/[^ ]*/\u&/g')
        num=$(date --date="$(date +%Y-%m-15) $offset month" +'%-m')

        echo "{\"name\": \"$name\", \"num\": \"$num\"}"
        ;;

    year)
        offset=$(eww get month_offset)
        num=$(date --date="$(date +%Y-%m-15) $offset month" +'%Y' | sed 's/[^ ]*/\u&/g')

        echo "{\"num\": \"$num\"}"
        ;;

    next-month)
        offset=$(eww get month_offset)
        eww update month_offset=$(($offset + 1))
        ;;

    prev-month)
        offset=$(eww get month_offset)
        eww update month_offset=$(($offset - 1))
        ;;
esac

