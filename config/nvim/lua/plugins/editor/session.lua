return {
    "rmagatti/auto-session",
    lazy = false,

    keys = {
        {
            "<Leader>qs",
            "<Cmd>AutoSession save<CR>",
            desc = "save current session",
        },

        {
            "<Leader>qr",
            "<Cmd>AutoSession restore<CR>",
            desc = "restore session for current directory",
        },

        {
            "<Leader>qR",
            "<Cmd>AutoSession search<CR>",
            desc = "search sessions",
        },

        {
            "<Leader>qt",
            "<Cmd>AutoSession toggle<CR>",
            desc = "toggle session autosave",
        },

        {
            "<Leader>qd",
            "<Cmd>AutoSession delete<CR>",
            desc = "delete current session",
        },

        {
            "<Leader>qD",
            "<Cmd>AutoSession deletePicker<CR>",
            desc = "select session to delete",
        },
    },

    config = function()
        vim.opt.sessionoptions = {
            "blank",
            "buffers",
            "curdir",
            "folds",
            "help",
            "localoptions",
            "skiprtp",
            "tabpages",
            "terminal",
            "winsize",
            "winpos",
        }

        require("auto-session").setup({
            show_auto_restore_notif = true,

            suppressed_dirs = { "~/", "~/Downloads", "/" },
            bypass_save_filetypes = { "alpha" },

            git_use_branch_name = true,
            git_auto_restore_on_branch_change = false,

            legacy_cmds = false,

            save_extra_data = function(_)
                local breakpoints = package.loaded["dap.breakpoints"]
                if not breakpoints then
                    return
                end

                local bps = {}
                for buf, buf_bps in pairs(breakpoints.get()) do
                    local filename = vim.api.nvim_buf_get_name(buf)
                    if filename ~= "" then
                        bps[filename] = buf_bps
                    end
                end

                if vim.tbl_isempty(bps) then
                    return
                end

                return vim.json.encode({ breakpoints = bps })
            end,

            restore_extra_data = function(_, extra_data)
                local json = vim.json.decode(extra_data)
                if not json.breakpoints then
                    return
                end

                local ok, breakpoints = pcall(require, "dap.breakpoints")
                if not ok or not breakpoints then
                    return
                end

                for buf_name, buf_bps in pairs(json.breakpoints) do
                    for _, bp in ipairs(buf_bps) do
                        local bufnr = vim.fn.bufnr(buf_name, true)
                        if vim.fn.bufloaded(bufnr) == 0 then
                            vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
                        end

                        breakpoints.set({
                            condition = bp.condition,
                            log_message = bp.logMessage,
                            hit_condition = bp.hitCondition,
                        }, bufnr, bp.line)
                    end
                end
            end,

            pre_restore_cmds = {
                function()
                    local breakpoints = package.loaded["dap.breakpoints"]
                    if breakpoints then
                        breakpoints.clear()
                    end
                end,
            },
        })

        local timer = vim.uv.new_timer()
        timer:start(
            30000,
            90000,
            vim.schedule_wrap(function()
                require("auto-session").auto_save_session()
            end)
        )
    end,
}
