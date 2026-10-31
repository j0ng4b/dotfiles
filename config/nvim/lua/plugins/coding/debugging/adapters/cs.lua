local dap = require("dap")

dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
}

-- Closest .csproj above the current buffer (or above cwd for unnamed buffers).
---@return string|nil
local function find_project()
    local name = vim.api.nvim_buf_get_name(0)

    return vim.fs.find(function(file)
        return file:match("%.csproj$") ~= nil
    end, {
        path = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd(),
        upward = true,
        type = "file",
    })[1]
end

---@param project? string
---@return string
local function project_dir(project)
    project = project or find_project()
    return project and vim.fs.dirname(project) or vim.fn.getcwd()
end

-- Debug build outputs of the project, without reference assemblies.
---@return string[]
local function find_dlls()
    local project = find_project()
    local name = project and vim.fn.fnamemodify(project, ":t:r") or "*"
    local dlls = vim.fn.globpath(project_dir(project), ("bin/Debug/**/%s.dll"):format(name), false, true)

    return vim.tbl_filter(function(path)
        return not path:find("/ref/", 1, true) and not path:find("/refint/", 1, true)
    end, dlls)
end

local function pick_assembly()
    local dlls = find_dlls()

    if #dlls == 0 then
        local path = vim.fn.input({
            prompt = "Path to DLL: ",
            default = project_dir() .. "/bin/Debug/",
            completion = "file",
        })
        return path ~= "" and path or dap.ABORT
    end

    if #dlls == 1 then
        return dlls[1]
    end

    -- nvim-dap resumes the returned coroutine and waits for the chosen value.
    return coroutine.create(function(dap_co)
        vim.ui.select(dlls, {
            prompt = "Select .NET assembly",
            format_item = function(path)
                return vim.fn.fnamemodify(path, ":~:.")
            end,
        }, function(choice)
            coroutine.resume(dap_co, choice or dap.ABORT)
        end)
    end)
end

dap.configurations.cs = {
    {
        type = "coreclr",
        request = "launch",
        name = "Launch project",
        -- Project folder, not the solution root: ASP.NET looks for
        -- appsettings.json relative to the working directory.
        cwd = project_dir,
        program = pick_assembly,
        env = { ASPNETCORE_ENVIRONMENT = "Development" },
    },

    {
        type = "coreclr",
        request = "attach",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
    },
}
