local function get_installed_parsers()
    local parser_filepaths = vim.api.nvim_get_runtime_file("parser/*.*", true)

    local installed_parsers = {}
    for _, filepath in ipairs(parser_filepaths) do
        local parser = string.match(filepath, ".*[/\\]([^/\\]+)%.%w+$")

        if not (vim.list_contains(installed_parsers, parser)) then
            table.insert(installed_parsers, parser)
        end
    end

    return installed_parsers
end

return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    priority = 100,
    build = function()
        require("nvim-treesitter").update(nil, { summary = true })
    end,
    config = function()
        if vim.fn.executable("cc") == 0 or vim.fn.executable("make") == 0 or vim.fn.executable("tree-sitter") == 0 then
            vim.notify("Install a C compiler, Make and tree-sitter cli to proper use treesitter!", vim.log.levels.WARN)
        end

        local treesitter = require("nvim-treesitter")
        treesitter.install({
            "c",
            "cpp",
            "cmake",
            "make",

            "zsh",
            "bash",

            "html",
            "tsx",
            "jsx",
            "vue",
            "css",
            "javascript",
            "typescript",

            "go",
            "java",

            "jinja",
            "python",

            "dockerfile",
            "yaml",

            "json",
            "json5",

            "lua",
            "vim",
            "vimdoc",
        })

        local auto = require("core.utils.autocmd")
        auto.cmd(
            "FileType",
            vim.iter(get_installed_parsers()):map(vim.treesitter.language.get_filetypes):flatten():totable(),
            function(args)
                -- enable highlight
                local lang = vim.treesitter.language.get_lang(args.match)
                vim.treesitter.start(args.buf, lang)

                -- enable indentation
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        )
    end,
}
