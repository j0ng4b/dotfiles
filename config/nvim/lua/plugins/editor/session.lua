return {
    "folke/persistence.nvim",
    event = "VimEnter",
    config = function()
        local autosave_enabled = true

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

        vim.keymap.set("n", "<leader>qw", function()
            persistence.save()
        end, {
            desc = "save current session",
        })

        vim.keymap.set("n", "<leader>qs", function()
            autosave_enabled = true
            persistence.load()
        end, { desc = "load session for current directory" })

        vim.keymap.set("n", "<leader>qS", function()
            autosave_enabled = true
            persistence.select()
        end, { desc = "select a session to load" })

        vim.keymap.set("n", "<leader>ql", function()
            autosave_enabled = true
            persistence.load({ last = true })
        end, { desc = "load the last session" })

        vim.keymap.set("n", "<leader>qd", function()
            autosave_enabled = false
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
            group = vim.api.nvim_create_augroup("PersistenceAutosave", {
                clear = true,
            }),
            callback = function()
                if not autosave_enabled then
                    return
                end

                vim.schedule(function()
                    if autosave_enabled then
                        persistence.save()
                    end
                end)
            end,
            desc = "save Neovim session state",
        })
    end,
}
