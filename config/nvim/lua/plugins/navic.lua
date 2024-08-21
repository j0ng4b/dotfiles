local config = function()
    local navic = require('nvim-navic')

    local icons = require('core.utils.icons')

    navic.setup({
        icons = icons.kinds,
        click = true,
    })
end


return {
    'SmiteshP/nvim-navic',
    config = config,
    dependencies = 'neovim/nvim-lspconfig',
}

