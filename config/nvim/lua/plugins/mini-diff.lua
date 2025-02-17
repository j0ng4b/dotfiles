return {
    'echasnovski/mini.diff',
    config = function()
        local icons = require('core.utils.icons')
        local diff = require('mini.diff')

        diff.setup({
            view = {
                style = 'sign',
                signs = {
                    add = icons.git.added,
                    change = icons.git.modified,
                    delete = icons.git.deleted,
                },
            },

            source = diff.gen_source.none(),
        })
    end,
}

