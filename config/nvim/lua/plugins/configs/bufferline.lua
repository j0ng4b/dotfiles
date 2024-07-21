local status, bufferline = pcall(require, 'bufferline')
if not status then
    return
end

local icons = require('utils.icons')
local buffer = require('utils.buffer')

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

