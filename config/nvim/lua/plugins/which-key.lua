return {
    src = "folke/which-key.nvim",
    config = function()
        local wk = require("which-key")
        wk.setup({
            preset = "helix",

            triggers = {
                { "<auto>", mode = "nixsotc" },
            },

            filter = function(mapping)
                return mapping.desc and mapping.desc ~= ""
            end,

            win = {
                height = { min = 4, max = 10 },

                title = true,
                title_pos = "center",

                wo = {
                    winblend = 60,
                },
            },

            layout = {
                align = "center",
            },

            icons = {
                group = "",
                rules = false,
            },

            plugins = {
                spelling = {
                    suggestions = 10,
                },
            },

            show_keys = false,
        })

        wk.add({
            {
                "<Leader>h",
                group = "󰊢 Git",
            },

            {
                "<leader>e",
                group = "󰉓 Explorer",
            },

            {
                "<leader>d",
                group = "󰓙 Diagnostics",
            },
        })

        vim.keymap.set({ "n" }, "<leader>?", function()
            wk.show({ global = false })
        end, { desc = "Buffer local keymaps" })
    end,
}
