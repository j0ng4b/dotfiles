return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    priority = 50,

    build = function()
        require("nvim-treesitter").update(nil, { summary = true })
    end,

    config = function()
        local missing_tools = vim.tbl_filter(function(tool)
            return vim.fn.executable(tool) == 0
        end, { "cc", "tree-sitter" })
        if #missing_tools > 0 then
            vim.notify("nvim-treesitter needs: " .. table.concat(missing_tools, ", "), vim.log.levels.WARN)
        end

        -- Installed when missing. Neovim already bundles some of them.
        require("nvim-treesitter").install({
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

            "razor",
            "c_sharp",

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

        vim.api.nvim_create_autocmd("FileType", {
            desc = "Enable Tree-sitter highlighting and indentation",
            group = vim.api.nvim_create_augroup("TreesitterSetup", {
                clear = true,
            }),

            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if not lang then
                    return
                end

                if not pcall(vim.treesitter.start, args.buf, lang) then
                    return
                end

                if vim.treesitter.query.get(lang, "indents") then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
