vim9script

#############################
####         XDG         ####
#############################

# Vim XDG directories
export const vim_config_home = (empty($XDG_CONFIG_HOME) ? '$HOME/.config' : $XDG_CONFIG_HOME) .. '/vim'
export const vim_cache_home = (empty($XDG_CACHE_HOME) ? '$HOME/.cache' : $XDG_CACHE_HOME) .. '/vim'
export const vim_state_home = (empty($XDG_STATE_HOME) ? '$HOME/.local/state' : $XDG_STATE_HOME) .. '/vim'
export const vim_data_home = (empty($XDG_DATA_HOME) ? '$HOME/.local/share' : $XDG_DATA_HOME) .. '/vim'

# Update runtime paths
if stridx(&runtimepath, vim_config_home) == -1
    &runtimepath = vim_config_home .. ',' .. &runtimepath
    &runtimepath = &runtimepath .. ',' .. vim_data_home
    &runtimepath = &runtimepath .. ',' .. vim_config_home .. '/after'
endif

# Update packages paths
if stridx(&packpath, vim_data_home) == -1
    &packpath = vim_data_home .. ',' .. &packpath
    &packpath = &packpath .. ',' .. vim_data_home .. '/after'
endif

