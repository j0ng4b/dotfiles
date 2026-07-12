return {
    "ibhagwan/fzf-lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local fzf = require("fzf-lua")
        fzf.setup()

        vim.keymap.set({ "n" }, "<leader>ff", fzf.files, {
            desc = "find file",
        })

        vim.keymap.set({ "n" }, "<leader>fg", fzf.live_grep, {
            desc = "search text in files",
        })

        vim.keymap.set({ "n" }, "<leader>fb", fzf.buffers, {
            desc = "find buffer",
        })

        vim.keymap.set({ "n" }, "<leader>fs", fzf.lgrep_curbuf, {
            desc = "search text on current file",
        })

        vim.keymap.set({ "n" }, "<leader>fo", fzf.lsp_document_symbols, {
            desc = "search for lsp symbols on current file",
        })

        vim.keymap.set({ "n" }, "<leader>fu", fzf.undotree, {
            desc = "undo history",
        })
    end,
}
