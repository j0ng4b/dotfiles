return {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
        { 'tpope/vim-dadbod', lazy = true },

        {
            'kristijanhusak/vim-dadbod-completion',
            ft = {
                'sql',
                'mysql',
                'plsql'
            },
            lazy = true
        },
    },

    cmd = {
        'DBUI',
        'DBUIToggle',
        'DBUIAddConnection',
        'DBUIFindBuffer',
    },

    init = function()
        vim.g.db_ui_win_position = 'right'
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_use_nvim_notifya = 1
        vim.g.db_ui_show_database_icon = 1
   end,
}
