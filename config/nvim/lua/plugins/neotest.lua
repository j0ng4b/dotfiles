local M = {}

local adapters = {}
local loaded = {}

local config = function()
    local neotest = require("neotest")

    neotest.setup({
        adapters = {},
        summary = {
            mappings = {
                expand = { "<space>", "<right>", "<left>", "<2-LeftMouse>" },
                jumpto = "<CR>",
            },
        },
    })

    vim.diagnostic.config({
        signs = false,
        virtual_text = {
            format = function(diagnostic)
                local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                return message
            end,
        },
    }, vim.api.nvim_create_namespace("neotest"))

    -- setup keymaps
    vim.keymap.set({ "n" }, "<Leader>tt", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.run.run()
    end, { desc = "run nearest test" })

    vim.keymap.set({ "n" }, "<Leader>tT", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.run.run(vim.fn.expand("%"))
    end, { desc = "run tests on current file" })

    vim.keymap.set({ "n" }, "<Leader>ts", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.run.stop()
    end, { desc = "stop running test" })

    vim.keymap.set({ "n" }, "<Leader>to", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.output.open({
            short = true,
            quiet = true,
            auto_close = true,
        })
    end, { desc = "show test output" })

    vim.keymap.set({ "n" }, "<Leader>tv", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.summary.toggle()
    end, { desc = "toggle test summary window" })

    vim.keymap.set({ "n" }, "<Leader>tw", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.watch.toggle()
    end, { desc = "watch nearest test" })

    vim.keymap.set({ "n" }, "<Leader>tW", function()
        M.setup_adapter(vim.bo.filetype)
        neotest.watch.toggle(vim.fn.expand("%"))
    end, { desc = "watch tests on current file" })
end

M.plugins = {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = config,
    },

    -- Adapters
    {
        "nvim-neotest/neotest-python",
        lazy = true,
        init = function()
            if vim.fn.executable("pytest") == 1 then
                M.add_adapter("python", "neotest-python")
            end
        end,
    },

    {
        "fredrikaverpil/neotest-golang",
        lazy = true,
        init = function()
            if vim.fn.executable("go") == 1 then
                M.add_adapter("go", "neotest-golang")
            end
        end,
    },
}

M.add_adapter = function(filetype, module)
    adapters[filetype] = module
end

M.setup_adapter = function(filetype)
    if loaded[filetype] then
        return
    end

    local module = adapters[filetype]
    if not module then
        return
    end

    local ok, adapter = pcall(require, module)
    if not ok then
        return
    end

    table.insert(require("neotest.config").adapters, adapter)
    loaded[filetype] = true
end

return M.plugins
