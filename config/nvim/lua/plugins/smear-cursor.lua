return {
    'sphamba/smear-cursor.nvim',
    cond = function()
        return not vim.g.neovide
    end,
    opts = {
        time_interval = 15,
        hide_target_hack = false,
        scroll_buffer_space = true,
        legacy_computing_symbols_support = false,

        stiffness = 0.7,
        trailing_stiffness = 0.4,
        trailing_exponent = 5,
        distance_stop_animating = 0.35,

        cursor_color = '#df6000',
        gamma = 2,
    },
}

