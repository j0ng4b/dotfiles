return {
    'wfxr/minimap.vim',
    enabled = false,
    init = function()
        vim.g.minimap_width = 20

        -- Git highlight
        vim.g.minimap_git_colors = 1

        -- Range highlight
        vim.g.minimap_highlight_range = 1

        -- Search highlight
        vim.g.minimap_highlight_search = 1

        vim.g.minimap_auto_start = 1
        vim.g.minimap_auto_start_win_enter = 1
        vim.g.minimap_background_processing = 1

        vim.g.minimap_close_filetypes = {
            'alpha',
            'neo-tree',
            'codecompanion',
        }
    end
}

