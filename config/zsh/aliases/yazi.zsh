function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"

    cwd="$(command cat -- "$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$(pwd)" ]; then
        builtin cd -- "$cwd"
    fi

    command rm -f -- "$tmp"
}
