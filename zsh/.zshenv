###
### XDG base directories
###
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

export PATH="${PATH}:${HOME}/.local/bin"

###
### Zsh
###
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

export HISTFILE="${XDG_STATE_HOME}/zsh/zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

export ZLE_RPROMPT_INDENT=0

###
### VIM
###
export VIMINIT="set nocompatible | source ${XDG_CONFIG_HOME}/vim/vimrc"

###
### Editors
###
export VISUAL=vim
export EDITOR=vim

