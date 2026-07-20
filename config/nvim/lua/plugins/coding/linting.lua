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
    "fstylelintrc",
    ".stylelintrc.json",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
}

local function linter_if_configured(linter, config_names)
    return function()
        local found = vim.fs.find(config_names, { upward = true, path = vim.fn.expand("%:p:h") })[1]
        return found and { linter } or {}
    end
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            python = { "ruff" },

            javascript = linter_if_configured("eslint_d", ESLINT_CONFIGS),
            javascriptreact = linter_if_configured("eslint_d", ESLINT_CONFIGS),
            typescript = linter_if_configured("eslint_d", ESLINT_CONFIGS),
            typescriptreact = linter_if_configured("eslint_d", ESLINT_CONFIGS),
            vue = linter_if_configured("eslint_d", ESLINT_CONFIGS),

            css = linter_if_configured("stylelint", STYLELINT_CONFIGS),
        }

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            callback = function()
                lint.try_lint()
            end,
            desc = "Run linter for the current filetype",
        })
    end,
}
