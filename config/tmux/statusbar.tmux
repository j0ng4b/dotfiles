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


status "#{?client_prefix,#[fg=$base04 bg=$base09 bold],#[fg=$base04 bg=$base0B bold]}  $(whoami)@#h #{?client_prefix,#[fg=$base09 bg=$base04 nobold],#[fg=$base0B bg=$base04 nobold]}#[fg=$base04 bg=$base03]"
status "#[fg=$base07 bg=$base03]  #{session_name} "
status "#($config_root/utils/git.tmux)"
status "#[fg=$base03 bg=$base01]#[fg=$base01 bg=$base00]"

set_option -g status-left "$STATUS_LEFT"

# Right
set_option -g status-right ''
set_option -g status-right-length 50

status "#[fg=$base04 bg=$base03]#{?client_prefix,#[fg=$base09 bg=$base04 nobold],#[fg=$base0B bg=$base04 nobold]}#{?client_prefix,#[fg=$base04 bg=$base09 bold],#[fg=$base04 bg=$base0B bold]} %H:%M "
status " #($config_root/utils/battery.tmux)"
status "#[fg=$base07 bg=$base03]"
status "#[fg=$base01 bg=$base00]#[fg=$base03 bg=$base01]"

set_option -g status-right "$STATUS_RIGHT"


##
## Window list

# No separator between windows in the status line
set_option -g window-status-separator ''

## Inactive
set_option -g window-status-format ''


window "#[fg=$base01 bg=$base00]#[fg=$base03 bg=$base01]"
window "#[fg=$base07 bg=$base03] #{window_index}:#{window_name}#{window_flag} "
window "#[fg=$base03 bg=$base01]#[fg=$base01 bg=$base00]"

set_option -g window-status-format "$WINDOW_INACTIVE"


## Active
set_option -g window-status-current-format ''


window "#[fg=$base03 bg=$base00]#{?client_prefix,#[fg=$base09 bg=$base04 nobold],#[fg=$base0B bg=$base04 nobold]}"
window "#{?client_prefix,#[fg=$base04 bg=$base09 bold],#[fg=$base04 bg=$base0B bold]} #{window_index}:#{window_name}#{window_flag} "
window "#{?client_prefix,#[fg=$base09 bg=$base04 nobold],#[fg=$base0B bg=$base04 nobold]}#[fg=$base03 bg=$base00]"

set_option -g window-status-current-format "$WINDOW_ACTIVE"


##
## Clock mode

# Color
set_option -g clock-mode-colour "${base0B}"

# Hour format
set_option -g clock-mode-style 24


##
## Message
##

# Set status line message style
set_option -g message-style "fg=$base06 bg=$base01"

# Set status line message command style
set_option -g message-command-style "fg=$base06 bg=$base02"


##
## Pane
##

# Set Indicator for active pane
set_option -g pane-border-indicators 'both'

# Set the pane border style for the currently active pane
set_option -g pane-active-border-style "fg=$base0B bg=$base00"

# Set the pane border style for inactive pane
set_option -g pane-border-style "fg=$base02 bg=$base00"

##
## Menu
##

set_option -g menu-style "fg=$base06 bg=$base01"
set_option -g menu-border-style "fg=$base06 bg=$base01"
set_option -g menu-selected-style "fg=$base04 bg=$base0B"

# Set the type of characters used for drawing menu borders
set_option -g menu-border-lines 'rounded'

##
## Pop-up
##

set_option -g popup-style "fg=$base06 bg=$base01"
set_option -g popup-border-style "fg=$base07 bg=$base01"

# Set the type of characters used for drawing pop-up borders
set_option -g popup-border-lines 'rounded'

