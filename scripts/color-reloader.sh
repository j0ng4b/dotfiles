#!/usr/bin/env sh

# TODO: block multiple script spawn

config_file=${XDG_CONFIG_HOME:-$HOME/.config}/system-configs.json

__generate_colors_file() {
    template_name=$1
    output_path=$2
    theme_name=$(cat $config_file | jq --raw-output '.theme')

    if [ ! -e "$root/themes/templates/$template_name" ]; then
        warn "no template found for $template_name"
        return
    fi

    if [ -z "$theme_name" ]; then
        error "theme file not found: $theme_name"
        return
    fi

    # Load theme colors
    . "$root/themes/$theme_name"

    # Generate color file
    cp --force "$root/themes/templates/$template_name" $output_path
    for color_name in base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F; do
        eval "sed -i -e "s/{$color_name}/\${$color_name}/" "$output_path""
    done
}

_foot_reloader() {
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/foot"
    colors_output_path="$config_dir/colors.ini"

    __generate_colors_file foot $colors_output_path

    # Update normal colors
    sed -nr 's/.*(regular|bright)([0-9])\s*=\s*([a-zA-Z0-9]{6}).*/\1 \2 \3/p' "$colors_output_path" |
        while read type num color; do
            [ "$type" = "bright" ] && num=$(($num + 8))
            printf "\033]4;$num;#$color\a"
        done

    # Update foreground color
    sed -nr 's/.*foreground\s*=\s*([a-zA-Z0-9]{6}).*/\1/p' "$colors_output_path" |
        while read color; do
            printf "\033]10;#$color\a"
        done

    # Update background color
    sed -nr 's/.*background\s*=\s*([a-zA-Z0-9]{6}).*/\1/p' "$colors_output_path" |
        while read color; do
            printf "\033]11;#$color\a"
        done
}

_cava_reloader() {
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/cava"
    colors_output_path="$config_dir/config"

    if [ ! -e "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi

    __generate_colors_file cava $colors_output_path
    pkill -USR1 cava
}

_eww_reloader() {
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/eww"
    colors_output_path="$config_dir/styles/colors.scss"

    __generate_colors_file eww $colors_output_path

    # NOTE: eww automatically reloads colors
}

_nvim_reloader() {
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

_tmux_reloader() {
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
    colors_output_path="$config_dir/colors.tmux"

    __generate_colors_file tmux $colors_output_path
    tmux source-file "$config_dir/tmux.conf"
}

_wm_reloader() {
    :
}

reloaders=""
reloaders_files=""
while [ $# -gt 0 ]; do
    [ "$1" = "eww" ] && reloaders="_eww_reloader;$reloaders"
    [ "$1" = "foot" ] && reloaders="_foot_reloader;$reloaders"
    [ "$1" = "cava" ] && reloaders="_cava_reloader;$reloaders"
    [ "$1" = "nvim" ] && reloaders="_nvim_reloader;$reloaders"
    [ "$1" = "tmux" ] && reloaders="_tmux_reloader;$reloaders"
    [ "$1" = "wm" ] && reloaders="_wm_reloader;$reloaders"

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

