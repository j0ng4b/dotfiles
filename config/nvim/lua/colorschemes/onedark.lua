return {
    'navarasu/onedark.nvim',
    version = '*',
    priority = 1000,
    opts = {
        style = 'darker',
        transparent = false,
        term_colors = true,
        cmp_itemkind_reverse = true,


        code_style = {
            comments = 'italic',
            keywords = 'none',
            functions = 'bold',
            strings = 'none',
            variables = 'none'
        },

        diagnostics = {
            darker = true,
            undercurl = true,
            background = true,
        },
    }
}

