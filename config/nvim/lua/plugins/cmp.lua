local function hex_to_rgb(hex)
    return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

local function contrast_fg(bg_int)
    if not bg_int then
        return 0xFFFFFF
    end

    local r, g, b = hex_to_rgb(string.format("#%06x", bg_int))
    return (0.299 * r + 0.587 * g + 0.114 * b) > 186 and 0x000000 or 0xFFFFFF
end

local function resolve_hl(name, seen)
    seen = seen or {}
    if seen[name] then
        return {}
    end
    seen[name] = true

    local hl = vim.api.nvim_get_hl(0, { name = name })
    if vim.tbl_isempty(hl) then
        return {}
    end

    return hl.link and resolve_hl(hl.link, seen) or hl
end

local function invert_hl(hl)
    return vim.tbl_extend("force", hl, {
        bg = hl.fg,
        fg = contrast_fg(hl.fg),
    })
end

local hl_cache = {}
local function badge_hl(src_group)
    local group = "CmpColorBadge_" .. src_group
    if hl_cache[group] then
        return hl_cache[group]
    end

    local hl = resolve_hl(src_group)
    if not hl.fg then
        return nil
    end

    vim.api.nvim_set_hl(0, group, invert_hl(hl))
    hl_cache[group] = group
    return group
end

local function setup_kind_highlights()
    local groups = {
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

    for _, name in ipairs(groups) do
        local hl = resolve_hl(name)
        if hl.fg then
            vim.api.nvim_set_hl(0, name, invert_hl(hl))
        end
    end
end

local static_source_labels = {
    buffer = "[Buffer]",
    cmdline = "[CMD]",
    cmdline_history = "[CMD]",
    async_path = "[Path]",
    codecompanion_tools = "[CC]",
    codecompanion_variables = "[CC]",
    codecompanion_slash_commands = "[CC]",
}

local function entry_label(entry)
    local src = entry.source.name

    if src == "nvim_lsp" or src == "nvim_lsp_signature_help" then
        local client_name = vim.tbl_get(entry, "source", "source", "client", "name")
        local suffix = src == "nvim_lsp_signature_help" and "·sig" or ""
        return "[" .. (client_name or "Lsp") .. suffix .. "]"
    end

    return static_source_labels[src] or src
end

local function has_words_before()
    local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
        return false
    end

    return vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]:sub(col, col):match("%s") == nil
end

-- Main config -----------------------------------------------------------------
local config = function()
    local utils = require("core.utils")
    local icons = require("core.utils.icons")
    local cmp = require("cmp")
    local hl_colors = utils.safe_require("nvim-highlight-colors")

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
                if cmp.visible() and cmp.get_selected_entry() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif vim.snippet.active({ direction = 1 }) then
                    cmp.close()
                    vim.snippet.jump(1)
                elseif cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() and cmp.get_selected_entry() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                elseif vim.snippet.active({ direction = -1 }) then
                    cmp.close()
                    vim.snippet.jump(-1)
                elseif cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
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

        experimental = {
            ghost_text = true,
        },

        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, item)
                local color_item = hl_colors and hl_colors.format(entry, { kind = item.kind })
                if color_item and color_item.abbr_hl_group then
                    item.kind_hl_group = badge_hl(color_item.abbr_hl_group)
                end

                item.menu = " · " .. entry_label(entry)
                item.kind = " " .. (icons.kinds[item.kind] or "") .. " "

                return item
            end,
        },

        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "buffer" },
            { name = "async_path" },
        }),
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

    local cmp_autopairs = utils.safe_require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs and cmp_autopairs.on_confirm_done())

    setup_kind_highlights()

    local auto = require("core.utils.autocmd")
    auto.cmd("Colorscheme", nil, function()
        for group in pairs(hl_cache) do
            pcall(vim.api.nvim_set_hl, 0, group, {})
        end

        hl_cache = {}
        setup_kind_highlights()
    end)
end

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "https://codeberg.org/FelipeLema/cmp-async-path",
    },
    config = config,
}
