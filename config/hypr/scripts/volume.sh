#!/usr/bin/env sh

error() { echo "\033[31m[Error]\033[0m $1"; }

# Check if wpctl is installed (wirepumbler)
if [ ! -e "$(which wpctl)" ]; then
    error "wpctl not found!"
    exit 1
fi

case $1 in
    lower)
        wpctl set-volume @DEFAULT_SINK@ 5%-
        ;;

    toggle)
        wpctl set-mute @DEFAULT_SINK@ toggle
        ;;

    raise)
        wpctl set-volume @DEFAULT_SINK@ 5%+
        ;;

    *)
        error "Invalid command $1!"
        exit 1
        ;;
esac

