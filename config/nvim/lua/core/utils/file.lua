local M = {}

--- Reads the entire contents of a file.
---@param filename string Path to the file.
---@return string|nil content The file contents, or `nil` if the file cannot be opened.
function M.read(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil
    end

    local content = file:read("*a")

    file:close()
    return content
end

--- Writes content to a file, overwriting its existing contents.
---@param filename string Path to the file.
---@param content string Content to write.
---@return boolean success `true` if the file was opened and written to, `false` otherwise.
function M.write(filename, content)
    local file = io.open(filename, "w")
    if not file then
        return false
    end

    file:write(content)
    file:close()

    return true
end

return M
