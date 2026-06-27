## Aliases
for alias in $ZDOTDIR/aliases/*; do
    source $alias
done


## Completion
for completion in $ZDOTDIR/completions/*; do
    source $completion
done


## Utilities
for utility in $ZDOTDIR/utils/*; do
    source $utility
done


## History
mkdir -p $ZDATADIR


## Options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CD_SILENT
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE

setopt NO_CASE_GLOB
setopt EXTENDED_GLOB
setopt GLOB_DOTS

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY_TIME

setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

setopt SH_WORD_SPLIT


## Binds
bindkey -v

## Plugins
# The (N-/on) modifier ensures it only matches directories (/),
# fails silently if empty (N), and explicitly orders by name (on)
for plugin_dir in $ZDATADIR/plugins/*(N-/on); do
    dir_name=${plugin_dir:t}

    # Ignore directories starting with '_' (data-only plugins or disabled)
    if [[ "$dir_name" == _* ]]; then
        continue
    fi

    plugin_name=${dir_name#*-}

    plugin_pre_conf="$ZDOTDIR/plugins.conf.d/pre/$plugin_name.conf.zsh"
    plugin_post_conf="$ZDOTDIR/plugins.conf.d/post/$plugin_name.conf.zsh"

    plugin_path=( "$plugin_dir"/($plugin_name.plugin.zsh|init.zsh|$plugin_name.zsh)(N-.) )
    plugin_path=$plugin_path[1]

    if [[ -z "$plugin_path" ]]; then
        echo "failed to load plugin: no entry file found in '$plugin_dir'"
        continue
    fi

    SKIP_PLUGIN=0

    # Load plugin pre-configuration
    if [[ -f "$plugin_pre_conf" ]]; then
        source "$plugin_pre_conf"
    fi

    if (( SKIP_PLUGIN )); then
        continue
    fi

    # Automatic zcompile: if the .zwc file is missing or older than the .zsh file, recompile it
    if [[ ! -f "${plugin_path}.zwc" || "$plugin_path" -nt "${plugin_path}.zwc" ]]; then
        zcompile "$plugin_path"
    fi

    # Load the actual plugin
    source "$plugin_path"

    # Load plugin post-configuration
    if [[ -f "$plugin_post_conf" ]]; then
        source "$plugin_post_conf"
    fi
done

# Prompt reload on SIGUSR1
TRAPUSR1() {
    if [[ -n $ZLE ]]; then
        # If in zle (line editor), reset the prompt
        zle .reset-prompt
    else
        # If not in an interactive editing session, just output a newline
        echo ""
    fi
}
