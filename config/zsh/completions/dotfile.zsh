function _dotfile_script_completion() {
    local line

    _arguments -C \
        "1: :(install uninstall check list help)" \
        "*::arg:->args"

    case $line[1] in
        install | uninstall)
            ;;

        check)
            ;;
    esac
}

compdef _dotfile_script_completion dotfile
