#!/usr/bin/env sh

# Scripts directory root
root=$(cd $(dirname $0); pwd)

## Cache
workspaces_cache_dir=${XDG_CACHE_HOME:-${HOME}/.cache}/eww/workspaces
workspaces_colors=$workspaces_cache_dir/colors

if [ ! -d "$workspaces_cache_dir" ]; then
    mkdir -p "$workspaces_cache_dir"

    printf "" > $workspaces_colors
    for i in $(seq 1 8); do
        printf "$i\n" >> $workspaces_colors
    done

    cat $workspaces_colors | sort -R | tee $workspaces_colors >/dev/null
fi


# Hyprland socket
socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

__get_single_color() {
    if [ $(cat $workspaces_colors | wc -l) -eq 0 ]; then
        printf "" > $workspaces_colors

        for i in $(seq 1 6); do
            printf "$i\n" >> $workspaces_colors
        done

        cat $workspaces_colors | sort -R | tee $workspaces_colors >/dev/null
    fi

    echo $(head -n 1 $workspaces_colors)
    sed -in '1d' $workspaces_colors
}

_get_colors() {
    printf '{'
    for i in $(seq 1 10); do
        printf "\"$i\": \"color$(__get_single_color)\""
        if [ $i -lt 10 ]; then
            printf ', '
        fi
    done
    printf '}'
}

__get_all_workspaces() {
    workspaces_windows=$(hyprctl workspaces -j |
        jq 'map({key: .id | tostring, value: .windows}) | from_entries')

    colors=$(_get_colors)
    seq 1 10 |
        jq --argjson w "$workspaces_windows" \
            --argjson c "$colors" \
           --slurp \
           --compact-output \
           'map(tostring) | map({id: ., windows: ($w[.]//0), color: $c[.]})'
}

export all=$(__get_all_workspaces)
export current=$(hyprctl monitors -j |
    jq '.[] | select(.focused) | .activeWorkspace.id')

echo "{ \"all\": $all, \"current\": $current }"

socat -u "UNIX-CONNECT:$socket" - |
    while read -r line; do
        case $line in
            "focusedmon>>"*)
                current=$(echo $line |
                    sed -ne 's/focusedmon>>.*,\([0-9]\+\)/\1/p')

                echo "{ \"all\": $all, \"current\": $current }"
                ;;

            "workspace>>"*)
                all=$(__get_all_workspaces)
                current=$(echo $line |
                    sed -ne 's/workspace>>\([0-9]\+\)/\1/p')

                echo "{ \"all\": $all, \"current\": $current }"
                ;;

            *)
                ;;
        esac
    done

