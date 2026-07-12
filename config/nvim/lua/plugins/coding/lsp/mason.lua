local config = function()
    require("mason").setup()
    require("mason-tool-installer").setup({
        ensure_installed = {
            -- Language servers
            "css-lsp",
            "html-lsp",
            "tailwindcss-language-server",
            "typescript-language-server",
            "vue-language-server",
            "emmet-language-server",

            "clangd",
            "jdtls",
            "pyright",
            "lua-language-server",

            {
                "omnisharp",
                condition = function()
                    return vim.fn.executable("dotnet") == 1
                end,
            },

            {
                "qmlls",
                condition = function()
                    return vim.fn.executable("quickshell") == 1
                end,
            },

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
