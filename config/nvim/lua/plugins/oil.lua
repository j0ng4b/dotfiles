return {
    "stevearc/oil.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",

    keys = {
        {
            "<leader>eo",
            function()
                require("oil").toggle_float()
            end,
            desc = "Open oil in floating window",
        },
    },

    config = function()
        local oil = require("oil")

        oil.setup({
            watch_for_changes = true,
            default_file_explorer = false,
            skip_confirm_for_simple_edits = true,

            columns = {
                "icon",
                "size",
            },

            view_options = {
                show_hidden = true,
                natural_order = true,

                is_always_hidden = function(name, _)
                    return name == ".." or name == ".git"
                end,
            },

            float = {
                padding = 2,

                max_width = 0.7,
                max_height = 0.6,

                border = "solid",

                win_options = {
                    wrap = true,
                    number = false,
                    relativenumber = false,
                },
            },

            use_default_keymaps = false,
            keymaps = {
                ["g?"] = { "actions.show_help", mode = "n" },
                ["g."] = { "actions.toggle_hidden", mode = "n" },

                ["h"] = "actions.parent",
                ["<BS>"] = { "actions.parent", mode = "n" },

                ["s"] = { "actions.select", opts = { horizontal = true } },
                ["S"] = { "actions.select", opts = { vertical = true } },
                ["<CR>"] = "actions.select",

                ["q"] = "actions.close",
                ["<Esc>"] = "actions.close",
                ["<C-c>"] = "actions.close",
            },
        })
    end,
}
