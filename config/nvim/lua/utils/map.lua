--   ╦ ╦┌┬┐┬┬  ┌─┐
--   ║ ║ │ ││  └─┐
--   ╚═╝ ┴ ┴┴─┘└─┘

local __map = function(modes, opts)
    local opts = opts or {}
    if opts.buffer then
        -- Don't pass buffer value to neovim function
        opts.buffer = nil

        return function(left, right)
            if type(right) == 'function' then
                opts.calback = right
                right = ''
            end

            vim.api.nvim_buf_set_keymap(modes, left, right, opts)
            opts.callback = nil
        end
    else
        return function(left, right)
            if type(right) == 'function' then
                opts.callback = right
                right = ''
            end

            vim.api.nvim_set_keymap(modes, left, right, opts)
            opts.callback = nil
        end
    end
end

local __unmap = function(modes)
    return function(left)
        vim.api.nvim_del_keymap(modes, left)
    end
end

local M = {}

M.n = __map('n')
M.c = __map('c')
M.v = __map('v')
M.i = __map('i')

M.del_n = __unmap('n')
M.del_c = __unmap('c')
M.del_v = __unmap('v')
M.del_i = __unmap('i')

setmetatable(M, {
    __call = function(self, ...)
        __map('')(...)
    end,
})
return M
