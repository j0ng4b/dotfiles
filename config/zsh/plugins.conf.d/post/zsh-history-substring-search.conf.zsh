# Normal arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Application mode arrow keys (vi-mode / zsh)
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Fallback to terminfo
if [[ -n "$terminfo[kcuu1]" ]]; then
    bindkey "$terminfo[kcuu1]" history-substring-search-up
fi
if [[ -n "$terminfo[kcud1]" ]]; then
    bindkey "$terminfo[kcud1]" history-substring-search-down
fi

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
