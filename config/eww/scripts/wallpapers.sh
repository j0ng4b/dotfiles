#!/usr/bin/env sh

pictures_dir="$(xdg-user-dir PICTURES)"
wallpapers_dir="$pictures_dir/wallpapers"
mkdir -p "$wallpapers_dir"

_get_wallpapers() {
    echo $(ls "$wallpapers_dir" | jq \
        --arg dir "$wallpapers_dir" \
        --raw-input \
        --slurp -c \
        'split("\n")[:-1] | map($dir + "/" + .)')
}

case $1 in
    list)
        _get_wallpapers
        inotifywait -q -m -e modify,create,delete,move --format '%w%f' "$wallpapers_dir" |
            while read -r _; do
                _get_wallpapers
            done
        ;;

    set)
        swww img \
            --transition-type wave \
            --transition-duration 2.5 \
            --transition-angle 315 \
            --transition-wave 10,10 \
            "$2"
        ;;

    toggle)
        eww close control-center themes
        case $(eww active-windows) in
            *wallpapers*)
                eww close wallpapers
                ;;
            *)
                eww open wallpapers
                ;;
        esac
        ;;
esac

