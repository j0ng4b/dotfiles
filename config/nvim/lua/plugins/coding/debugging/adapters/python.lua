local dap = require("dap")

-- The adapter runs in Mason's debugpy venv; the debugged program uses
-- pythonPath.
dap.adapters.python = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
    args = { "-m", "debugpy.adapter" },
}

-- Interpreter for the debugged program: activated venv, then the project's
-- .venv/venv, then PATH.
---@return string
local function python_path()
    local cwd = vim.fn.getcwd()
    local candidates = {}

    if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
        candidates[#candidates + 1] = vim.env.VIRTUAL_ENV .. "/bin/python"
    end

    vim.list_extend(candidates, {
        cwd .. "/.venv/bin/python",
        cwd .. "/venv/bin/python",
        vim.fn.exepath("python"),
        vim.fn.exepath("python3"),
    })

    for _, python in ipairs(candidates) do
        if python ~= "" and vim.fn.executable(python) == 1 then
            return python
        end
    end

    vim.notify("dap: no Python interpreter found", vim.log.levels.ERROR)
    return dap.ABORT
end

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        pythonPath = python_path,
    },

    {
        type = "python",
        request = "launch",
        name = "Flask (debug)",
        module = "flask",
        args = { "run", "--no-debugger", "--no-reload", "--port", "5001" },
        jinja = true,
        cwd = "${workspaceFolder}",
        pythonPath = python_path,
    },
}
