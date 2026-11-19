local function close_dbout()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "dbout" then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end
end

return {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
        {
            "tpope/vim-dadbod",
            lazy = true,
        },

        {
            "kristijanhusak/vim-dadbod-completion",
            lazy = true,
            ft = { "sql", "mysql", "plsql" },
        },
    },

    cmd = {
        "DBUI",
        "DBUIToggle",
        "DBUIAddConnection",
        "DBUIFindBuffer",
    },

    keys = {
        {
            "<leader>Do",
            "<cmd>DBUIToggle<cr>",
            desc = "DB: toggle drawer",
        },

        {
            "<leader>Da",
            "<cmd>DBUIAddConnection<cr>",
            desc = "DB: add connection",
        },

        {
            "<leader>Dc",
            close_dbout,
            desc = "DB: close result window",
        },
    },

    init = function()
        local utils = require("core.utils")

        vim.g.db_ui_win_position = "right"
        vim.g.db_ui_use_nerd_fonts = 1

        vim.g.db_ui_env_variable_url = "DATABASE_URL"
        vim.g.db_ui_env_variable_name = "DATABASE_NAME"

        vim.g.db_ui_save_location = "~/.local/share/db_ui"
        vim.g.db_ui_execute_on_save = 0

        vim.g.db_ui_use_nvim_notify = 1
        vim.g.db_ui_disable_info_notifications = 1

        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("DbuiWindow", { clear = true }),
            pattern = "DBUIOpened",
            callback = function()
                if vim.bo.filetype ~= "dbui" then
                    return
                end

                local wo = vim.wo[0][0]
                wo.foldcolumn = "0"
                wo.number = false
                wo.relativenumber = false
                wo.signcolumn = "no"
                wo.statuscolumn = ""
                wo.cursorline = true
                wo.wrap = false
            end,
            desc = "Window options for the DBUI sidebar",
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("DadbodCmp", { clear = true }),
            pattern = { "sql", "mysql", "plsql" },
            callback = function()
                local cmp = utils.safe_require("cmp")
                if cmp then
                    cmp.setup.buffer({
                        sources = {
                            { name = "vim-dadbod-completion" },
                            { name = "buffer" },
                            { name = "async_path" },
                        },
                    })
                end
            end,
            desc = "Use dadbod completion in SQL buffers",
        })

        vim.g.db_ui_disable_mappings_sql = 1
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("DbuiSqlKeys", { clear = true }),
            pattern = { "sql", "mysql", "plsql" },
            callback = function(ev)
                local function map(mode, lhs, plug, desc)
                    vim.keymap.set(mode, lhs, plug, {
                        buffer = ev.buf,
                        remap = true, -- necessário para <Plug>
                        silent = true,
                        desc = desc,
                    })
                end

                map("n", "<leader>De", "<Plug>(DBUI_ExecuteQuery)", "DB: execute query")
                map("v", "<leader>De", "<Plug>(DBUI_ExecuteQuery)", "DB: execute query")

                map("n", "<C-CR>", "vip<Plug>(DBUI_ExecuteQuery)", "DB: execute query under cursor")
                map("i", "<C-CR>", "<C-o>vip<Plug>(DBUI_ExecuteQuery)", "DB: execute query under cursor")
                map("v", "<C-CR>", "<Plug>(DBUI_ExecuteQuery)", "DB: execute selected query")

                map("n", "<leader>Ds", "<Plug>(DBUI_SaveQuery)", "DB: save query")
                map("n", "<leader>Db", "<Plug>(DBUI_EditBindParameters)", "DB: edit bind parameters")
            end,
            desc = "Dadbod keymaps for SQL buffers",
        })
    end,
}
