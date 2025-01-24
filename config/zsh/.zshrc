## Aliases
for alias in $ZDOTDIR/aliases/*; do
    source $alias
done


## Completion
source $ZDOTDIR/completion.zsh


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

# Enable history substring search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down


## Plugins
plugins="$(ls -d $ZDATADIR/plugins/*)"

for plugin in $plugins; do
    plugin_name="$(basename $plugin | cut -d'-' -f2-)"
    plugin_path="$plugin/$plugin_name.plugin.zsh"

    if [ ! -e "$plugin_path" ]; then
        continue
    fi

    plugin_pre_conf="$ZDOTDIR/plugins.conf.d/pre/$plugin_name.conf.zsh"
    plugin_post_conf="$ZDOTDIR/plugins.conf.d/post/$plugin_name.conf.zsh"

    if [ -f $plugin_path ]; then
        # load plugin pre configuration
        if [ -f $plugin_pre_conf ]; then
            source "$plugin_pre_conf"
        fi

        # load plugin
        source "$plugin_path"

        # load plugin post configuration
        if [ -f $plugin_post_conf ]; then
            source "$plugin_post_conf"
        fi
    else
        echo "failed to load plugin: can't find '$plugin_path'"
    fi
done


## Start starship
if command -v starship; then
    eval "$(starship init zsh)"
fi

