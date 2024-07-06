#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

case $1 in
    set)
        brightnessctl --quiet --class backlight set $2 2>&1 >/dev/null
        brightnessctl --save 2>&1 >/dev/null
        ;;

    info)
        cur=$(brightnessctl --class backlight get)
        max=$(brightnessctl --class backlight max)

        echo "{ \"value\": \"$cur\", \"max\": \"$max\" }"
        ;;

    maximum)
        echo $(brightnessctl --class backlight max)
        ;;

    current)
        echo $(brightnessctl --class backlight get)
        ;;
esac

