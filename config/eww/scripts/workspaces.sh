#!/usr/bin/env sh

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

__get_all_workspaces() {
    workspaces_windows=$(hyprctl workspaces -j |
        jq 'map({key: .id | tostring, value: .windows}) | from_entries')

    seq 1 10 |
        jq --argjson w "$workspaces_windows" \
           --slurp \
           --compact-output \
           'map(tostring) | map({id: ., windows: ($w[.]//0)})'
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

