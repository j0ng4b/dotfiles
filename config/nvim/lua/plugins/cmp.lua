local function setup_highlights()
    local function hex_to_rgb(hex)
        return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
    end

    local function get_contrast_fg(bg)
        if not bg then
            return 0xFFFFFF
        end

        local hex = string.format("#%06x", bg)
        local r, g, b = hex_to_rgb(hex)

        if 0.299 * r + 0.587 * g + 0.114 * b > 186 then
            return 0x000000
        else
            return 0xFFFFFF
        end
    end

    local function resolve_hl(name, seen)
        seen = seen or {}

        if seen[name] then
            return {}
        end
        seen[name] = true

        local hl = vim.api.nvim_get_hl(0, { name = name })
        if hl.link then
            return resolve_hl(hl.link, seen)
        end

        return hl
    end

    local names = {
        "CmpItemKindField",
        "CmpItemKindProperty",
        "CmpItemKindEvent",

        "CmpItemKindText",
        "CmpItemKindEnum",
        "CmpItemKindKeyword",

        "CmpItemKindConstant",
        "CmpItemKindConstructor",
        "CmpItemKindReference",

        "CmpItemKindFunction",
        "CmpItemKindStruct",
        "CmpItemKindClass",
        "CmpItemKindModule",
        "CmpItemKindOperator",

        "CmpItemKindVariable",
        "CmpItemKindFile",

        "CmpItemKindUnit",
        "CmpItemKindSnippet",
        "CmpItemKindFolder",

        "CmpItemKindMethod",
        "CmpItemKindValue",
        "CmpItemKindEnumMember",

        "CmpItemKindInterface",
        "CmpItemKindColor",
        "CmpItemKindTypeParameter",
    }

    for _, name in ipairs(names) do
        local hl = resolve_hl(name)
        if hl.fg then
            vim.api.nvim_set_hl(0, name, {
                fg = get_contrast_fg(hl.fg),
                bg = hl.fg,
                bold = hl.bold,
                italic = hl.italic,
            })
        end
    end
end

local config = function()
    local icons = require("core.utils.icons")
    local cmp = require("cmp")

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
            ["<C-d>"] = cmp.mapping.scroll_docs(-5),
            ["<C-f>"] = cmp.mapping.scroll_docs(5),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Replace,
                            select = false,
                        })
                    else
                        fallback()
                    end
                end,
                s = cmp.mapping.confirm({ select = true }),
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({
                        behavior = cmp.SelectBehavior.Select,
                    })
                elseif vim.snippet.active({ direction = 1 }) then
                    vim.snippet.jump(1)
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({
                        behavior = cmp.SelectBehavior.Select,
                    })
                elseif vim.snippet.active({ direction = -1 }) then
                    vim.snippet.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        },

        completion = {
            keyword_length = 1,
        },

        window = {
            completion = {
                col_offset = -3,
                side_padding = 0,
            },
        },

        view = {
            entries = {
                name = "custom",
                selection_order = "near_cursor",
            },
        },

        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, item)
                local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
                local source_labels = {
                    nvim_lsp = "[Lsp]",
                    nvim_lsp_signature_help = "[LspSig]",
                    buffer = "[Buffer]",
                    cmdline = "[CMD]",
                    cmdline_history = "[CMD]",
                    async_path = "[Path]",
                    codecompanion_tools = "[CC]",
                    codecompanion_variables = "[CC]",
                    codecompanion_slash_commands = "[CC]",
                }

                item.menu = " · " .. (source_labels[entry.source.name] or entry.source.name)
                item.kind = " " .. (icons.kinds[item.kind] or "") .. " "

                if color_item.abbr_hl_group then
                    item.kind_hl_group = "cmp-item-" .. color_item.abbr_hl_group

                    local hl_attrs = {}
                    for k, v in pairs(vim.api.nvim_get_hl(0, { name = color_item.abbr_hl_group })) do
                        hl_attrs[k] = v
                    end

                    hl_attrs.reverse = true
                    hl_attrs.force = true

                    vim.api.nvim_set_hl(0, item.kind_hl_group, hl_attrs)
                end

                return item
            end,
        },

        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "buffer" },
            { name = "async_path" },
        }),

        experimental = {
            ghost_text = true,
        },
    })

    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" },
            { name = "cmdline_history" },
        },

        experimental = {
            ghost_text = true,
        },
    })

    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "async_path" },
            { name = "cmdline" },
            { name = "cmdline_history" },
        }),

        matching = {
            disallow_symbol_nonprefix_matching = false,
        },

        experimental = {
            ghost_text = true,
        },
    })

    cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
    end)

    -- Setup highlights
    setup_highlights()

    local auto = require("core.utils.autocmd")
    auto.cmd("Colorscheme", nil, setup_highlights)
end

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "dmitmel/cmp-cmdline-history",
        "https://codeberg.org/FelipeLema/cmp-async-path",
    },
    config = config,
}
