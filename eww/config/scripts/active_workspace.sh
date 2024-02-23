#!/usr/bin/env sh

HYPRLAND_SOCKET=/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock

# Generate first active workspace
hyprctl -j activeworkspace | jq '(.id - 1)'

socat -u UNIX-CONNECT:$HYPRLAND_SOCKET - | while read -r line; do
    case ${line%>>*} in
        workspace)
            echo $(( ${line#*>>} - 1 ))
            ;;
    esac
done

