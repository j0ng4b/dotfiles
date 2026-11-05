return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local bufferline = require("bufferline")
        local groups = require("bufferline.groups")

        local icons = require("core.utils.icons")
        local buffer = require("core.utils.buffer")

        bufferline.setup({
            options = {
                themable = true,
                separator_style = "slant",

                sort_by = "directory",
                modified_icon = icons.file.modified,

                show_buffer_close_icons = false,

                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "NeoTree",
                        text_align = "center",
                        separator = false,
                    },
                },

                hover = {
                    enabled = true,
                    delay = 500,
                    reveal = { "close" },
                },

                groups = {
                    options = {
                        toggle_hidden_on_enter = false,
                    },

                    items = {
                        groups.builtin.ungrouped,

                        {
                            name = "Terminal",
                            auto_close = true,
                            matcher = function(buf)
                                return buf.buftype == "terminal"
                            end,
                        },
                    },
                },

                close_command = function(bufnr)
                    buffer.close(bufnr)
                end,

                right_mouse_command = function(bufnr)
                    buffer.close(bufnr)
                end,

                custom_filter = function(buf_number)
                    if vim.bo[buf_number].filetype == "qf" or vim.bo[buf_number].buftype == "quickfix" then
                        return false
                    end

                    return true
                end,
            },
        })
    end,
}
