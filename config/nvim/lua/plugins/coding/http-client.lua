local icons = require("core.utils.icons")

return {
    "mistweaverco/kulala.nvim",
    event = { "SessionLoadPost", "VimLeavePre" },
    ft = { "http", "rest", "javascript", "lua" },
    config = function()
        local kulala = require("kulala")
        kulala.setup({
            global_keymaps = false,

            lsp = {
                enable = true,
                keymaps = false,
            },

            response_format = {
                indent = 4,
                expand_tabs = true,
                sort_keys = true,
            },

            ui = {
                display_mode = "float",

                show_request_summary = false,

                winbar = true,
                default_view = "headers_body",
                default_winbar_panes = { "headers_body", "verbose", "script_output", "report" },

                show_icons = "on_request",
                icons = {
                    inlay = {
                        loading = icons.http.loading,
                        done = icons.http.done,
                        error = icons.http.error,
                    },

                    lualine = icons.http.request,
                },

                scratchpad_default_contents = {
                    "@host=localhost",
                    "@port=5000",
                    "@baseUrl=http://{{host}}:{{port}}",
                    "",
                    "### GET request",
                    "GET {{baseUrl}}/",
                    "Accept: application/json",
                    "",
                    "### POST request",
                    "POST {{baseUrl}}/",
                    "Accept: application/json",
                    "Content-Type: application/json",
                    "",
                    "{",
                    '    "key": "value"',
                    "}",
                },
            },
        })

        --------------------
        -- Request execution
        vim.keymap.set({ "n", "v" }, "<leader>rs", kulala.run, {
            desc = "send request",
        })

        vim.keymap.set({ "n", "v" }, "<leader>ra", kulala.run_all, {
            desc = "send all requests",
        })

        vim.keymap.set({ "n" }, "<leader>rr", kulala.replay, {
            desc = "replay last request",
        })

        --------------------
        -- Request inspection
        vim.keymap.set({ "n" }, "<leader>ri", kulala.inspect, {
            desc = "inspect current request",
        })

        vim.keymap.set({ "n" }, "<leader>rf", kulala.search, {
            desc = "find request",
        })

        --------------------
        -- Environment
        vim.keymap.set({ "n" }, "<leader>re", kulala.set_selected_env, {
            desc = "select environment",
        })

        --------------------
        -- Utilities
        vim.keymap.set({ "n" }, "<leader>rb", kulala.scratchpad, {
            desc = "open HTTP scratchpad",
        })

        vim.keymap.set({ "n" }, "<leader>rc", kulala.copy, {
            desc = "copy request as cURL",
        })

        vim.keymap.set({ "n" }, "<leader>rC", kulala.from_curl, {
            desc = "paste request from cURL",
        })

        --------------------
        -- Navigation
        vim.keymap.set({ "n" }, "]r", kulala.jump_next, {
            desc = "go to next request",
        })

        vim.keymap.set({ "n" }, "[r", kulala.jump_prev, {
            desc = "go to previous request",
        })
    end,
}
