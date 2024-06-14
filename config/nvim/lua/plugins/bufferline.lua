local status, bufferline = pcall(require, 'bufferline')
if not status then
    return
end

_G.__cached_neo_tree_selector = nil
_G.__get_selector = function()
  return _G.__cached_neo_tree_selector
end

bufferline.setup({
    options = {
        themable = false,
        separator_style = 'slant',

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

        -- highlights = require('catppuccin.groups.integrations.bufferline').get()
    },
})

