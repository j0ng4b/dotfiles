local config = function()
    require("mason").setup()
    require("mason-tool-installer").setup({
        ensure_installed = {
            -- Language servers
            "css-lsp",
            "tailwindcss-language-server",
            "typescript-language-server",
            "vue-language-server",

            "clangd",
            "jdtls",
            "omnisharp",
            "pyright",
            "qmlls",
            "lua-language-server",

            {
                "gopls",
                condition = function()
                    return vim.fn.executable("go") == 1
                end,
            },

            -- Formatters
            "prettier",
            "isort",
            "black",
            "stylua",

            -- Others
            "tree-sitter-cli",
        },
    })
end

return {
    "mason-org/mason.nvim",
    priority = 100,
    dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = config,
}
