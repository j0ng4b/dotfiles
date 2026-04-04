local config = function()
    require("nvim-navic").setup({
        icons = require("core.utils.icons").kinds,
        click = true,
    })
end

return {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig",
    config = config,
}
