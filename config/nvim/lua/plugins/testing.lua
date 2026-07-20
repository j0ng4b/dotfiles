local ADAPTERS = {
    cs = { modules = { "neotest-dotnet" }, executable = "dotnet" },
    go = { modules = { "neotest-golang" }, executable = "go" },

    python = { modules = { "neotest-python" }, executable = "pytest" },

    vue = { modules = { "neotest-vitest", "neotest-jest" } },
    javascript = { modules = { "neotest-vitest", "neotest-jest" } },
    javascriptreact = { modules = { "neotest-vitest", "neotest-jest" } },
    typescript = { modules = { "neotest-vitest", "neotest-jest" } },
    typescriptreact = { modules = { "neotest-vitest", "neotest-jest" } },
}

local loaded = {}

local config = function()
    local neotest = require("neotest")

    neotest.setup({
        adapters = {},

        summary = {
            mappings = {
                jumpto = "<CR>",
                expand = { "<space>", "<right>", "<left>", "<2-LeftMouse>" },
            },
        },
    })

    vim.diagnostic.config({
        signs = false,
        virtual_text = {
            format = function(diagnostic)
                return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            end,
        },
    }, vim.api.nvim_create_namespace("neotest"))
end

--------------------------------------------------------------------
-- Load and register adapters for the current filetype only once
--------------------------------------------------------------------
local M = {}

local function load_module(module_name)
    if loaded[module_name] then
        return true
    end

    local ok, adapter = pcall(require, module_name)
    if not ok then
        vim.notify(("neotest: failed to load adapter '%s': %s"):format(module_name, adapter), vim.log.levels.ERROR)
        return false
    end

    table.insert(require("neotest.config").adapters, adapter)
    loaded[module_name] = true
    return true
end

local function with_adapter(callback)
    return function()
        if M.setup_adapters(vim.bo.filetype) then
            callback()
        end
    end
end

M.setup_adapters = function(filetype)
    local entry = ADAPTERS[filetype]
    if not entry then
        vim.notify(("neotest: no adapter configured for filetype '%s'"):format(filetype), vim.log.levels.INFO)
        return false
    end

    if entry.executable and vim.fn.executable(entry.executable) == 0 then
        vim.notify(
            ("neotest: '%s' not found on PATH; tests for %s cannot run"):format(entry.executable, filetype),
            vim.log.levels.WARN
        )
        return false
    end

    local any_loaded = false
    for _, module_name in ipairs(entry.modules) do
        if load_module(module_name) then
            any_loaded = true
        end
    end

    return any_loaded
end

return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },

        keys = {
            {
                "<Leader>tt",
                with_adapter(function()
                    require("neotest").run.run()
                end),
                desc = "run nearest test",
            },

            {
                "<Leader>tT",
                with_adapter(function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end),
                desc = "run tests on current file",
            },

            {
                "<Leader>tw",
                with_adapter(function()
                    require("neotest").watch.toggle()
                end),
                desc = "watch nearest test",
            },

            {
                "<Leader>tW",
                with_adapter(function()
                    require("neotest").watch.toggle(vim.fn.expand("%"))
                end),
                desc = "watch tests on current file",
            },

            {
                "<Leader>ts",
                function()
                    require("neotest").run.stop()
                end,
                desc = "stop running test",
            },

            {
                "<Leader>to",
                function()
                    require("neotest").output.open({ short = true, quiet = true, auto_close = true })
                end,
                desc = "show test output",
            },

            {
                "<Leader>tv",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "toggle test summary window",
            },
        },

        config = config,
    },

    { "nvim-neotest/neotest-python", lazy = true },
    { "fredrikaverpil/neotest-golang", lazy = true },
    { "nvim-neotest/neotest-jest", lazy = true },
    { "marilari88/neotest-vitest", lazy = true },
    { "Issafalcon/neotest-dotnet", lazy = true },
}
