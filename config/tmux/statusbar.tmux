#!/bin/env sh

# Configuration root variable
config_root="$(cd $(dirname $0); pwd)"

##
## Helpers
##

STATUS_LEFT=''
STATUS_RIGHT=''

WINDOW_ACTIVE=''
WINDOW_INACTIVE=''


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

window() {
    if [ -z "$(get_option window-status-format)" ]; then
        WINDOW_INACTIVE="$WINDOW_INACTIVE$@"
    elif [ -z "$(get_option window-status-current-format)" ]; then
        WINDOW_ACTIVE="$WINDOW_ACTIVE$@"
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
set_option -s status-interval 1

# Align window list to center of the bar
set_option -s status-justify absolute-centre

# Default status bar colors
set_option -g status-style "fg=$base07, bg=$base00"


##
## Status sides

# Left
set_option -g status-left '' # reset
set_option -g status-left-length 50

status "#[fg=$base04 bg=$base0B bold]  $(whoami)@#h #[fg=$base0B bg=$base04 nobold]#[fg=$base04 bg=$base03]"
status "#[fg=$base07 bg=$base03]  #{session_name} "
status "#($config_root/utils/git.tmux)"
status "#[fg=$base03 bg=$base01]#[fg=$base01 bg=$base00]"

set_option -g status-left "$STATUS_LEFT"

# Right
set_option -g status-right ''
set_option -g status-right-length 50

status "#[fg=$base04 bg=$base03]#[fg=$base0B bg=$base04]#[fg=$base04 bg=$base0B bold] %H:%M "
status "#[fg=$base07 bg=$base03]#($config_root/utils/battery.tmux)"
status "#[fg=$base01 bg=$base00]#[fg=$base03 bg=$base01]"

set_option -g status-right "$STATUS_RIGHT"


##
## Window list

# No separator between windows in the status line
set_option -g window-status-separator ''

# Inactive
set_option -g window-status-format ''

window "#[fg=$base01 bg=$base00]#[fg=$base03 bg=$base01]"
window "#[fg=$base07 bg=$base03] #{window_index}:#{window_name}#{window_flag} "
window "#[fg=$base03 bg=$base01]#[fg=$base01 bg=$base00]"

set_option -g window-status-format "$WINDOW_INACTIVE"

# Active
set_option -g window-status-current-format ''

window "#[fg=$base03 bg=$base00]#[fg=$base0B bg=$base03]"
window "#[fg=$base04 bg=$base0B bold] #{window_index}:#{window_name}#{window_flag} "
window "#[fg=$base0B bg=$base03 nobold]#[fg=$base03 bg=$base00]"

set_option -g window-status-current-format "$WINDOW_ACTIVE"


##
## Clock mode

# Color
set_option -g clock-mode-colour "${base0B}"

# Hour format
set_option -g clock-mode-style 24

