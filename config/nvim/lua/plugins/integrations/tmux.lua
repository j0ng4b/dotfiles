return {
    "christoomey/vim-tmux-navigator",
    cond = vim.fn.exists("$TMUX") == 1,
    config = function()
        vim.g.tmux_navigator_no_mappings = 1
        vim.g.tmux_navigator_preserve_zoom = 1

        local function map(lhs, rhs)
            vim.keymap.set({ "n" }, lhs, rhs, { silent = true })
        end

        map("<C-h>", "<Cmd>TmuxNavigateLeft<CR>")
        map("<C-j>", "<Cmd>TmuxNavigateDown<CR>")
        map("<C-k>", "<Cmd>TmuxNavigateUp<CR>")
        map("<C-l>", "<Cmd>TmuxNavigateRight<CR>")
    end,
}
