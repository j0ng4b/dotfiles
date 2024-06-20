#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
infocenter_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/infocenter
infocenter_lock=$infocenter_cache_dir/lock

if [ ! -d "$infocenter_cache_dir" ]; then
    mkdir -p "$infocenter_cache_dir"
    echo "unlocked" > $infocenter_lock
fi

case $1 in
    open)
        if [ "$(cat $infocenter_lock)" = "unlocked" ]; then
            echo "locked" > $infocenter_lock
            eww open infocenter
        fi
        ;;

    close)
        if [ "$(cat $infocenter_lock)" = "locked" ]; then
            echo "unlocked" > $infocenter_lock
            eww close infocenter
            eww update month_offset=0
        fi
        ;;

    toggle)
        if [ "$(cat $infocenter_lock)" = "unlocked" ]; then
            echo "locked" > $infocenter_lock
            eww open infocenter
        else
            echo "unlocked" > $infocenter_lock
            eww close infocenter
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

