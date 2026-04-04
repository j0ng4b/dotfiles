local config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup({
        signs = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
            untracked = { text = "┆" },
        },

        signs_staged = {
            add = { text = "┃" },
            change = { text = "┃" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
        },

        signs_staged_enable = false,
        on_attach = function()
            -- Navigation
            vim.keymap.set({ "n" }, "<Leader>hn", function()
                gitsigns.nav_hunk("next")
            end, {
                desc = "jump to next hunk",
            })

            vim.keymap.set({ "n" }, "<Leader>hp", function()
                gitsigns.nav_hunk("prev")
            end, {
                desc = "jump to previous hunk",
            })

            -- Actions
            vim.keymap.set({ "n" }, "<leader>hS", gitsigns.stage_buffer, {
                desc = "stage all hunks on buffer",
            })

            vim.keymap.set({ "n", "v" }, "<leader>hs", function()
                local range = nil
                local mode = vim.api.nvim_get_mode().mode

                if mode == "v" or mode == "V" or mode == "<C-v>" then
                    range = {
                        vim.fn.getpos("v")[2],
                        vim.fn.getpos(".")[2],
                    }
                end

                gitsigns.stage_hunk(range)
            end, {
                desc = "stage lines of the hunk at cursor position",
            })

            vim.keymap.set({ "n" }, "<leader>hR", function()
                local range = nil
                local mode = vim.api.nvim_get_mode().mode

                if mode == "v" or mode == "V" or mode == "<C-v>" then
                    range = {
                        vim.fn.getpos("v")[2],
                        vim.fn.getpos(".")[2],
                    }
                end

                gitsigns.reset_buffer(range)
            end, {
                desc = "reset the lines of all hunks on buffer",
            })

            vim.keymap.set({ "n", "v" }, "<leader>hr", gitsigns.reset_hunk, {
                desc = "reset the lines of the hunk",
            })

            vim.keymap.set({ "n" }, "<leader>hv", gitsigns.preview_hunk, {
                desc = "preview hunk at cursor position",
            })

            vim.keymap.set({ "n" }, "<leader>hb", gitsigns.blame_line, {
                desc = "show line last modification revision and author",
            })
        end,
    })
end

return {
    "lewis6991/gitsigns.nvim",
    config = config,
}
