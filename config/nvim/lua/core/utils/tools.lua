local json = require("core.utils.json")
local file = require("core.utils.file")

local PATH = vim.fn.stdpath("config") .. "/tools.json"

local M = {}

local data, by_ft

--- Loads and caches the contents of the tools.json configuration file.
---@return table
local function load()
    data = data or json.read(PATH) or {}
    return data
end

--- Expands comma-separated filetype keys (e.g., "html,css") into individual entries,
--- merging their respective format and lint lists into a normalized index.
---@return table<string, table>
local function index()
    if by_ft then
        return by_ft
    end

    by_ft = {}
    for key, spec in pairs(load().filetypes or {}) do
        for ft in key:gmatch("[^,%s]+") do
            local slot = by_ft[ft] or {}

            for _, kind in ipairs({ "format", "lint" }) do
                if spec[kind] then
                    slot[kind] = vim.list_extend(slot[kind] or {}, spec[kind])
                end
            end

            by_ft[ft] = slot
        end
    end

    return by_ft
end

--- Filetypes that declare at least one tool of `kind` ("format" | "lint").
---@param kind string
---@return string[]
function M.filetypes(kind)
    local list = {}

    for ft, slot in pairs(index()) do
        if slot[kind] then
            list[#list + 1] = ft
        end
    end

    return list
end

--- True if the buffer's project configures `tool`.
--- Tools without `files`/`embedded` have no requirement.
---@param tool string
---@param bufnr integer
---@return boolean
function M.has(tool, bufnr)
    local tools = load().tools or {}
    local spec = tools[tool]
    if spec and spec.like then
        spec = tools[spec.like]
    end

    if not spec or (not spec.files and not spec.embedded) then
        return true
    end

    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return false
    end

    return vim.fs.root(name, function(fname, dir)
        if vim.tbl_contains(spec.files or {}, fname) then
            return true
        end

        local text = spec.embedded and spec.embedded[fname]
        if not text then
            return false
        end

        local content = file.read(dir .. "/" .. fname)
        return content ~= nil and content:find(text, 1, true) ~= nil
    end) ~= nil
end

--- Tools to run for the buffer: strings run if configured,
--- nested lists run only the first configured one.
---@param kind string
---@param bufnr integer
---@param available? fun(name: string): boolean
---@return string[]
function M.resolve(kind, bufnr, available)
    local entries = (index()[vim.bo[bufnr].filetype] or {})[kind] or {}
    local result = {}

    --- Validates whether a tool is configured for the project and available.
    ---@param name string
    ---@return boolean
    local function usable(name)
        return M.has(name, bufnr) and (not available or available(name))
    end

    for _, entry in ipairs(entries) do
        if type(entry) == "string" then
            if usable(entry) then
                result[#result + 1] = entry
            end
        else
            for _, name in ipairs(entry) do
                if usable(name) then
                    result[#result + 1] = name
                    break
                end
            end
        end
    end

    return result
end

return M
