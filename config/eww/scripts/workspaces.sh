#!/usr/bin/env sh

__get_all_workspaces() {
    workspaces_windows=$(swaymsg -t get_workspaces |
        jq 'map({key: .name | tostring, value: [ .focused, true ]}) | from_entries')

    seq 1 5 |
        jq --argjson w "$workspaces_windows" \
           --slurp \
           --compact-output \
           'map(tostring) | map({name: ., focused: ($w[.][0]//false), non_empty: ($w[.][1]//false)})'
}

echo "$(__get_all_workspaces)"
swaymsg -t subscribe -m '[ "workspace" ]' | while read -r event; do
    if [ "$(echo $event | jq --raw-output '.change')" = "focus" ]; then
        echo "$(__get_all_workspaces)"
    fi
done

