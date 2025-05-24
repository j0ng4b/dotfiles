#!/usr/bin/env sh

case $1 in
    close)
        eww update "window-$2-open"=false

        # Wait animation to finish before closing
        sleep 0.15

        # Close the specified window
        eww close $2
        ;;

    toggle)
        closed=""
        for window in $(eww active-windows); do
            window=$(echo $window | cut -d' ' -f2)
            if [ "$window" = "$2" ]; then
                closed="true"
            fi

            case $window in
                *settings* | *control-center*)
                    eww update "window-$window-open"=false

                    # Wait animation to finish before closing
                    sleep 0.15

                    eww close $window
                    ;;
            esac
        done

        # If the specified window was not closed, open it
        if [ -z "$closed" ]; then
            eww open $2
            eww update "window-$2-open"=true
        fi
        ;;
esac


