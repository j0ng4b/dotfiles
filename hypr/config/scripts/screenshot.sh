#!/usr/bin/env sh

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
        ;;

    *)
        exit 1
        ;;
esac

# Send screenshot notification
notify-send -w -a "screenshot.sh" -i $screenshot_path "Screenshot saved" \
    "$pretty_path"

