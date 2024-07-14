#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

cache_dir_window=$cache_dir/window
cache_window_status=$cache_dir_window/status

if [ ! -d "$cache_dir" ]; then
    mkdir -p "$cache_dir"
    mkdir -p "$cache_dir_window"

    echo "closed" > $cache_window_status
fi

_is_window_open() {
    win=$1

    windows=$(cat $cache_window_status)
    if [ "$windows" = "closed" ]; then
        echo "closed"
        return
    fi

    for open_window in $windows; do
        if [ "$win" = "$open_window" ]; then
            echo "open"
            return
        fi
    done

    echo "closed"
}

_close_other_windows() {
    windows=$(cat $cache_window_status)
    if [ "$windows" = "closed" ]; then
        return
    fi

    for window in $windows; do
        eww close $window
    done

    echo "closed" > $cache_window_status
}

cmd=$1
case $cmd in
    window)
        subcmd=$2
        case $subcmd in
            open | close | toggle)
                win=$3
                case $win in
                    menu)
                        if [ "$subcmd" = "toggle" ]; then
                            if [ "$(_is_window_open $win)" = "open" ]; then
                                subcmd="close"
                            else
                                subcmd="open"
                            fi
                        fi

                        _close_other_windows

                        eww $subcmd $win
                        if [ "$subcmd" = "open" ]; then
                            echo $win >> $cache_window_status
                        else
                            sed -ie "/$win/d" $cache_window_status
                        fi
                        ;;
                esac
                ;;
        esac
        ;;

    lock)
        hyprlock --immediate
        ;;

    logout)
        hyprctl quit
        ;;
esac

