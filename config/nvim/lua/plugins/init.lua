--   ╔═╗┬  ┬ ┬┌─┐┬┌┐┌┌─┐
--   ╠═╝│  │ ││ ┬││││└─┐
--   ╩  ┴─┘└─┘└─┘┴┘└┘└─┘

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- Plugins list
require('lazy').setup({
    -- Language server setup
    {
        'neovim/nvim-lspconfig',
        config = function()
            require('plugins.configs.lsp')
        end,
    },

    {
        'SmiteshP/nvim-navic',
        dependencies = 'neovim/nvim-lspconfig',
        config = function()
            require('plugins.configs.navic')
        end,
    },

    -- Autocomplete
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-buffer',
        },
        config = function()
            require('plugins.configs.cmp')
        end,
    },

    -- Snippets
    {
        'garymjr/nvim-snippets',
        dependencies = 'rafamadriz/friendly-snippets',
        config = function()
            require('snippets').setup({
                highlight_preview = true,
                create_cmp_source = true,
                friendly_snippets = true,
            })
        end,
    },

    -- Treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        -- WARN: Treesitter tagged version should note be used see:
        -- https://github.com/tree-sitter/tree-sitter-html/issues/102
        --
        -- When using tagged version the parsers get less updates
        -- therefore it's more easier to get compatibilities issues.
        -- version = '*',
        config = function()
            require('plugins.configs.treesitter')
        end,
    },

    -- Fold
    {
        'razak17/tailwind-fold.nvim',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        opts = {
            symbol = '󱏿',
            highlight = {
                fg = '#38BDF8',
            },
        },
        ft = {
            'html',
            'javascriptreact',
            'typescriptreact',
        },
    },

    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require('plugins.configs.ufo')
        end,
    },

    -- Tree viewer
    {
        'nvim-neo-tree/neo-tree.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('plugins.configs.neotree')
        end,
    },

    -- Auto closing
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require('plugins.configs.autopairs')
        end,
    },

    {
        'windwp/nvim-ts-autotag',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = 'nvim-treesitter/nvim-treesitter',
        config = function()
            require('nvim-ts-autotag').setup()
        end
    },

    -- Git
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('plugins.configs.gitsigns')
        end,
    },

    -- Others useful plugins
    {
        'kylechui/nvim-surround',
        event = 'VeryLazy',
        config = function()
            require('nvim-surround').setup({
                move_cursor = 'stick',
            })
        end
    },

    {
        'mattn/emmet-vim',
        ft = {
            'html',
            'css',
            'scss',
            'javascriptreact',
            'typescriptreact',
        },
    },

    {
        'dcampos/cmp-emmet-vim',
        dependencies = 'mattn/emmet-vim',
    },

    -- Colorschemes
    {
        'catppuccin/nvim',
        name = 'catppuccin',
    },

    {
        'sainnhe/gruvbox-material',
        name = 'gruvbox',
    },

    -- Eye-candy
    {
        'rachartier/tiny-devicons-auto-colors.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        event = 'VeryLazy',
        config = function()
            require('tiny-devicons-auto-colors').setup()
        end
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.configs.lualine')
        end,
    },

    {
        'akinsho/bufferline.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.configs.bufferline')
        end,
    },

    {
        'luukvbaal/statuscol.nvim',
        config = function()
            require('plugins.configs.statuscol')
        end,
    },

    {
        'b0o/incline.nvim',
        event = 'VeryLazy',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.configs.incline')
        end,
    },

    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function()
            require('ibl').setup({
                indent = {
                    smart_indent_cap = true,
                },
            })
        end,
    },

    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({
                render = 'virtual',

                virtual_symbol = '',
                virtual_symbol_position = 'inline',
                virtual_symbol_prefix = '',
                virtual_symbol_suffix = ' ',

                enable_rgb = true,
                enable_hex = true,
                enable_hsl = true,

                -- NOTE: If tailwind language server is installed then this
                -- option will not take any effect, LSP has priority.
                enable_tailwind = true,
                enable_var_usage = true,
                enable_short_hex = true,
                enable_named_colors = true,
            })
        end,
    },
})

