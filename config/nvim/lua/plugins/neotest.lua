local config = function()
    require('neotest').setup {
        adapters = {
            require('neotest-python'),
        },
    }
end

return {
    'nvim-neotest/neotest',
    config = config,
    dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',

        -- Adapters
        'nvim-neotest/neotest-python',
    },
}

