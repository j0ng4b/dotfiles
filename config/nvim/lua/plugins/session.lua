return {
    "folke/persistence.nvim",
    event = "VimEnter",
    config = function()
        local persistence = require("persistence")
        persistence.setup()

        -- Auto load session on startup
        if vim.fn.argc() == 0 then
            persistence.load()
        end

        vim.opt.sessionoptions = {
            "buffers",
            "curdir",
            "folds",
            "localoptions",
            "skiprtp",
            "tabpages",
            "terminal",
            "winsize",
            "winpos",
        }

        vim.keymap.set("n", "<leader>qs", function()
            persistence.load()
        end, { desc = "load session for current directory" })

        vim.keymap.set("n", "<leader>qS", function()
            persistence.select()
        end, { desc = "select a session to load" })

        vim.keymap.set("n", "<leader>ql", function()
            persistence.load({ last = true })
        end, { desc = "load the last session" })

        vim.keymap.set("n", "<leader>qd", function()
            persistence.stop()
        end, { desc = "stop session saving" })

        -- Setup auto save
        vim.api.nvim_create_autocmd({
            "BufReadPost",
            "BufDelete",

            "WinNew",
            "WinClosed",

            "FocusLost",
        }, {
            desc = "save Neovim session state",
            callback = function()
                vim.schedule(function()
                    persistence.save()
                end)
            end,
        })
    end,
}
