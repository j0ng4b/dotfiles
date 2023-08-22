# zsh parameter completion for the dotnet CLI
_dotnet_zsh_complete() {
    # The array $words contains the words present on the command line currently
    # being edited.
    local completions=("$(dotnet complete "$words")")

    # If the completion list is empty, just continue with filename selection
    if [ -z "$completions" ]; then
        _arguments '*::arguments: _normal'
        return
    fi

    # _values is a function for completion.
    #
    # (ps:\n:) is a parameter substitution thats means:
    #     p  -> Recognize the same escape sequences as the print.
    #     s  -> Force field splitting at the separator string.
    #     \n -> It's the separator of string.
    #
    _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet

