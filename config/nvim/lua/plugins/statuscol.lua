local config = function()
    local statuscol = require('statuscol')

    local ft_ignore = {
        'neo-tree',
        'dbui',
    }

    local builtin = require('statuscol.builtin')
    statuscol.setup({
        relculright = true,

        ft_ignore = ft_ignore,
        bt_ignore = ft_ignore,

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
end


return {
    'luukvbaal/statuscol.nvim',
    config = config,
}

