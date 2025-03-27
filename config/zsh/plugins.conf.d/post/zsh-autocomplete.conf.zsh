# Make ← and → always move the cursor on the command line
bindkey -M menuselect  '^[[D' .backward-char  '^[OD' .backward-char
bindkey -M menuselect  '^[[C'  .forward-char  '^[OC'  .forward-char


# Insert common string
# all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

# all history widgets
zstyle ':autocomplete:*history*:*' insert-unambiguous yes

# ^S
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes


# Set autocompletion timeout
zstyle ':autocomplete:*' timeout 0.5


# Set minimum of characters before display completion
zstyle ':autocomplete:*' min-input 3


# Enable history substring search
#
# NOTE: this may prevent zsh-autocomplete from crash, testing before enabling
# bellow code

# bindkey '^[[A' history-substring-search-up "$terminfo[kcuu1]" history-substring-search-up
# bindkey '^[[B' history-substring-search-down "$terminfo[kcud1]" history-substring-search-down

# bindkey -M vicmd 'k' history-substring-search-up
# bindkey -M vicmd 'j' history-substring-search-down

