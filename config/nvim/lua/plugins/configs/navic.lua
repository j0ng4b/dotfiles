local status, navic = pcall(require, 'nvim-navic')
if not status then
    return
end

local icons = require('utils.icons')

navic.setup({
    icons = icons.kinds,
    click = true,
})

