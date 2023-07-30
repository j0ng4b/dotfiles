#!/usr/bin/env sh

hc() {
    herbstclient "$@"
}

get_value() {
    echo $(echo $1 | cut -d' ' -f$2)
}

hc --idle | {
    while true; do
        IFS=$'\t' read -r cmd || break
        case $(get_value "$cmd" 1) in
            attribute_changed)
                attr=$(get_value "$cmd" 2)
                [ "$attr" = "tags.focus.frame_count" ] || continue

                value="none"
                new_value=$(get_value "$cmd" 4)

                [ "$new_value" -gt "1" ] && value="if_empty"

                hc set show_frame_decorations $value
                ;;
        esac
    done
}

