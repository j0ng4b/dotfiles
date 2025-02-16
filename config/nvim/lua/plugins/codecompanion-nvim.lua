local install_required_treesitters = function()
    local treesitter = require('nvim-treesitter.configs')
    local ensure_installed = treesitter.get_ensure_installed_parsers()

    local treesitter_languages = { 'markdown' }

    for _, language in ipairs(treesitter_languages) do
        if not vim.tbl_contains(ensure_installed, language) then
            table.insert(ensure_installed, language)
        end
    end

    treesitter.setup { ensure_installed = ensure_installed }
end

local config = function()
    install_required_treesitters()


    local map = require('core.utils.map')

    map({ 'n', 'v' }, '<Leader>ca', '<Cmd>CodeCompanionActions<CR>', { noremap = true })
    map({ 'n', 'v' }, '<Leader>c', '<Cmd>CodeCompanionChat Toggle<CR>', { noremap = true })
    map({ 'v' }, 'ga', '<Cmd>CodeCompanionChat Add<CR>', { noremap = true })

    vim.cmd [[cab cc CodeCompanion]]


    require('codecompanion').setup({
        sources = {
            per_filetype = {
                codecompanion = { 'codecompanion' },
            },
        },

        display = {
            action_palette = {
                provider = 'telescope',
            },

            chat = {
                show_header_separator = false,
                start_in_insert_mode = true,

                window = {
                    layout = 'float',

                    height = 0.85,
                    width = 0.70,
                },
            },
        },

        strategies = {
            chat = {
                adapter = 'gemini',

                keymaps = {
                    send = {
                        modes = { n = '<C-s>', i = '<C-s>' },
                    },

                    close = {
                        modes = { n = '<C-c>', i = '<C-c>' },
                    },
                },

                roles = {
                    llm = function(adapter)
                        return adapter.formatted_name
                    end,

                    user = 'Me',
                },
            },

            inline = {
                adapter = 'ollama',
            },
        },

        adapters = {
            ollama = function()
                return require('codecompanion.adapters').extend('ollama', {
                    schema = {
                        model = {
                            default = 'llama3.2',
                        },
                    },
                })
            end,
        },
    })
end


return {
    'olimorris/codecompanion.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
    },
    config = config,
}

