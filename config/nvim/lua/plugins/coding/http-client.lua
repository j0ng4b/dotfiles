local icons = require("core.utils.icons")

local SCRATCHPAD = {
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
}

-- { lhs, kulala function, description, mode }; active only in http/rest buffers.
local KEYMAPS = {
    -- Request execution
    { "<leader>rs", "run", "send request", { "n", "v" } },
    { "<leader>ra", "run_all", "send all requests", { "n", "v" } },
    { "<leader>rr", "replay", "replay last request" },

    -- Response window
    { "<leader>ro", "open", "open response window" },
    { "<leader>rq", "close", "close response window" },
    { "<leader>rt", "toggle_view", "toggle headers/body" },
    { "<leader>rS", "show_stats", "show request stats" },

    -- Inspection
    { "<leader>ri", "inspect", "inspect current request" },
    { "<leader>rf", "search", "find request" },

    -- Environment
    { "<leader>re", "set_selected_env", "select environment" },

    -- Utilities
    { "<leader>rc", "copy", "copy request as cURL" },
    { "<leader>rC", "from_curl", "paste request from cURL" },
    { "<leader>rg", "download_graphql_schema", "download GraphQL schema" },

    -- Navigation
    { "]r", "jump_next", "go to next request" },
    { "[r", "jump_prev", "go to previous request" },
}

---@return table[]
local function build_keys()
    local keys = {
        -- Works from any buffer.
        {
            "<leader>rb",
            function()
                require("kulala").scratchpad()
            end,
            desc = "open HTTP scratchpad",
        },
    }

    for _, map in ipairs(KEYMAPS) do
        keys[#keys + 1] = {
            map[1],
            require("kulala")[map[2]],
            ft = { "http", "rest" },
            mode = map[4] or "n",
            desc = map[3],
        }
    end

    return keys
end

return {
    "dont-be-evil-company/kulala.nvim",

    ft = { "http", "rest", "javascript" },
    event = { "SessionLoadPost" },
    keys = build_keys(),

    config = function()
        -- Needed by session.restore to bring back request history and the UI.
        vim.opt.sessionoptions:append("globals")

        require("kulala").setup({
            -- Own mappings live in keys above.
            -- The response window keymaps stay at the defaults.
            global_keymaps = false,

            response_format = {
                indent = 4,
                expand_tabs = true,
                sort_keys = true,
            },

            ui = {
                display_mode = "float",

                show_request_summary = false,

                default_view = "headers_body",
                default_winbar_panes = {
                    "headers_body",
                    "verbose",
                    "script_output",
                    "report",
                },

                -- Responses larger than this are not shown at all.
                max_response_size = 512 * 1024,

                show_icons = "on_request",
                icons = {
                    inlay = {
                        loading = icons.http.loading,
                        done = icons.http.done,
                        error = icons.http.error,
                    },

                    lualine = icons.http.request,
                },

                scratchpad_default_contents = SCRATCHPAD,
            },
        })
    end,
}
