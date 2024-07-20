local status, bufferline = pcall(require, 'bufferline')
if not status then
    return
end

local icons = require('utils.icons')

_G.__cached_neo_tree_selector = nil
_G.__get_selector = function()
  return _G.__cached_neo_tree_selector
end

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
                raw = ' %{%v:lua.__get_selector()%} ',
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

