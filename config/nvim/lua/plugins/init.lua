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
        version = '*',
        config = function()
            require('plugins.lsp')
        end,
    },

    {
        'SmiteshP/nvim-navic',
        dependencies = {
            'neovim/nvim-lspconfig',
        },
        config = function()
            require('plugins.navic')
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
            require('plugins.cmp')
        end,
    },

    -- Snippets
    {
        'garymjr/nvim-snippets',
        version = '*',
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
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
        version = '*',
        config = function()
            require('plugins.treesitter')
        end,
    },

    -- Tree viewer
    {
        'nvim-neo-tree/neo-tree.nvim',
        version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('plugins.neotree')
        end,
    },

    -- Auto closing
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require('plugins.autopairs')
        end,
    },

    {
        'windwp/nvim-ts-autotag',
        config = true,
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
            require('plugins.gitsigns')
        end,
    },

    -- Others useful plugins
    {
        'kylechui/nvim-surround',
        version = '*', -- Use for stability; omit to use `main` branch for the latest features
        event = 'VeryLazy',
        config = function()
            require('nvim-surround').setup({
                move_cursor = 'stick',
            })
        end
    },

    -- Colorschemes
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        config = function()
            require('plugins.colorscheme.catppuccin')
        end,
    },

    -- Eye-candy
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.lualine')
        end,
    },

    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.bufferline')
        end,
    },

    {
        'b0o/incline.nvim',
        event = 'VeryLazy',
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('plugins.incline')
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
        'nvim-tree/nvim-web-devicons',
        lazy = true,
    },

    {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({
                render = 'virtual',

                virtual_symbol_position = 'inline',
                virtual_symbol_prefix = '',
                virtual_symbol_suffix = '  ',

                enable_tailwind = true,
            })
        end,
    },
})

