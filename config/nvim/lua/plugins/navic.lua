return {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        local icons = require("core.utils.icons")
        local navic = require("nvim-navic")

        navic.setup({
            icons = icons.kinds,
            click = true,
        })
    end,
}
