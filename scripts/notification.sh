#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

# Notifications level
level_silent=100
level_important=60
level_noisy=0


_get_status() {
    case $(dunstctl get-pause-level) in
        $level_silent)
            nerd="󰂛"
            phosphor=""
            pause_level="silent"
            ;;

        $level_important)
            nerd="󰂚"
            phosphor=""
            pause_level="important"
            ;;

        $level_noisy)
            nerd="󰂞"
            phosphor=""
            pause_level="noisy"
            ;;
    esac

    printf '{'
    printf '"icons": {'
    printf '"nerd": "%s",' $nerd
    printf '"phosphor": "%s"' $phosphor
    printf '},'
    printf '"level": "%s",' $pause_level
    printf '"Level": "%s"' $(echo $pause_level | sed "s/[^ ]*/\\u&/g")
    printf '}\n'
}

cmd=$1
case $cmd in
    status)
        _get_status
        ;;

    set)
        subcmd=$2
        case $subcmd in
            silent | important | noisy | toggle)
                if [ "$subcmd" = "toggle" ]; then
                    case $(dunstctl get-pause-level) in
                        $level_silent)
                            subcmd=important
                            ;;

                        $level_important)
                            subcmd=noisy
                            ;;

                        $level_noisy)
                            subcmd=silent
                            ;;
                    esac
                fi

                eval "dunstctl set-pause-level \$level_$subcmd"

                # Close any displayed notification
                for _ in $(seq 1 $(dunstctl count displayed)); do
                    dunstctl close
                done
                ;;
        esac
esac

