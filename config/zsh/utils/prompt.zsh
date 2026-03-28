## Setup prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"

    autoload -Uz add-zsh-hook add-zle-hook-widget

    # Transient prompt
    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"

    function _transient_prompt() {
        [ "$CONTEXT" = "start" ] || return 0

        # Save original prompt
        SAVED_PROMPT="$PROMPT"
        SAVED_RPROMPT="$RPROMPT"

        # Use transient prompt
        PROMPT="$TRANSIENT_PROMPT"
        RPROMPT=""
        zle reset-prompt && zle -R

        # Restore prompt to original prompt
        PROMPT="$SAVED_PROMPT"
        RPROMPT="$SAVED_RPROMPT"
    }
    add-zle-hook-widget zle-line-finish _transient_prompt

    # Use transient prompt on ctrl+c
    TRAPINT() { _transient_prompt; return $(( 128 + $1 )) }

    # Bottom positioning
    _bottom_prompt() {
        [ "${ZPROMPT_POS}" = "UP" ] && return
        print -n "\e[$LINES;H"
    }
    add-zsh-hook precmd _bottom_prompt
fi
