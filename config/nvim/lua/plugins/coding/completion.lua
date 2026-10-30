local hl_cache = {}

-- Readable foreground (black/white) for a 0xRRGGBB background.
---@param bg integer
---@return integer
local function contrast_fg(bg)
    local r = math.floor(bg / 0x10000)
    local g = math.floor(bg / 0x100) % 0x100
    local b = bg % 0x100

    return (0.299 * r + 0.587 * g + 0.114 * b) > 186 and 0x000000 or 0xFFFFFF
end

-- Creates the badge group once per colorscheme and returns its name.
---@param group string
---@param bg integer
---@return string
local function badge(group, bg)
    if not hl_cache[group] then
        vim.api.nvim_set_hl(0, group, { bg = bg, fg = contrast_fg(bg) })
        hl_cache[group] = true
    end

    return group
end

-- Inverted version of cmp's own CmpItemKind<kind> (icon on a colored block).
---@param kind string
---@return string|nil
local function kind_badge(kind)
    local fg = vim.api.nvim_get_hl(0, { name = "CmpItemKind" .. kind, link = false }).fg
    return fg and badge("CmpKindBadge" .. kind, fg) or nil
end

-- Parses "#rgb", "#rrggbb" or "#rrggbbaa" into 0xRRGGBB. Anything else is nil.
---@param text? string
---@return integer|nil
local function hex_to_int(text)
    local digits = text and text:match("#(%x+)")
    if not digits then
        return nil
    end

    if #digits == 3 then
        digits = digits:gsub(".", "%0%0")
    end

    if #digits ~= 6 and #digits ~= 8 then
        return nil
    end

    return tonumber(digits:sub(1, 6), 16)
end

-- Color of a completion entry: LSP Color items (tailwind, css-lsp) or a
-- label that is itself a hex color.
---@return integer|nil
local function entry_color(entry)
    local item = entry:get_completion_item()

    if item.kind == vim.lsp.protocol.CompletionItemKind.Color then
        local doc = item.documentation
        if type(doc) == "table" then
            doc = doc.value
        end
        return hex_to_int(doc) or hex_to_int(item.detail)
    end

    local label = item.label or ""
    return label:match("^#%x+$") and hex_to_int(label) or nil
end

local SOURCE_LABELS = {
    buffer = "[Buffer]",
    async_path = "[Path]",
    cmdline = "[CMD]",
    cmdline_history = "[CMD]",
    codecompanion_tools = "[CC]",
    codecompanion_variables = "[CC]",
    codecompanion_slash_commands = "[CC]",
}

---@return string
local function entry_label(entry)
    local src = entry.source.name

    if src:find("^nvim_lsp") then
        local client = vim.tbl_get(entry, "source", "source", "client", "name") or "Lsp"
        return ("[%s%s]"):format(client, src == "nvim_lsp_signature_help" and "·sig" or "")
    end

    return SOURCE_LABELS[src] or ("[" .. src .. "]")
end

---@return boolean
local function has_words_before()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return col > 0 and vim.api.nvim_get_current_line():sub(col, col):match("%s") == nil
end

return {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "https://codeberg.org/FelipeLema/cmp-async-path",
    },
    config = function()
        local utils = require("core.utils")
        local icons = require("core.utils.icons")
        local cmp = require("cmp")

        -- Tab / S-Tab. With a selected entry, navigate the menu; otherwise prefer
        -- jumping snippet placeholders over navigating an unselected menu.
        ---@param dir 1|-1
        local function navigate(dir)
            return cmp.mapping(function(fallback)
                local select = dir == 1 and cmp.select_next_item or cmp.select_prev_item
                local snippet = vim.snippet.active({ direction = dir })

                if cmp.visible() and (cmp.get_selected_entry() or not snippet) then
                    select({ behavior = cmp.SelectBehavior.Select })
                elseif snippet then
                    cmp.close()
                    vim.snippet.jump(dir)
                elseif dir == 1 and has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" })
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
                ["<C-k>"] = cmp.mapping(function()
                    if cmp.visible_docs() then
                        cmp.close_docs()
                    else
                        cmp.open_docs()
                    end
                end, { "i", "s" }),

                ["<C-Space>"] = cmp.mapping.complete(),

                -- Only confirms an explicitly selected entry; otherwise a normal <CR>.
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

                ["<Tab>"] = navigate(1),
                ["<S-Tab>"] = navigate(-1),
            },

            window = {
                documentation = { border = "rounded" },
                completion = {
                    col_offset = -3,
                    side_padding = 0,
                },
            },

            view = {
                docs = { auto_open = false },
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
                    local color = entry_color(entry)

                    item.kind_hl_group = color and badge(("CmpColorBadge%06x"):format(color), color)
                        or kind_badge(item.kind)

                    item.kind = " " .. (icons.kinds[item.kind] or "") .. " "
                    item.menu = "    " .. entry_label(entry)

                    return item
                end,
            },

            sources = {
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "buffer" },
                { name = "async_path" },
            },
        })

        ---@param types string|string[]
        ---@param sources table
        ---@param extra? table
        local function cmdline(types, sources, extra)
            cmp.setup.cmdline(
                types,
                vim.tbl_extend("force", {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = sources,
                    experimental = { ghost_text = true },
                }, extra or {})
            )
        end

        cmdline({ "/", "?" }, {
            { name = "buffer" },
            { name = "cmdline_history" },
        })

        cmdline(":", {
            { name = "async_path" },
            { name = "cmdline" },
            { name = "cmdline_history" },
        }, { matching = { disallow_symbol_nonprefix_matching = false } })

        -- Hide copilot's ghost text while the cmp menu is open.
        cmp.event:on("menu_opened", function()
            vim.b.copilot_suggestion_hidden = true
        end)
        cmp.event:on("menu_closed", function()
            vim.b.copilot_suggestion_hidden = false
        end)

        local autopairs = utils.safe_require("nvim-autopairs.completion.cmp")
        if autopairs then
            cmp.event:on("confirm_done", autopairs.on_confirm_done())
        end

        -- :colorscheme clears every group; badges are recreated lazily on next use.
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("CmpHighlights", { clear = true }),
            callback = function()
                hl_cache = {}
            end,
            desc = "Reset completion badge cache after colorscheme changes",
        })
    end,
}
