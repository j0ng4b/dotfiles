--   ╦ ╦┌┬┐┬┬  ┌─┐
--   ║ ║ │ ││  └─┐
--   ╚═╝ ┴ ┴┴─┘└─┘

local M = {}

function M.group(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

function M.cmd(events, pattern, cmd, opts)
    local split = function(input, sep)
        local res = {}

        for str in input:gmatch('([^' .. sep .. ']+)') do
            table.insert(res, str)
        end

        return res
    end

    if type(events) == 'string' and string.find(events, ',') then
        events = split(events, ',')
    end

    local opts = opts or {}
    if type(opts) == 'string' then
        opts = { group = opts }
    end

    if type(pattern) == 'string' and string.find(pattern, ',') then
        opts.pattern = split(pattern, ',')
    elseif type(pattern) == 'table' then
        opts.pattern = pattern
    end

    if type(cmd) == 'function' then
        opts.callback = cmd
    else
        opts.command = cmd
    end

    vim.api.nvim_create_autocmd(events, opts)
end

return M
