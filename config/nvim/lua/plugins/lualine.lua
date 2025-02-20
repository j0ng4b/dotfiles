local codecompanion = function()
    local M = require('lualine.component'):extend()

    M.processing = false
    M.spinner_index = 1

    local spinner_symbols = {
        '⠋',
        '⠙',
        '⠹',
        '⠸',
        '⠼',
        '⠴',
        '⠦',
        '⠧',
        '⠇',
        '⠏',
    }
    local spinner_symbols_len = #spinner_symbols


    function M:init(options)
        M.super.init(self, options)
        local auto = require('core.utils.autocmd')

        auto.group('CodeCompanionHooks')
        auto.cmd('User', 'CodeCompanionRequest*', function(request)
            if request.match == 'CodeCompanionRequestStarted' then
                self.processing = true
            elseif request.match == 'CodeCompanionRequestFinished' then
                self.processing = false
            end
        end, 'CodeCompanionHooks')
    end


    function M:update_status()
        if self.processing then
            self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
            return 'Generating response ' .. spinner_symbols[self.spinner_index]
        else
            return nil
        end
    end

    return M
end

local config = function()
    local lualine = require('lualine')

    local icons = require('core.utils.icons')

    codecompanion_component = codecompanion()
    lualine.setup({
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = ''},
            section_separators = { left = '', right = ''},
            always_divide_middle = true,

        },

        sections = {
            lualine_a = {
                'mode',
            },
            lualine_b = {
                'branch',
            },
            lualine_c = {
                {
                    'filetype',
                    separator = '',
                    padding = { left = 1, right = 0 },
                    icon_only = true,
                },
                {
                    'filename',
                    separator = '',
                    padding = 0,
                    symbols = {
                        modified = icons.file.modified,
                        readonly = icons.file.readonly,
                        unnamed = ' [No Name]',
                        newfile = ' [New]',
                    },
                },
                { '%=', separator = '' },
                {
                    'diagnostics',
                    separator = '',
                    sources = { 'nvim_diagnostic', 'nvim_lsp' },
                    sections = { 'error', 'warn', 'info', 'hint' },
                    symbols = icons.diagnostics,
                },
            },

            lualine_x = {
                {
                    'fileformat',
                    separator = '',
                    padding = 1,
                },
                {
                    'encoding',
                    padding = {
                        left = -1,
                        right = 1,
                    },
                },
            },
            lualine_y = {
                'progress',
            },
            lualine_z = {
                'location',
            },
        },

        extensions = {
            'lazy',
            'mason',
            'neo-tree',
            'quickfix',
            'toggleterm',

            {
                sections = {
                    lualine_a = {
                        function()
                            return ' CodeCompanion'
                        end,
                    },

                    lualine_z = {
                        codecompanion_component,
                    },
                },

                filetypes = { 'codecompanion' },
            },
        },
    })
end


return {
    'nvim-lualine/lualine.nvim',
    config = config,
    dependencies = 'nvim-tree/nvim-web-devicons',
}

