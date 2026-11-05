return {
    "folke/which-key.nvim",
    event = "VeryLazy",

    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "buffer local keymaps",
        },
    },

    opts = {
        preset = "modern",

        -- The popup only shows up when hesitate; marks, registers and
        -- spelling suggestions stay instant.
        delay = function(ctx)
            return ctx.plugin and 0 or 500
        end,

        triggers = {
            { "<auto>", mode = "nxso" },
        },

        -- Hide mappings that have no description.
        filter = function(mapping)
            return mapping.desc ~= nil and mapping.desc ~= ""
        end,

        win = {
            title = true,
            title_pos = "center",

            wo = { winblend = 30 },
            height = { min = 4, max = 10 },
        },

        layout = { align = "center" },

        icons = {
            group = "",
            rules = false,
        },

        plugins = {
            spelling = {
                enabled = true,
                suggestions = 10,
            },
        },

        show_keys = false,

        spec = {
            { "<Leader>h", group = "󰊢 Git" },
            { "<Leader>c", group = " Code" },
            { "<Leader>e", group = "󰉓 Explorer" },
            { "<Leader>f", group = "󰈙 File/find" },
            { "<Leader>d", group = "󰓙 Diagnostics" },
            { "<Leader>t", group = "󰙨 Test" },
            { "<Leader>b", group = "󰕷 Debug" },
            { "<Leader>q", group = "󰦛 Session" },
            { "<Leader>r", group = "󰖟 HTTP requests" },

            { "]", group = "next" },
            { "[", group = "prev" },
            { "g", group = "goto" },
            { "gs", group = "surround" },
            { "z", group = "fold" },
        },
    },
}
