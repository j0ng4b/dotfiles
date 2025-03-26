local adapters = {}

local config = function()
    require('neotest').setup({
        adapters = {},
    })

    vim.diagnostic.config({
        signs = false,
        virtual_text = {
            format = function(diagnostic)
                local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
                return message
            end,
        }
    }, vim.api.nvim_create_namespace('neotest'))
end

M = {
    {
        'nvim-neotest/neotest',
        config = config,
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
        },
    },

    -- Adapters
    {
        'nvim-neotest/neotest-python',
        lazy = true,
        dependencies = 'nvim-neotest/neotest',

        init = function()
            require('plugins.neotest').add_adapter('python', 'neotest-python')
        end,

        config = function()
            local adapters = require('neotest.config').adapters
            table.insert(adapters, require('neotest-python'))
        end,
    },

    {
        'fredrikaverpil/neotest-golang',
        lazy = true,
        dependencies = 'nvim-neotest/neotest',

        init = function()
            require('plugins.neotest').add_adapter('go', 'neotest-golang')
        end,

        config = function()
            local adapters = require('neotest.config').adapters
            table.insert(adapters, require('neotest-golang'))
        end,
    },
}


M.add_adapter = function(filetype, adapter)
    adapters[filetype] = adapter
end

M.setup_adapter = function(filetype)
    if adapters[filetype] and not package.loaded[adapters[filetype]] then
        require(adapters[filetype])
    end
end

return M
