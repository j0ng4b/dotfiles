#!/bin/env sh

branch=''
has_git_branch() {
    path=$(__get_pane_path)
    branch="$(git -C $path rev-parse --abbrev-ref HEAD)"

    if [ -n "$branch" ]; then
        return 0
    fi

    return 1
}

get_git_branch() {
    if has_git_branch; then
        branch="$(git -C "$(__get_pane_path)" rev-parse --abbrev-ref HEAD)"
        echo " $branch  "
    fi
}

__get_pane_path() {
    panes="$(tmux list-panes -F '#{pane_active} #{pane_current_path}')"

    IFS=';'
    for line in $(echo $panes | tr '\n' ';'); do
        status="$(echo $line | cut -d' ' -f1)"
        path="$(echo $line | cut -d' ' -f2)"

        if [ "$status" -eq 1 ]; then
            echo $path
            break
        fi
    done
}

get_git_branch

