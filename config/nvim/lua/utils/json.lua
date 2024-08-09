local M = {}

function M.read(filename)
    local file = io.open(filename, 'r')
    if not file then
      return nil
    end

    local ok, json = pcall(vim.json.decode, file:read('*a'))

    file:close()
    return ok and json or {}
end

function M.write(filename, json)
    local file = io.open(filename, 'w')
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
