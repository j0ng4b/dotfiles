-- { lhs, nvim-dap function, description }
local COMMANDS = {
    { "<F5>", "continue", "start or continue debugging" },
    { "<S-F5>", "terminate", "terminate debugging" },
    { "<F6>", "pause", "pause debugging" },
    { "<F7>", "restart", "restart debugging" },
    { "<F8>", "run_to_cursor", "run to cursor" },
    { "<F10>", "step_over", "step over" },
    { "<F11>", "step_into", "step into" },
    { "<S-F11>", "step_out", "step out" },
    { "<F12>", "restart_frame", "restart current frame" },
    { "<Leader>bt", "toggle_breakpoint", "toggle breakpoint" },
    { "<Leader>bC", "clear_breakpoints", "clear all breakpoints" },
}

local REPL_ALIASES = {
    into = ".i",
    intoi = ".ii",
    out = ".o",
    scopes = ".s",
    threads = ".t",
    frames = ".f",
    up = ".u",
    down = ".d",
    goto_ = ".g",
}

local ADAPTERS = "plugins.coding.debugging.adapters"

-- Loads every module in adapters/ (one per language: adapter + configurations).
local function load_adapters()
    local dir = vim.fn.stdpath("config") .. "/lua/" .. (ADAPTERS:gsub("%.", "/"))

    for file, kind in vim.fs.dir(dir) do
        local name = kind == "file" and file:match("^(.+)%.lua$")
        if name then
            local ok, err = pcall(require, ADAPTERS .. "." .. name)
            if not ok then
                vim.notify(("dap: failed to load '%s': %s"):format(name, err), vim.log.levels.ERROR)
            end
        end
    end
end

-- Breakpoint that asks for a text first (condition or log message).
---@param prompt string
---@param set fun(dap: table, text: string)
local function prompted_breakpoint(prompt, set)
    return function()
        local text = vim.fn.input(prompt)
        if text ~= "" then
            set(require("dap"), text)
        end
    end
end

-- Moves the cursor to a DAP UI element, opening the UI if it isn't visible.
---@param name string
local function focus_dapui(name)
    return function()
        local ui = require("dapui")
        local element = ui.elements[name]

        if not element then
            vim.notify(("dap: unknown DAP UI element '%s'"):format(name), vim.log.levels.ERROR)
            return
        end

        local function focus()
            local win = vim.fn.bufwinid(element.buffer())
            if win == -1 then
                return false
            end
            vim.api.nvim_set_current_win(win)
            return true
        end

        if focus() then
            return
        end

        ui.open()
        vim.schedule(function()
            if not focus() then
                vim.notify(("dap: DAP UI element '%s' is not visible"):format(name), vim.log.levels.WARN)
            end
        end)
    end
end

---@return table[]
local function build_keys()
    local keys = {}

    for _, cmd in ipairs(COMMANDS) do
        keys[#keys + 1] = {
            cmd[1],
            function()
                require("dap")[cmd[2]]()
            end,
            desc = cmd[3],
        }
    end

    vim.list_extend(keys, {
        {
            "<Leader>bl",
            prompted_breakpoint("Log point message: ", function(dap, message)
                dap.set_breakpoint(nil, nil, message)
            end),
            desc = "set log point breakpoint",
        },
        {
            "<Leader>bc",
            prompted_breakpoint("Breakpoint condition: ", function(dap, condition)
                dap.set_breakpoint(condition)
            end),
            desc = "set conditional breakpoint",
        },

        {
            "<Leader>be",
            function()
                require("dapui").eval()
            end,
            mode = { "n", "v" },
            desc = "evaluate expression under cursor",
        },
        {
            "<Leader>bu",
            function()
                require("dapui").toggle()
            end,
            desc = "toggle debug UI",
        },

        { "<Leader>br", focus_dapui("repl"), desc = "focus debug REPL" },
        { "<Leader>bs", focus_dapui("scopes"), desc = "focus debug scopes" },
        { "<Leader>bw", focus_dapui("watches"), desc = "focus debug watches" },
        { "<Leader>bk", focus_dapui("stacks"), desc = "focus debug stacks" },
    })

    return keys
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
    },

    keys = build_keys(),

    config = function()
        local icons = require("core.utils.icons")

        local dap = require("dap")
        local ui = require("dapui")

        load_adapters()

        for cmd, alias in pairs(REPL_ALIASES) do
            vim.list_extend(require("dap.repl").commands[cmd], { alias })
        end

        local signs = {
            DapBreakpoint = icons.debug.breakpoint,
            DapLogPoint = icons.debug.logpoint,
            DapStopped = icons.debug.stopped,
            DapBreakpointCondition = icons.debug.condpoint,
            DapBreakpointRejected = icons.debug.rejectedpoint,
        }
        for name, text in pairs(signs) do
            vim.fn.sign_define(name, { text = text, texthl = name })
        end

        ui.setup()
        dap.listeners.after.event_initialized.dapui_config = ui.open
        dap.listeners.before.event_terminated.dapui_config = ui.close
        dap.listeners.before.event_exited.dapui_config = ui.close

        require("nvim-dap-virtual-text").setup({
            enabled_commands = false,
            virt_text_pos = "eol",
        })
    end,
}
