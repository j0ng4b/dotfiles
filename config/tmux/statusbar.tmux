#!/bin/env sh

# Configuration root variable
config_root="$(cd $(dirname $0); pwd)"

# Load helpers scripts
. "$config_root/utils/battery.tmux"


##
## Helpers
##

STATUS_LEFT=''
STATUS_MIDDLE=''
STATUS_RIGHT=''


get_option() {
    value=$(tmux show-option -gvq $1)

    if [ -n "$value" ]; then
        echo $value
    else
        echo $2
    fi
}

set_option() {
    tmux set-option "$@"
}

status() {
    if [ -z "$(get_option status-left)" ]; then
        STATUS_LEFT="$STATUS_LEFT$@"
    elif [ -z "$(get_option status-right)" ]; then
        STATUS_RIGHT="$@$STATUS_RIGHT"
    fi
}


##
## Styling
##

### Load base theme
. "$config_root/colors.tmux"


# Enable status bar by default
set_option -s status on

# Status bar update interval
set_option -s status-interval 5

# Align window list to center of the bar
set_option -s status-justify absolute-centre

# Default status bar colors
set_option -g status-style "fg=$base07, bg=$base00"


# Status (left side)
set_option -g status-left '' # reset
set_option -g status-left-length 50

status "#[fg=$base04 bg=$base0B bold]  $(whoami)@#h #[fg=$base0B bg=$base04 nobold]#[fg=$base04 bg=$base03]"
status "#[fg=$base07 bg=$base03]  #{session_name} #[fg=$base03 bg=$base01]#[fg=$base01 bg=$base00]"

set_option -g status-left "$STATUS_LEFT"


# Status (right side)
set_option -g status-right ''
set_option -g status-right-length 50

status "#[fg=$base04 bg=$base03]#[fg=$base0B bg=$base04]#[fg=$base04 bg=$base0B bold] %H:%M "

if has_battery; then
    status " $(status_battery) "
    status "#[fg=$base07 bg=$base03]"
fi

status "#[fg=$base01 bg=$base00]#[fg=$base03 bg=$base01]"

set_option -g status-right "$STATUS_RIGHT"

