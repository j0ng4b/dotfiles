autoload -Uz add-zsh-hook

zle-line-init() {
    [ "$CONTEXT" = "start" ] || return 0

    while true; do
        zle .recursive-edit

        ret=$?
        [ $ret -eq 0 -a "$KEYS" = $'\4' ] || break

        exit 0
    done

    ps=$PROMPT
    rps=$RPROMPT


    bgcolor="%(?.$base01.$base08)"
    fgcolor="%(?.$base05.$base01)"

    echo ""
    PROMPT="%K{$bgcolor}%F{$fgcolor} %(?.➜.✗) %k%F{$bgcolor}%f "
    RPROMPT=""

    zle .reset-prompt


    PROMPT=$ps
    RPROMPT=$rps


    if [ $ret -eq 0 ]; then
        zle .accept-line
    else
        zle .send-break
    fi

    return ret
}


bottom-prompt() {
    # Move the cursor to bottom of screen
    print -n "\e[$LINES;H"

    # Check if ZLE is active
    [ -n "$ZLE" ] && zle .reset-prompt
}


zle -N zle-line-init
add-zsh-hook precmd bottom-prompt

