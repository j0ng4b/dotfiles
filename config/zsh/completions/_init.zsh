# Create completion cache directory
mkdir -p $XDG_CACHE_HOME/zsh/

fpath=("$ZDATADIR/plugins/_zsh-completions/src" $fpath)

_complete_alias() {
    [[ -n $PREFIX  ]] && compadd -- ${(M)${(k)galiases}:#$PREFIX*}
    return 1
}

# Cache
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# File
zstyle ':completion:*' file-list false
zstyle ':completion:*' file-sort name

# List files and directories
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' list-separator '->'

# Match
zstyle ':completion:*' match-original both
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}'             \
    'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'         \
    'l:|=* r:|=*'

# Approximation
zstyle ':completion:*' max-errors 5
zstyle ':completion:*' original true

# Miscellaneous
zstyle ':completion:*' add-space false
zstyle ':completion:*' assign-list true
zstyle ':completion:*' completer _complete _complete_alias _expand _match _prefix
zstyle ':completion:*:descriptions' format $'\e[31m[%d]\e[0m'
zstyle ':completion:*' expand prefix
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' verbose true
zstyle ':completion:*' rehash true

# FZF Integrations
if command -v fzf >/dev/null 2>&1; then
    zstyle ':completion:*' menu no

    zstyle ':fzf-tab:*' switch-group '<' '>'
else
    zstyle ':completion:*' menu select=1
fi

# Enable completion
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump
