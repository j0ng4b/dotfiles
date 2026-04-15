## sudo
alias sudo="sudo "


## ls
if command -v eza >/dev/null 2>&1; then
    _ls_default_opts="--all --icons --group-directories-first"
    _ls_default_long_opts="--long --smart-group --total-size --git"

    alias ls="eza $_ls_default_opts --classify=always"
    alias ll="eza $_ls_default_opts $_ls_default_long_opts"

    alias lt="eza $_ls_default_opts --tree --level=2"
    alias llt="eza $_ls_default_opts $_ls_default_long_opts --tree --level=2"

    alias lr="eza $_ls_default_opts --recurse --level=2"
    alias llr="eza $_ls_default_opts $_ls_default_long_opts --recurse --level=2"

    alias lg="eza $_ls_default_opts $_ls_default_long_opts --git-repos"
else
    alias ls="ls -FA"
    alias ll="ls -FAl"

    alias lr="ls -AFR"
    alias llr="ls -FARl"
fi


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

