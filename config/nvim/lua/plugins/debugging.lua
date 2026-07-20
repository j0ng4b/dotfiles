local DEBUGPY_PYTHON = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

local ADAPTERS = {
    python = {
        executables = { DEBUGPY_PYTHON },
        setup = function(dap)
            dap.adapters.python = {
                type = "executable",
                command = DEBUGPY_PYTHON,
                args = { "-m", "debugpy.adapter" },
            }

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",

                    program = "${file}",
                    cwd = "${workspaceFolder}",

                    pythonPath = function()
                        local virtual_env = os.getenv("VIRTUAL_ENV")
                        if virtual_env and virtual_env ~= "" then
                            local python = virtual_env .. "/bin/python"
                            if vim.fn.executable(python) == 1 then
                                return python
                            end
                        end

                        local python = vim.fn.exepath("python")
                        if python ~= "" then
                            return python
                        end

                        python = vim.fn.exepath("python3")
                        if python ~= "" then
                            return python
                        end

                        vim.notify("dap: no Python interpreter found", vim.log.levels.ERROR)
                        return dap.ABORT
                    end,
                },
            }
        end,
    },

    cs = {
        executables = { "dotnet", "netcoredbg" },
        setup = function(dap)
            dap.adapters.coreclr = {
                type = "executable",
                command = vim.fn.exepath("netcoredbg"),
                args = { "--interpreter=vscode" },
            }

            dap.configurations.cs = {
                {
                    type = "coreclr",
                    request = "launch",
                    name = "Launch project",
                    cwd = "${workspaceFolder}",

                    program = function()
                        local filename = vim.api.nvim_buf_get_name(0)
                        local start_path = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()

                        local project = vim.fs.find(function(name)
                            return name:match("%.csproj$") ~= nil
                        end, {
                            path = start_path,
                            upward = true,
                            type = "file",
                        })[1]

                        local root = project and vim.fs.dirname(project) or vim.fn.getcwd()
                        local pattern

                        if project then
                            local project_name = vim.fn.fnamemodify(project, ":t:r")
                            pattern = "bin/Debug/**/" .. project_name .. ".dll"
                        else
                            pattern = "bin/Debug/**/*.dll"
                        end

                        local dlls = vim.fn.globpath(root, pattern, false, true)
                        dlls = vim.tbl_filter(function(path)
                            return not path:find("/ref/", 1, true) and not path:find("/refint/", 1, true)
                        end, dlls)

                        if #dlls == 0 then
                            local path = vim.fn.input({
                                prompt = "Path to DLL: ",
                                default = root .. "/bin/Debug/",
                                completion = "file",
                            })

                            return path ~= "" and path or dap.ABORT
                        end

                        if #dlls == 1 then
                            return dlls[1]
                        end

                        return coroutine.create(function(dap_run_co)
                            vim.ui.select(dlls, {
                                prompt = "Select .NET assembly",

                                format_item = function(path)
                                    return vim.fn.fnamemodify(path, ":~:.")
                                end,
                            }, function(choice)
                                coroutine.resume(dap_run_co, choice or dap.ABORT)
                            end)
                        end)
                    end,
                },

                {
                    type = "coreclr",
                    request = "attach",
                    name = "Attach to process",

                    processId = require("dap.utils").pick_process,
                },
            }
        end,
    },

    go = {
        executables = { "dlv" },

        setup = function(dap)
            dap.adapters.go = {
                type = "server",
                port = "${port}",

                executable = {
                    command = vim.fn.exepath("dlv"),
                    args = {
                        "dap",
                        "--listen=127.0.0.1:${port}",
                    },
                },
            }

            dap.configurations.go = {
                {
                    type = "go",
                    request = "launch",
                    mode = "debug",
                    name = "Launch file",

                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },

                {
                    type = "go",
                    request = "launch",
                    mode = "debug",
                    name = "Launch package",

                    program = "${fileDirname}",
                    cwd = "${workspaceFolder}",
                },

                {
                    type = "go",
                    request = "launch",
                    mode = "test",
                    name = "Debug package tests",

                    program = "${fileDirname}",
                    cwd = "${workspaceFolder}",
                },

                {
                    type = "go",
                    request = "attach",
                    mode = "local",
                    name = "Attach to process",

                    processId = require("dap.utils").pick_process,
                },
            }
        end,
    },
}

local loaded = {}

local function setup_adapter(filetype)
    local entry = ADAPTERS[filetype]
    if not entry then
        vim.notify(("dap: no debug adapter configured for filetype '%s'"):format(filetype), vim.log.levels.INFO)
        return false
    end

    if loaded[filetype] then
        return true
    end

    for _, executable in ipairs(entry.executables or {}) do
        if vim.fn.executable(executable) == 0 then
            vim.notify(
                ("dap: '%s' not found; debugging for %s cannot run"):format(executable, filetype),
                vim.log.levels.WARN
            )
            return false
        end
    end

    local ok, err = pcall(entry.setup, require("dap"))
    if not ok then
        vim.notify(("dap: failed to configure adapter for %s: %s"):format(filetype, err), vim.log.levels.ERROR)
        return false
    end

    loaded[filetype] = true
    return true
end

local function with_adapter(callback)
    return function()
        local dap = require("dap")
        if dap.session() or setup_adapter(vim.bo.filetype) then
            callback(dap)
        end
    end
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
    },

    keys = {
        {
            "<F5>",
            with_adapter(function(dap)
                dap.continue()
            end),
            desc = "start or continue debugging",
        },

        {
            "<S-F5>",
            function()
                require("dap").terminate()
            end,
            desc = "terminate debugging",
        },

        {
            "<F10>",
            function()
                require("dap").step_over()
            end,
            desc = "step over the current function",
        },

        {
            "<F11>",
            function()
                require("dap").step_into()
            end,
            desc = "step into the current function",
        },

        {
            "<F12>",
            function()
                require("dap").step_out()
            end,
            desc = "step out of the current function",
        },

        {
            "<Leader>bt",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "toggle breakpoint",
        },
        {
            "<Leader>bl",
            function()
                require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end,
            desc = "set log point breakpoint with message",
        },

        {
            "<Leader>br",
            function()
                require("dap").repl.toggle()
            end,
            desc = "toggle debug REPL",
        },

        {
            "<Leader>bc",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "set conditional breakpoint",
        },
    },

    config = function()
        local icons = require("core.utils.icons")

        local dap = require("dap")
        local repl = require("dap.repl")
        local ui = require("dapui")

        vim.list_extend(repl.commands.into, { ".i" })
        vim.list_extend(repl.commands.intoi, { ".ii" })
        vim.list_extend(repl.commands.out, { ".o" })
        vim.list_extend(repl.commands.scopes, { ".s" })
        vim.list_extend(repl.commands.threads, { ".t" })
        vim.list_extend(repl.commands.frames, { ".f" })
        vim.list_extend(repl.commands.up, { ".u" })
        vim.list_extend(repl.commands.down, { ".d" })
        vim.list_extend(repl.commands.goto_, { ".g" })

        vim.fn.sign_define("DapBreakpoint", {
            text = icons.debug.breakpoint,
            texthl = "DapBreakpoint",
        })

        vim.fn.sign_define("DapLogPoint", {
            text = icons.debug.logpoint,
            texthl = "DapLogPoint",
        })

        vim.fn.sign_define("DapStopped", {
            text = icons.debug.stopped,
            texthl = "DapStopped",
        })

        vim.fn.sign_define("DapBreakpointCondition", {
            text = icons.debug.condpoint,
            texthl = "DapBreakpointCondition",
        })

        vim.fn.sign_define("DapBreakpointRejected", {
            text = icons.debug.rejectedpoint,
            texthl = "DapBreakpointRejected",
        })

        -- DAP ui setup
        ui.setup()

        dap.listeners.after.event_initialized.dapui_config = function()
            ui.open()
        end

        dap.listeners.before.event_terminated.dapui_config = function()
            ui.close()
        end

        dap.listeners.before.event_exited.dapui_config = function()
            ui.close()
        end

        -- DAP virtual text
        require("nvim-dap-virtual-text").setup({
            enabled_commands = false,
            virt_text_pos = "eol",
        })
    end,
}
