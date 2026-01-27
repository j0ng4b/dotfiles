local config = function()
    local cmp = require('cmp')

    local auto = require('core.utils.autocmd')
    local icons = require('core.utils.icons')

    local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    cmp.setup({
        snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
        },

        mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-5),
            ['<C-f>'] = cmp.mapping.scroll_docs(5),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = false
                        })
                    else
                        fallback()
                    end
                end,
                s = cmp.mapping.confirm({ select = true }),
            }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.snippet.active({ direction = 1 }) then
                    vim.snippet.jump(1)
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.snippet.active({ direction = -1 }) then
                    vim.snippet.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        },

        completion = {
            keyword_length = 1,
        },

        window = {
            completion = {
                col_offset = -4,
                side_padding = 0,
            },
        },

        view = {
            entries = {
                name = 'custom',
                selection_order = 'near_cursor',
            },
        },

        formatting = {
            fields = { 'kind', 'abbr', 'menu' },
            format = function(entry, item)
                local color_item = require('nvim-highlight-colors').format(entry, { kind = item.kind })

                item.menu = ' · ' .. ({
                    nvim_lsp = '[Lsp]',
                    nvim_lsp_signature_help = '[LspSig]',
                    snippets = '[Snippet]',
                    buffer = '[Buffer]',
                    emmet_vim = '[Emmet]',
                    path = '[Path]',
                    codecompanion_tools = '[CC]',
                    codecompanion_variables = '[CC]',
                    codecompanion_slash_commands = '[CC]',
                    ['vim-dadbod-completion'] = '[DB]',
                })[entry.source.name]

                item.kind = ' ' .. (icons.kinds[item.kind] or '') .. ' '

                if color_item.abbr_hl_group then
                    item.kind_hl_group = 'cmp-item-' .. color_item.abbr_hl_group

                    local hl_attrs = {}
                    for k, v in pairs(vim.api.nvim_get_hl(0, { name = color_item.abbr_hl_group })) do
                        hl_attrs[k] = v
                    end

                    hl_attrs.reverse = true
                    hl_attrs.force = true

                    vim.api.nvim_set_hl(0, item.kind_hl_group, hl_attrs)
                end

                return item
            end
        },

        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'snippets' },
            { name = 'buffer' },
            { name = 'emmet_vim' },
            { name = 'path' },
        }),
    })

    cmp.event:on('menu_opened', function()
        vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on('menu_closed', function()
        vim.b.copilot_suggestion_hidden = false
    end)


    local names = {
        'CmpItemKindField',
        'CmpItemKindProperty',
        'CmpItemKindEvent',

        'CmpItemKindText',
        'CmpItemKindEnum',
        'CmpItemKindKeyword',

        'CmpItemKindConstant',
        'CmpItemKindConstructor',
        'CmpItemKindReference',

        'CmpItemKindFunction',
        'CmpItemKindStruct',
        'CmpItemKindClass',
        'CmpItemKindModule',
        'CmpItemKindOperator',

        'CmpItemKindVariable',
        'CmpItemKindFile',

        'CmpItemKindUnit',
        'CmpItemKindSnippet',
        'CmpItemKindFolder',

        'CmpItemKindMethod',
        'CmpItemKindValue',
        'CmpItemKindEnumMember',

        'CmpItemKindInterface',
        'CmpItemKindColor',
        'CmpItemKindTypeParameter',
    }

    for _, name in ipairs(names) do
        vim.cmd.highlight({ name, 'term=reverse', 'cterm=reverse', 'gui=reverse' })
    end
end


return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    config = config,
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'dcampos/cmp-emmet-vim',
    },
}

