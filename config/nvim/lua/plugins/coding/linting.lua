local file = require("core.utils.file")

--- True when `name` (a file found walking up from the buffer) is `filename` and
--- contains `text`.
---
---@param dir string
---@param name string
---@param filename string
---@param text string
---
---@return boolean
local function contains(dir, name, filename, text)
    if name ~= filename then
        return false
    end

    local content = file.read(dir .. "/" .. name)
    return content ~= nil and content:find(text, 1, true) ~= nil
end

-- A linter only runs in projects that configure it. Each check receives a file
-- name (and its directory) found while walking up from the buffer.
local configured = {
    eslint = function(name)
        return vim.startswith(name, ".eslintrc") or vim.startswith(name, "eslint.config.")
    end,

    oxlint = function(name)
        return vim.startswith(name, ".oxlintrc") or vim.startswith(name, "oxlint.config.")
    end,

    stylelint = function(name)
        return vim.startswith(name, ".stylelintrc") or vim.startswith(name, "stylelint.config.")
    end,

    ruff = function(name, dir)
        return name == "ruff.toml" or name == ".ruff.toml" or contains(dir, name, "pyproject.toml", "[tool.ruff")
    end,

    flake8 = function(name, dir)
        return name == ".flake8"
            or contains(dir, name, "setup.cfg", "[flake8]")
            or contains(dir, name, "tox.ini", "[flake8]")
    end,

    djlint = function(name, dir)
        return name == ".djlintrc" or contains(dir, name, "pyproject.toml", "[tool.djlint")
    end,
}

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        local js = { "eslint", "oxlint" }
        lint.linters_by_ft = {
            javascript = js,
            javascriptreact = js,
            typescript = js,
            typescriptreact = js,
            vue = js,
            css = { "stylelint" },
            scss = { "stylelint" },
            htmldjango = { "djlint" },
            jinja = { "djlint" },
            python = { "ruff", "flake8" },
        }

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            desc = "Run the linters the project configures",
            callback = function(args)
                local path = vim.api.nvim_buf_get_name(args.buf)
                if path == "" then
                    return
                end

                local names = vim.tbl_filter(function(name)
                    local check = configured[name]
                    return check ~= nil and vim.fs.root(path, check) ~= nil
                end, lint.linters_by_ft[vim.bo[args.buf].filetype] or {})

                if #names > 0 then
                    vim.api.nvim_buf_call(args.buf, function()
                        lint.try_lint(names)
                    end)
                end
            end,
        })
    end,
}
