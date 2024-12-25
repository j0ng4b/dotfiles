local M = {}

function M.read(filename)
    local file = io.open(filename, 'r')
    if not file then
      return nil
    end

    local content = file:read('*a')

    file:close()
    return content
end

function M.write(filename, content)
    local file = io.open(filename, 'w')
    if not file then
      return false
    end

    file:write(content)
    file:close()

    return true
end

return M
