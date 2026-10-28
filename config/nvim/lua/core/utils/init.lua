local M = {}

--- Try load a module without error propagation.
---@param module string
---@return any|nil module
function M.safe_require(module)
    local ok, m = pcall(require, module)
    return ok and m or nil
end

return M
