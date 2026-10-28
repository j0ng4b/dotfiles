local M = {}

--- Reads and decodes a JSON file.
---@param filename string Path to the JSON file.
---@return any|table json The decoded JSON value, or an empty table if the file cannot be opened or decoded.
function M.read(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil
    end

    local ok, json = pcall(vim.json.decode, file:read("*a"))

    file:close()
    return ok and json or {}
end

--- Encodes a value as JSON and writes it to a file.
---@param filename string Path to the output file.
---@param json any Value to encode as JSON.
---@return boolean success `true` if the file was opened and encoding succeeded, `false` otherwise.
function M.write(filename, json)
    local file = io.open(filename, "w")
    if not file then
        return false
    end

    local ok, content = pcall(vim.json.encode, json)
    if not ok then
        file:close()
        return false
    end

    file:write(content)
    file:close()

    return true
end

return M
