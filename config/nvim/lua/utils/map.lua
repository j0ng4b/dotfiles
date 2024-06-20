--   ╦ ╦┌┬┐┬┬  ┌─┐
--   ║ ║ │ ││  └─┐
--   ╚═╝ ┴ ┴┴─┘└─┘

local M = {}

M.del = function(modes, left)
    for _, mode in ipairs(modes) do
        vim.api.nvim_del_keymap(mode, left)
    end
end

setmetatable(M, {
    __call = function(self, modes, left, right, opts)
        local opts = opts or {}

        if opts.buffer then
            -- Don't pass buffer value to neovim function
            opts.buffer = nil

            if type(right) == 'function' then
                opts.calback = right
                right = ''
            end

            for _, mode in ipairs(modes) do
                vim.api.nvim_buf_set_keymap(mode, left, right, opts)
            end
        else
            if type(right) == 'function' then
                opts.callback = right
                right = ''
            end

            for _, mode in ipairs(modes) do
                vim.api.nvim_set_keymap(mode, left, right, opts)
            end
        end
    end
})

return M
