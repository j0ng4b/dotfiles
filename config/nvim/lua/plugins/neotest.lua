local adapters = {}

local config = function()
    local neotest = require("neotest")
    local plugins = require("plugins.neotest")

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
        plugins.setup_adapter(vim.bo.filetype)
        neotest.run.run()
    end, { desc = "run nearest test" })

    vim.keymap.set({ "n" }, "<Leader>tT", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.run.run(vim.fn.expand("%"))
    end, { desc = "run tests on current file" })

    vim.keymap.set({ "n" }, "<Leader>ts", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.run.stop()
    end, { desc = "stop running test" })

    vim.keymap.set({ "n" }, "<Leader>to", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.output.open({
            short = true,
            quiet = true,
            auto_close = true,
        })
    end, { desc = "show test output" })

    vim.keymap.set({ "n" }, "<Leader>tv", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.summary.toggle()
    end, { desc = "toggle test summary window" })

    vim.keymap.set({ "n" }, "<Leader>tw", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.watch.toggle()
    end, { desc = "watch nearest test" })

    vim.keymap.set({ "n" }, "<Leader>tW", function()
        plugins.setup_adapter(vim.bo.filetype)
        neotest.watch.toggle(vim.fn.expand("%"))
    end, { desc = "watch tests on current file" })
end

M = {
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
        dependencies = "nvim-neotest/neotest",

        init = function()
            require("plugins.neotest").add_adapter("python", "neotest-python")
        end,

        config = function()
            table.insert(require("neotest.config").adapters, require("neotest-python"))
        end,
    },

    {
        "fredrikaverpil/neotest-golang",
        dependencies = "nvim-neotest/neotest",

        init = function()
            require("plugins.neotest").add_adapter("go", "neotest-golang")
        end,

        config = function()
            table.insert(require("neotest.config").adapters, require("neotest-golang"))
        end,
    },
}

M.add_adapter = function(filetype, adapter)
    adapters[filetype] = adapter
end

M.setup_adapter = function(filetype)
    if adapters[filetype] and not package.loaded[adapters[filetype]] then
        require(adapters[filetype])
    end
end

return M
