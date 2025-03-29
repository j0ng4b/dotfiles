## ls
_ls_default_opts="--all --icons --group-directories-first"
_ls_default_long_opts="--long --smart-group --total-size --git"

alias -g ls="eza $_ls_default_opts --classify=always"
alias -g ll="eza $_ls_default_opts $_ls_default_long_opts"

alias -g lt="eza $_ls_default_opts --tree --level=2"
alias -g llt="eza $_ls_default_opts $_ls_default_long_opts --tree --level=2"

alias -g lr="eza $_ls_default_opts --recurse --level=2"
alias -g llr="eza $_ls_default_opts $_ls_default_long_opts --recurse --level=2"

alias -g lg="eza $_ls_default_opts $_ls_default_long_opts --git-repos"


## cat
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
elif command -v batcat >/dev/null 2>&1; then
    alias cat="batcat"
fi


## mkdir
alias md="mkdir -p"


## rm
alias rm="rm -f"
alias rd="rm -rf"


## clear
alias cl="clear"


## yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"

    cwd="$(command cat -- "$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$(pwd)" ]; then
        builtin cd -- "$cwd"
    fi

    rm -f -- "$tmp"
}

