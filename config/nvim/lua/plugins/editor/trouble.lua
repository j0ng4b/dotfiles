return {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = "Trouble",

    keys = {
        {
            "<Leader>dt",
            "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
            desc = "toggle diagnostics list (current buffer)",
        },

        {
            "<Leader>dT",
            "<Cmd>Trouble diagnostics toggle<CR>",
            desc = "toggle diagnostics list (workspace)",
        },
    },

    config = function()
        require("trouble").setup({
            auto_close = true,
            focus = true,

            warn_no_results = false,
            open_no_results = false,

            preview = {
                type = "float",
                relative = "editor",
                border = "rounded",
                title = "Preview",
                title_pos = "center",
                position = { 0, -2 },
                size = { width = 0.6, height = 0.6 },
                zindex = 200,

                wo = {
                    foldcolumn = "0",
                    signcolumn = "no",
                    statuscolumn = "",

                    number = false,
                    relativenumber = false,

                    cursorline = false,
                    cursorcolumn = false,

                    list = false,
                    winbar = "",
                },
            },
        })
    end,
}
