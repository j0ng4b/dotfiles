local function save_breakpoints()
    -- Don't load nvim-dap just to save a session.
    local breakpoints = package.loaded["dap.breakpoints"]
    if not breakpoints then
        return
    end

    local by_file = {}
    for buf, list in pairs(breakpoints.get()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
            by_file[name] = list
        end
    end

    if next(by_file) == nil then
        return
    end

    return vim.json.encode({ breakpoints = by_file })
end

local function restore_breakpoints(_, extra_data)
    local ok, data = pcall(vim.json.decode, extra_data)
    if not ok or type(data) ~= "table" or not data.breakpoints then
        return
    end

    local has_dap, breakpoints = pcall(require, "dap.breakpoints")
    if not has_dap then
        return
    end

    for name, list in pairs(data.breakpoints) do
        local bufnr = vim.fn.bufnr(name, true)
        if vim.fn.bufloaded(bufnr) == 0 then
            vim.api.nvim_buf_call(bufnr, vim.cmd.edit)
        end

        for _, bp in ipairs(list) do
            breakpoints.set({
                condition = bp.condition,
                log_message = bp.logMessage,
                hit_condition = bp.hitCondition,
            }, bufnr, bp.line)
        end
    end
end

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
            "globals",
        }

        require("auto-session").setup({
            show_auto_restore_notif = false,

            suppressed_dirs = { "~/", "~/Downloads", "/" },
            bypass_save_filetypes = { "alpha" },

            git_use_branch_name = true,
            git_auto_restore_on_branch_change = false,

            legacy_cmds = false,

            save_extra_data = save_breakpoints,
            restore_extra_data = restore_breakpoints,

            pre_restore_cmds = {
                function()
                    local breakpoints = package.loaded["dap.breakpoints"]
                    if breakpoints then
                        breakpoints.clear()
                    end
                end,
            },
        })
    end,
}
