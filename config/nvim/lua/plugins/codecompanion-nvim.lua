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


    require('codecompanion').setup({
        display = {
            action_palette = {
                provider = 'telescope',
            },

            chat = {
                show_header_separator = false,
                start_in_insert_mode = true,

                window = {
                    layout = 'vertical',

                    height = 0.85,
                    width = 0.30,
                },
            },

            diff = {
                enabled = true,
                layout = 'vertical',
                provider = 'mini_diff',
            },
        },

        strategies = {
            chat = {
                adapter = 'copilot',

                keymaps = {
                    send = {
                        modes = {
                            n = { '<CR>', '<C-s>' },
                            i = '<C-s>'
                        },
                    },

                    close = {
                        modes = { n = '<C-c>', i = '<C-c>' },
                    },
                },

                roles = {
                    llm = function(adapter)
                        return adapter.formatted_name
                    end,

                    user = vim.fn.system('whoami'):match('%S+'),
                },
            },

            inline = {
                adapter = 'copilot',
            },
        },

        adapters = {
            copilot = function()
                return require('codecompanion.adapters').extend('copilot', {
                    schema = {
                        model = {
                            default = 'o3-mini',
                        },

                        max_tokens = {
                            default = 8192,
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

        {
            'zbirenbaum/copilot.lua',
            event = 'InsertEnter',

            opts = {
                panel = {
                    enabled = false,
                },

                suggestion = {
                    auto_trigger = true,

                    keymap = {
                        accept = '<C-y>',
                        accept_line = '<C-j>',
                        accept_word = '<C-l>',
                    },
                },
            },
        },
    },
    config = config,
}

