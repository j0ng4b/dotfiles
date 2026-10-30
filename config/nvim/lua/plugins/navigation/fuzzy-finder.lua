-- Most recently used first; the current buffer goes last.
---@return table[]
local function get_buffers()
    local current = vim.api.nvim_get_current_buf()
    local infos = vim.tbl_filter(function(b)
        return b.name ~= ""
    end, vim.fn.getbufinfo({ buflisted = 1 }))

    table.sort(infos, function(a, b)
        local la = a.bufnr == current and 0 or a.lastused
        local lb = b.bufnr == current and 0 or b.lastused
        return la > lb
    end)

    return infos
end

-- Shortest path suffix that tells the buffers apart: only colliding labels
-- grow, one directory at a time.
---@param paths string[]
---@return string[]
local function smart_labels(paths)
    local segs, depth, labels = {}, {}, {}
    for i, path in ipairs(paths) do
        segs[i] = vim.split(path, "/", { plain = true, trimempty = true })
        depth[i] = 1
    end

    local changed = true
    while changed do
        changed = false

        local groups = {}
        for i = 1, #paths do
            labels[i] = table.concat(segs[i], "/", math.max(1, #segs[i] - depth[i] + 1))
            groups[labels[i]] = groups[labels[i]] or {}
            table.insert(groups[labels[i]], i)
        end

        for _, group in pairs(groups) do
            if #group > 1 then
                for _, i in ipairs(group) do
                    if depth[i] < #segs[i] then
                        depth[i] = depth[i] + 1
                        changed = true
                    end
                end
            end
        end
    end

    return labels
end

-- Opens an interactive fuzzy-find buffer switcher using fzf-lua.
--
-- Lists buffers ordered by most recently used, with smart path disambiguation,
-- devicons, modified indicators, and management actions (switch / delete).
local function smart_buffers()
    local fzf = require("fzf-lua")
    local fzf_utils = require("fzf-lua.utils")
    local devicons = require("nvim-web-devicons")

    local WIN_W = 0.80

    -- Lines look like "<bufnr>\t<display>"; fzf only shows the display part.
    ---@param line? string
    ---@return integer|nil
    local function bufnr_of(line)
        return tonumber((line or ""):match("^(%d+)\t"))
    end

    fzf.fzf_exec(function(cb)
        local buffers = get_buffers()
        local labels = smart_labels(vim.tbl_map(function(b)
            return b.name
        end, buffers))

        -- Subtract 5 columns to account for fzf window borders, padding, and inner spacing.
        local content_w = math.floor(vim.o.columns * WIN_W) - 5
        local num_w = #tostring(vim.fn.bufnr("$"))

        for i, b in ipairs(buffers) do
            local name = vim.fn.fnamemodify(b.name, ":t")
            local icon, hl = devicons.get_icon(name, vim.fn.fnamemodify(name, ":e"), { default = true })

            local mod = b.changed ~= 0 and " ●" or ""
            local num = ("[%" .. num_w .. "d]"):format(b.bufnr)
            local left_w = vim.fn.strdisplaywidth(icon .. " " .. labels[i] .. mod)
            local pad = math.max(1, content_w - left_w - #num)

            cb(("%d\t%s %s%s%s%s"):format(
                b.bufnr,
                hl and fzf_utils.ansi_from_hl(hl, icon) or icon,
                labels[i],
                mod,
                (" "):rep(pad),
                fzf_utils.ansi_codes.magenta(num)
            ))
        end

        cb()
    end, {
        winopts = { width = WIN_W, height = 0.4, preview = { hidden = true } },

        fzf_opts = {
            ["--delimiter"] = "\t",
            ["--with-nth"] = "2..",
        },

        actions = {
            ["default"] = function(selected)
                local bufnr = bufnr_of(selected[1])
                if bufnr then
                    vim.api.nvim_set_current_buf(bufnr)
                end
            end,

            ["ctrl-x"] = {
                reload = true,
                fn = function(selected)
                    for _, line in ipairs(selected) do
                        local bufnr = bufnr_of(line)
                        if bufnr and vim.bo[bufnr].modified then
                            vim.notify(("buffer %d has unsaved changes!"):format(bufnr), vim.log.levels.WARN)
                        elseif bufnr then
                            vim.api.nvim_buf_delete(bufnr, {})
                        end
                    end
                end,
            },
        },
    })
end

return {
    "ibhagwan/fzf-lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local fzf = require("fzf-lua")

        local no_preview = { winopts = { preview = { hidden = true } } }
        fzf.setup({
            files = no_preview,
            oldfiles = no_preview,
        })

        -- vim.ui.select (code actions, code lens...) goes through fzf-lua.
        fzf.register_ui_select()

        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc })
        end

        map("<leader>ff", fzf.files, "find file")
        map("<leader>fg", fzf.live_grep, "search text in files")
        map("<leader>fb", smart_buffers, "find buffer")
        map("<leader>fs", fzf.lgrep_curbuf, "search text on current file")
        map("<leader>fo", fzf.lsp_document_symbols, "search for lsp symbols on current file")
        map("<leader>fu", fzf.undotree, "undo history")
    end,
}
