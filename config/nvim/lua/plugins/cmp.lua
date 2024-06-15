local status, cmp = pcall(require, 'cmp')
if not status then
    return
end

local kind_icons = {
    Text = '',
    Method = '󰆧',
    Boolean = '',
    Null = '󰟢',
    Function = '󰊕',
    Constructor = '',
    Package = '󰏖',
    Field = '',
    Variable = '',
    Class = '󰠱',
    Interface = '',
    Module = '',
    Property = '󰜢',
    Unit = '',
    Value = '󰎠',
    Array = '󰅪',
    String = '󰀬',
    Number = '󰎠',
    Enum = '󰒻',
    Keyword = '󰌋',
    Snippet = '',
    Color = '󰏘',
    File = '󰈙',
    Reference = '',
    Folder = '󰉋',
    EnumMember = '',
    Constant = '󰏿',
    Struct = '󰌗',
    Event = '',
    Object = '󰅩',
    Key = '󰌋',
    Operator = '󰆕',
    TypeParameter = '󰅲',
}

cmp.setup({
    snippet = {
        expand = function(args)
        end,
    },

    mapping = {
        ['<C-d>'] = cmp.mapping.scroll_docs(-5),
        ['<C-f>'] = cmp.mapping.scroll_docs(5),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
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
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
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
        format = function(entry, vim_item)
            vim_item.menu = '       (' .. (vim_item.kind or '') .. ')  '
            vim_item.kind = ' ' .. (kind_icons[vim_item.kind] or '') .. ' '

            return vim_item
        end
    },

    sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'buffer' },
    },
})

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

