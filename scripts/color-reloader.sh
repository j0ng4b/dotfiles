#!/usr/bin/env sh

# TODO: block multiple script spawn

config_file=${XDG_CONFIG_HOME:-$HOME/.config}/system-configs.json

_foot() {
    theme_name=$(cat $config_file | jq --raw-output '.theme')
    if [ -z "$theme_name" ]; then
        return
    fi

    color_dir=${XDG_CONFIG_HOME:-$HOME/.config}/foot/themes
    color_file=$color_dir/$theme_name

    # Update normal colors
    sed -nr 's/.*(regular|bright)([0-9])\s*=\s*([a-zA-Z0-9]{6}).*/\1 \2 \3/p' "$color_file" |
        while read type num color; do
            [ "$type" = "bright" ] && num=$(($num + 8))
            printf "\033]4;$num;#$color\a"
        done

    # Update foreground color
    sed -nr 's/.*foreground\s*=\s*([a-zA-Z0-9]{6}).*/\1/p' "$color_file" |
        while read color; do
            printf "\033]10;#$color\a"
        done

    # Update background color
    sed -nr 's/.*background\s*=\s*([a-zA-Z0-9]{6}).*/\1/p' "$color_file" |
        while read color; do
            printf "\033]11;#$color\a"
        done
}

_eww() {
    theme_name=$(cat $config_file | jq --raw-output '.theme')
    if [ -z "$theme_name" ]; then
        return
    fi

    color_dir=${XDG_CONFIG_HOME:-$HOME/.config}/eww/styles/themes
    color_file=$color_dir/$theme_name.scss

    ln -sf $color_file ${XDG_CONFIG_HOME:-$HOME/.config}/eww/styles/colors.scss
}

_nvim() {
    theme_name=$(cat $config_file | jq --raw-output '.theme')
    if [ -z "$theme_name" ]; then
        return
    fi

    runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
	for sock in "$runtime_dir"/nvim.*.0; do
		nvim --clean --headless --server "$sock" \
			--remote-send \
                "<Cmd>if get(g:, 'colors_name', '') !=# '$theme_name' |\
                    let g:_update_colorscheme=1                       |\
                    silent! colorscheme $theme_name                   |\
                endif<CR>" +'qa!' 2>/dev/null
	done
}

reloaders=""
while [ $# -gt 0 ]; do
    [ "$1" = "eww" ] && reloaders="_eww;$reloaders"
    [ "$1" = "foot" ] && reloaders="_foot;$reloaders"
    [ "$1" = "nvim" ] && reloaders="_nvim;$reloaders"

    shift
done

if [ -z "$reloaders" ]; then
    exit 0
fi

pid_file=$(mktemp /tmp/inotifywait_modify_pid.XXXXXXX) || exit 1
while true; do
    eval "$reloaders"

    inotifywait --quiet --event modify "$config_file" &

    # Copy inotifywait pid to stop if needed
    echo $! > $pid_file

    # Wait until modify event finish or be stopped
    while kill -0 $! 2>/dev/null; do
        sleep 1
    done
done &

# Watch changes on foot color file (symbolic link)
while true; do
    inotifywait --quiet --event delete_self "$config_file" | {
        # Kill old modify process
        kill -9 $(cat $pid_file) 2>/dev/null
    }
done &


case $reloaders in
    *foot*)
        exec "$SHELL"
        ;;
esac

