# Create completion cache directory
mkdir -p $XDG_CACHE_HOME/zsh/

_complete_alias() {
    [[ -n $PREFIX  ]] && compadd -- ${(M)${(k)galiases}:#$PREFIX*}
    return 1
}

# Cache
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# File
zstyle ':completion:*' file-list true
zstyle ':completion:*' file-sort name

# List files and directories
zstyle ':completion:*' list-colors ''
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
zstyle ':completion:*' add-space true
zstyle ':completion:*' completer _expand _complete_alias _complete             \
    _ignored _match _approximate _prefix
zstyle ':completion:*' format $'\n%d'
zstyle ':completion:*' expand prefix
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' menu select=1
zstyle ':completion:*' verbose true

# Enable completion
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump

