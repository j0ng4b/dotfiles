#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)


# Helper function
_get_themes_dir() {
    test_dir=$(realpath $root)

    while [ "$test_dir" != "$HOME" ]; do
        if [ -x "$test_dir/dotfile" ]; then
            break
        fi

        test_dir=$(realpath $(dirname $test_dir))
    done

    if [ "$test_dir" != "$HOME" ]; then
        echo "$test_dir/scripts/color_reloader/color"
        return 0
    else
        echo ""
        return 1
    fi
}

_get_themes() {
    themes=$(ls -d "$themes_dir"/*)

    printf "["
    count=0
    n=$(echo "$themes" | wc -w)
    for theme in $themes; do
        count=$((count + 1))
        json=$(sed -n "s/^\(base[0-9A-Fa-f]\{2\}\)='\([^']*\)'/\"\1\":\"\2\",/p" "$theme" | tr -d '\n')
        json=${json%,}

        printf "{"
        printf "\"name\":\"$(basename "$theme")\","
        printf "$json"

        # Remove trailing comma from json if present
        if [ "$count" -eq "$n" ]; then
            printf "}"
        else
            printf "},"
        fi
    done
    echo "]"
}

themes_dir="$(_get_themes_dir)"
case $1 in
    list)
        _get_themes
        inotifywait -q -m -e modify,create,delete,move --format '%w%f' "$themes_dir" |
            while read -r _; do
                _get_themes
            done
        ;;

    set)
        cur_theme=$(cat "$XDG_CONFIG_HOME/sysconf/theme")

        if [ "$cur_theme" = "$2" ]; then
            exit 0
        fi

        printf $2 > "$XDG_CONFIG_HOME/sysconf/theme"
        ;;

    toggle)
        eww close control-center wallpapers
        case $(eww active-windows) in
            *themes*)
                eww close themes
                ;;
            *)
                eww open themes
                ;;
        esac
        ;;
esac

