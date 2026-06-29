local config = function()
    require("colorizer").setup({
        filetypes = {
            "*",
            "!cmp_docs",
            "!cmp_menu",
        },

        options = {
            parsers = {
                css = true,
                sass = { enable = true },
                xterm = { enable = true },
                tailwind = { enable = true },
            },

            display = {
                mode = "virtualtext",
                virtualtext = {
                    char = "●",
                    position = "before",
                },
            },
        },
    })
end

return {
    "catgoose/nvim-colorizer.lua",
    config = config,
}