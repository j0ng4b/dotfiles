local function nt()
    return require("neotest")
end

-- All adapters are registered up front: each one only claims the projects it
-- recognizes (go.mod, pyproject.toml, *.csproj, package.json...).
local function adapters()
    return {
        require("neotest-python"),
        require("neotest-golang"),
        -- Name of the adapter registered in the DAP config (core of
        -- debugging/adapters/cs.lua).
        require("neotest-dotnet")({ dap = { adapter_name = "coreclr" } }),
        require("neotest-vitest"),
        require("neotest-jest"),
    }
end

return {
    "nvim-neotest/neotest",

    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",

        -- Adapters
        "nvim-neotest/neotest-python",
        "fredrikaverpil/neotest-golang",
        "Issafalcon/neotest-dotnet",
        "marilari88/neotest-vitest",
        "nvim-neotest/neotest-jest",
    },

    keys = {
        {
            "<Leader>tt",
            function()
                nt().run.run()
            end,
            desc = "run nearest test",
        },

        {
            "<Leader>tT",
            function()
                nt().run.run(vim.fn.expand("%"))
            end,
            desc = "run tests on current file",
        },

        {
            "<Leader>tl",
            function()
                nt().run.run_last()
            end,
            desc = "run last test",
        },

        {
            "<Leader>td",
            function()
                nt().run.run({ strategy = "dap" })
            end,
            desc = "debug nearest test",
        },

        {
            "<Leader>tw",
            function()
                nt().watch.toggle()
            end,
            desc = "watch nearest test",
        },

        {
            "<Leader>tW",
            function()
                nt().watch.toggle(vim.fn.expand("%"))
            end,
            desc = "watch tests on current file",
        },

        {
            "<Leader>ts",
            function()
                nt().run.stop()
            end,
            desc = "stop running test",
        },

        {
            "<Leader>to",
            function()
                nt().output.open({ short = true, quiet = true, auto_close = true })
            end,
            desc = "show test output",
        },

        {
            "<Leader>tO",
            function()
                nt().output_panel.toggle()
            end,
            desc = "toggle test output panel",
        },

        {
            "<Leader>tv",
            function()
                nt().summary.toggle()
            end,
            desc = "toggle test summary window",
        },
    },

    config = function()
        nt().setup({
            adapters = adapters(),

            summary = {
                mappings = {
                    jumpto = "<CR>",
                    expand = {
                        "<space>", "<right>", "<left>", "<2-LeftMouse>" },
                },
            },
        })

        -- Single-line test failure messages as virtual text.
        vim.diagnostic.config({
            signs = false,
            virtual_text = {
                format = function(diagnostic)
                    return vim.trim((diagnostic.message:gsub("%s+", " ")))
                end,
            },
        }, vim.api.nvim_create_namespace("neotest"))
    end,
}
