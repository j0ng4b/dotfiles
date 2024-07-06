#!/usr/bin/env sh

# NOTE: _runner already define some commons, if definition is not here
# probably its on _runner.

# Real screenshot path
screenshot_path="$(xdg-user-dir PICTURES)/$(date +'Screenshot-%d%m%Y-%H%M%S.png')"

# Pretty screenshot path used on notification
pretty_path="$(echo $screenshot_path | sed -e "s|$HOME|~|g")"

case $1 in
    # Take a screenshot of entire screen
    screen)
        grim $screenshot_path
        ;;

    # Take a screenshot of a selected area
    area)
        grim -g "$(slurp -d -F "IosevkaJ0ng4b Nerd Font Mono")" $screenshot_path

        if [ $? -gt 0 ]; then
            notify-send -w -a "screenshot.sh" "Screenshot aborted" ""
            exit 1
        fi
        ;;

    *)
        error "Invalid command $1!"
        exit 1
        ;;
esac

# Send screenshot notification
notify-send -w -a "screenshot.sh" -i $screenshot_path "Screenshot saved" \
    "$pretty_path"

