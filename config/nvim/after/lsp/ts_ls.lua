-- Vue setup, see:
--   https://github.com/vuejs/language-tools/wiki/Neovim
local vue_plugin = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

return {
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = vue_plugin,
                languages = { "vue" },
            },
        },
    },

    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },

    settings = {
        typescript = {
            tsserver = { useSyntaxServer = false },
        },
    },
}
