--   ╦ ╦┌┬┐┬┬  ┌─┐
--   ║ ║ │ ││  └─┐
--   ╚═╝ ┴ ┴┴─┘└─┘

local M = {}

M.del = function(modes, left)
    for _, mode in ipairs(modes) do
        vim.api.nvim_del_keymap(mode, left)
    end
end


M.which_key = false
M.use_which_key = function(enable)
    M.which_key = enable or true
end

M.group = function(name, prefix)
    if not M.which_key then
        return
    end

    require('which-key').add({
        lhs = prefix,
        group = name,
    })
end

local wk_map = function(modes, left, right, opts)
    if not M.which_key then
        return
    end

    if type(opts) == 'string' then
        opts = {
            desc = opts,
        }
    else
        opts = opts or {}
    end


    require('which-key').add({
        left,
        right,

        mode = modes,

        desc = opts.desc,
        icon = opts.icon,

        remap = opts.remap,
    })
end


local normal_map = function(modes, left, right, opts)
    local opts = opts or {}

    if opts.buffer then
        local buffer = opts.buffer

        -- Don't pass buffer value to neovim function
        opts.buffer = nil

        if type(right) == 'function' then
            opts.callback = right
            right = ''
        end

        for _, mode in ipairs(modes) do
            vim.api.nvim_buf_set_keymap(buffer, mode, left, right, opts)
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


setmetatable(M, {
    __call = function(self, ...)
        if self.which_key then
            wk_map(...)
            return
        end

        normal_map(...)
    end
})

return M
