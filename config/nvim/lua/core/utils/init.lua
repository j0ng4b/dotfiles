--  ╦ ╦┌┬┐┬┬  ┌─┐
--  ║ ║ │ ││  └─┐
--  ╚═╝ ┴ ┴┴─┘└─┘

local M = {}

function M.safe_require(mod)
    local ok, m = pcall(require, mod)
    return ok and m or nil
end

return M
