#################
##   ALIASES   ##
#################
for alias in $ZDOTDIR/aliases/*; do
    . $alias
done

#################
## COMPLETION  ##
#################
. $ZDOTDIR/completion.sh

#################
##   HISTORY   ##
#################
histdir="$(dirname $HISTFILE)"
if [ -n "$histdir" -a ! -d "$histdir" ]; then
    mkdir -p "$histdir"
fi

#################
##   OPTIONS   ##
#################
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

