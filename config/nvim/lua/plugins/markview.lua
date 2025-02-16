local install_required_treesitters = function()
    local treesitter = require('nvim-treesitter.configs')
    local ensure_installed = treesitter.get_ensure_installed_parsers()

    local treesitter_languages = {
        'markdown',
        'markdown_inline',
        'html',
        -- 'latex',
        'yaml',
    }

    for _, language in ipairs(treesitter_languages) do
        if not vim.tbl_contains(ensure_installed, language) then
            table.insert(ensure_installed, language)
        end
    end

    treesitter.setup { ensure_installed = ensure_installed }
end


local config = function()
    install_required_treesitters()


    local presets = require('markview.presets');

    require('markview').setup({
        preview = {
            hybrid_modes = { 'n' },
            filetypes = { 'markdown', 'codecompanion' },
            ignore_buftypes = {},

            icon_provider = 'devicons',
        }
    })
end


return {
    'OXY2DEV/markview.nvim',
    lazy = false,
    config = config,
}

