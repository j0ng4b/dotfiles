return {
    "christoomey/vim-tmux-navigator",
    config = function()
        vim.g.tmux_navigator_no_mappings = 1
        vim.g.tmux_navigator_preserve_zoom = 1

        if vim.fn.exists("$TMUX") then
            vim.keymap.set({ "n" }, "<C-h>", "<Cmd>TmuxNavigateLeft<CR>") -- left
            vim.keymap.set({ "n" }, "<C-j>", "<Cmd>TmuxNavigateDown<CR>") -- bottom
            vim.keymap.set({ "n" }, "<C-k>", "<Cmd>TmuxNavigateUp<CR>") -- top
            vim.keymap.set({ "n" }, "<C-l>", "<Cmd>TmuxNavigateRight<CR>") -- right
        end
    end,
}
