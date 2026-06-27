# Group completion descriptions
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Dynamic previews with fallback for standard coreutils
zstyle ':fzf-tab:complete:*:*' fzf-preview '
    local file=$realpath

    if [[ -d $file ]]; then
        if command -v eza >/dev/null 2>&1; then
            eza --color=always --icons --group-directories-first -a $file
        else
            ls --color=always -lA $file
        fi
    elif [[ -f $file ]]; then
        if command -v bat >/dev/null 2>&1; then
            bat --color=always --style=numbers,changes $file
        else
            cat $file
        fi
    else
        echo $file
    fi'

# Tree view specifically for the 'cd' command
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
    if command -v eza >/dev/null 2>&1; then
        eza --color=always --icons --tree --level=2 $realpath
    else
        ls --color=always -lA $realpath
    fi'

# Custom process preview for kill/ps commands
zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'
