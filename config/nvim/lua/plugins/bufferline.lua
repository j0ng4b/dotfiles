local config = function()
    local bufferline = require('bufferline')

    local icons = require('core.utils.icons')
    local buffer = require('core.utils.buffer')

    bufferline.setup({
        options = {
            themable = false,
            separator_style = 'slant',
            modified_icon = icons.file.modified,
            sort_by = 'directory',

            close_command = function(bufnr) buffer.close(bufnr) end,
            right_mouse_command = function(bufnr) buffer.close(bufnr) end,

            offsets = {
                {
                    filetype = 'neo-tree',
                    text = 'Explore',
                    text_align = 'center',
                    separator = false,
                }
            },

            hover = {
                enabled = true,
                delay = 100,
                reveal = { 'close' },
            },

            groups = {
                options = {
                    toggle_hidden_on_enter = false,
                },

                items = {
                    {
                        name = 'Terminal',
                        auto_close = true,
                        matcher = function(buf)
                            return buf.buftype == 'terminal'
                        end,
                    },
                },
            },

            custom_filter = function(buf_number, buf_numbers)
                if vim.bo[buf_number].filetype == 'qf'
                    or vim.bo[buf_number].buftype == 'quickfix' then
                    return false
                elseif vim.bo[buf_number].filetype == 'codecompanion' then
                    return false
                end

                return true
            end,
        },
    })
end


return {
    'akinsho/bufferline.nvim',
    config = config,
    dependencies = 'nvim-tree/nvim-web-devicons',
}

