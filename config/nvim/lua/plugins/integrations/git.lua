return {
    "lewis6991/gitsigns.nvim",
    config = function()
        local gitsigns = require("gitsigns")
        gitsigns.setup({
            signs_staged_enable = false,

            signs = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "▁" },
                topdelete = { text = "▔" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },

            preview_config = {
                border = "rounded",
            },

            on_attach = function(buffer)
                local function map(modes, lhs, rhs, desc)
                    vim.keymap.set(modes, lhs, rhs, {
                        buffer = buffer,
                        silent = true,
                        desc = desc,
                    })
                end

                -- Navigation
                map({ "n" }, "<Leader>hn", function()
                    gitsigns.nav_hunk("next")
                end, "jump to next hunk")

                map({ "n" }, "<Leader>hp", function()
                    gitsigns.nav_hunk("prev")
                end, "jump to previous hunk")

                -- Stage hunk
                map({ "n" }, "<Leader>hS", gitsigns.stage_buffer, "stage all hunk on buffer")
                map({ "n", "x" }, "<Leader>hs", function()
                    local mode = vim.api.nvim_get_mode().mode
                    local range = nil

                    if mode == "v" or mode == "V" or mode == "<C-v>" then
                        range = {
                            vim.fn.getpos("v")[2],
                            vim.fn.getpos(".")[2],
                        }
                    end

                    gitsigns.stage_hunk(range)
                end, "stage lines of the hunk")

                -- Reset hunk
                map({ "n" }, "<Leader>hR", gitsigns.reset_buffer, "reset the lines of all hunks on buffer")
                map({ "n", "x" }, "<Leader>hr", function()
                    local mode = vim.api.nvim_get_mode().mode
                    local range = nil

                    if mode == "v" or mode == "V" or mode == "<C-v>" then
                        range = {
                            vim.fn.getpos("v")[2],
                            vim.fn.getpos(".")[2],
                        }
                    end

                    gitsigns.reset_hunk(range)
                end, "reset the lines of the hunk")

                -- Preview
                map({ "n" }, "<Leader>hv", gitsigns.preview_hunk, "preview hunk at cursor position")

                -- Blame
                map({ "n" }, "<Leader>hB", gitsigns.blame, "show last modification version and author on current file")
                map({ "n" }, "<Leader>hb", gitsigns.blame_line, "show line last modification revision and author")
            end,
        })
    end,
}
