local config = function()
    local bufferline = require('bufferline')

    local icons = require('core.utils.icons')
    local buffer = require('core.utils.buffer')

    bufferline.setup({
        options = {
            themable = false,
            separator_style = 'slant',
            modified_icon = icons.file.modified,

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
        },
    })
end


return {
    'akinsho/bufferline.nvim',
    config = config,
    dependencies = 'nvim-tree/nvim-web-devicons',
}

