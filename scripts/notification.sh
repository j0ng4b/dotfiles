#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Cache
cache_dir=$SCRIPT_CACHE_DIR

# Notification mode
mode_normal="default"
mode_dnd="do-not-disturb"


_get_status() {
    mode=$(makoctl mode)
    case $mode in
        *$mode_dnd*)
            nerd="󰂛"
            phosphor=""
            pause_level="silent"
            ;;

        *$mode_normal*)
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
            silent | noisy | toggle)
                if [ "$subcmd" = "toggle" ]; then
                    mode=$(makoctl mode)
                    case $mode in
                        *$mode_dnd*)
                            subcmd="-r do-not-disturb"
                            ;;

                        *$mode_normal*)
                            subcmd="-a do-not-disturb"
                            ;;
                    esac
                fi

                # Close any displayed notification
                makoctl dismiss --all

                eval "makoctl mode $subcmd"
                ;;
        esac
esac

