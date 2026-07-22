local ESLINT_CONFIGS = {
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yaml",
    ".eslintrc.yml",

    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
}

local STYLELINT_CONFIGS = {
    ".stylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
}

local LINTERS = {
    python = {
        names = { "ruff" },
    },

    javascript = {
        names = { "eslint_d" },
        configs = ESLINT_CONFIGS,
    },

    javascriptreact = {
        names = { "eslint_d" },
        configs = ESLINT_CONFIGS,
    },

    typescript = {
        names = { "eslint_d" },
        configs = ESLINT_CONFIGS,
    },

    typescriptreact = {
        names = { "eslint_d" },
        configs = ESLINT_CONFIGS,
    },

    vue = {
        names = { "eslint_d" },
        configs = ESLINT_CONFIGS,
    },

    css = {
        names = { "stylelint" },
        configs = STYLELINT_CONFIGS,
    },
}

local function has_config(bufnr, config_names)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return false
    end

    return vim.fs.find(config_names, {
        path = vim.fs.dirname(filename),
        upward = true,
        type = "file",
    })[1] ~= nil
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            callback = function(args)
                local filetype = vim.bo[args.buf].filetype

                local entry = LINTERS[filetype]
                if not entry then
                    return
                end

                if entry.configs and not has_config(args.buf, entry.configs) then
                    return
                end

                lint.try_lint(entry.names)
            end,
            desc = "Run configured linters for the current file",
        })
    end,
}
