return {
    'christoomey/vim-tmux-navigator',

    cmd = {
        'TmuxNavigateLeft',
        'TmuxNavigateDown',
        'TmuxNavigateUp',
        'TmuxNavigateRight',
        'TmuxNavigatePrevious',
    },

    event = function()
        if vim.fn.exists('$TMUX') == 1 then
            return 'VeryLazy'
        end
    end,

    init = function()
        vim.g.tmux_navigator_no_mappings = 1
        vim.g.tmux_navigator_preserve_zoom = 1
    end
}

