# Open or enter on completion menu
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

# Cycle thought completion menu entries
bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete


# Insert unambiguous prefix
## all Tab widgets
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

## all history widgets
zstyle ':autocomplete:*history*:*' insert-unambiguous yes

## ^S
zstyle ':autocomplete:menu-search:*' insert-unambiguous yes


# Add space after some completions
zstyle ':autocomplete:*' add-space \
    executables aliases functions builtins reserved-words commands


# Minimum input before show menu
zstyle ':autocomplete:*' min-input 1
