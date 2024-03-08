# This will be used to spawn a new terminal in current directory
autoload -Uz add-zsh-hook

function osc7-pwd() {
    emulate -L zsh
    setopt extendedglob

    local LC_ALL=C

    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function chpwd-osc7-pwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}

add-zsh-hook -Uz chpwd chpwd-osc7-pwd

