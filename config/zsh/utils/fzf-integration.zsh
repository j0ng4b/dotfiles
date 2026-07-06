## fzf integration
if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
    else
        # Load key-bindings (Ctrl+R, Ctrl+T, Alt+C)
        if [ -f /usr/share/fzf/key-bindings.zsh ]; then
            source /usr/share/fzf/key-bindings.zsh
        fi

        # Load fzf autocomplete
        if [ -f /usr/share/fzf/completion.zsh ]; then
            source /usr/share/fzf/completion.zsh
        fi
    fi
fi
