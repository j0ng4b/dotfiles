local status, statuscol = pcall(require, 'statuscol')
if not status then
    return
end

local builtin = require('statuscol.builtin')
statuscol.setup({
    relculright = true,

    ft_ignore = { 'neo-tree' },
    bt_ignore = { 'neo-tree' },

    segments = {
        {
            text = { '%s' },
            click = 'v:lua.ScSa',
        },
        {
            text = { builtin.lnumfunc },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
        },
        {
            text = { ' ', builtin.foldfunc, ' ' },
            click = 'v:lua.ScFa',
        },
    },
})

