#!/usr/bin/env sh

HYPRLAND_SOCKET=/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock

# Generate workspaces information
workspace_0_active=false
workspace_1_active=false
workspace_2_active=false
workspace_3_active=false
workspace_4_active=false
workspace_5_active=false
workspace_6_active=false
workspace_7_active=false
workspace_8_active=false
workspace_9_active=false


get_workspaces() {
    echo -n [

    for i in $(seq 0 9); do
        eval echo -n '{\"num\":'$i', \"active\": '\$workspace_${i}_active'}'
        [ $i -lt 9 ] && echo -n ','
    done

    echo ]
}

update_workspaces() {
    for i in $(seq 0 9); do
        eval workspace_${i}_active=false
    done

    for workspace in $(hyprctl -j workspaces | jq '.[]|(.id - 1)'); do
        eval workspace_${workspace}_active=true
    done
}

# Generate first workspaces
update_workspaces
get_workspaces


socat -u UNIX-CONNECT:$HYPRLAND_SOCKET - | while read -r line; do
    case ${line%>>*} in
        createworkspace | destroyworkspace)
            update_workspaces
            get_workspaces
            ;;

        movewindow)
            get_workspaces
            ;;
    esac
done

