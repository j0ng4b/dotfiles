# Enable Powerlevel10k instant prompt
if [ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]; then
    source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#################
##   ALIASES   ##
#################
for alias in $ZDOTDIR/aliases/*; do
    source $alias
done


#################
## COMPLETION  ##
#################
source $ZDOTDIR/completion.zsh


#################
##  UTILITIES  ##
#################
for utility in $ZDOTDIR/utils/*; do
    source $utility
done


#################
##   PLUGINS   ##
#################
while IFS=" " read -r plugin; do
    # Load plugin if exists
    if [ -f "$ZDATADIR/plugins/$plugin" ]; then
        source "$ZDATADIR/plugins/$plugin"

        # Load plugin configuration if any
        plugin_conf="$(dirname $plugin).zsh"
        if [ -f "$ZDOTDIR/plugins.conf.d/$plugin_conf" ]; then
            source "$ZDOTDIR/plugins.conf.d/$plugin_conf"
        fi
    fi
done <<-EOF
    powerlevel10k/powerlevel10k.zsh-theme
    zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF


#################
##   HISTORY   ##
#################
mkdir -p $ZDATADIR


#################
##   OPTIONS   ##
#################
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CD_SILENT
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

setopt COMPLETE_ALIASES
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

