-- Avoids an error on every save when the project is configured but the tool
-- isn't installed.
---@param name string
---@return boolean
local function is_available(name)
    local linter = require("lint").linters[name]
    if not linter then
        return false
    end

    local cmd = linter.cmd
    if type(cmd) == "function" then
        cmd = cmd()
    end

    return vim.fn.executable(cmd or name) == 1
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")
        local tools = require("plugins.utils.tools")

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
            desc = "Run the linters the project configures",
            callback = function(args)
                local names = tools.resolve("lint", args.buf, is_available)
                if #names > 0 then
                    vim.api.nvim_buf_call(args.buf, function()
                        lint.try_lint(names)
                    end)
                end
            end,
        })
    end,
}
