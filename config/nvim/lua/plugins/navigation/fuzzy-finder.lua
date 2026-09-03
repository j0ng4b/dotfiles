local function smart_labels(paths)
    local parts = {}
    for i, path in ipairs(paths) do
        parts[i] = vim.split(path, "/", { plain = true, trimempty = true })
    end

    local function suffix(segs, n)
        local from = math.max(1, #segs - n + 1)
        local out = {}
        for k = from, #segs do
            out[#out + 1] = segs[k]
        end

        return table.concat(out, "/")
    end

    local labels = {}
    for i, segs_i in ipairs(parts) do
        local need = 1
        while need <= #segs_i do
            local cand = suffix(segs_i, need)
            local unique = true
            for j, segs_j in ipairs(parts) do
                if i ~= j and suffix(segs_j, math.min(need, #segs_j)) == cand then
                    unique = false
                    break
                end
            end

            if unique then
                labels[i] = cand
                break
            end

            need = need + 1
        end

        labels[i] = labels[i] or (segs_i[#segs_i] or paths[i])
    end

    return labels
end

local function smart_buffers()
    local fzf = require("fzf-lua")
    local devicons = require("nvim-web-devicons")

    local bufs = vim.api.nvim_list_bufs()
    local items, paths = {}, {}

    for _, b in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
            local name = vim.api.nvim_buf_get_name(b)
            if name ~= "" then
                paths[#paths + 1] = name
                items[#items + 1] = { bufnr = b, path = name, changed = vim.bo[b].modified }
            end
        end
    end

    if #items == 0 then
        vim.notify("No buffers found", vim.log.levels.INFO)
        return
    end

    local labels = smart_labels(paths)

    local max_bufnr_w = 1
    for _, it in ipairs(items) do
        max_bufnr_w = math.max(max_bufnr_w, #tostring(it.bufnr))
    end

    local WIN_W = 0.80
    local content_max_w = math.floor(vim.o.columns * WIN_W) - 5

    fzf.fzf_exec(function(cb)
        for i, item in ipairs(items) do
            local ext = vim.fn.fnamemodify(item.path, ":e")
            local icon, hl = devicons.get_icon(item.path, ext, { default = true })
            local icon_colored = hl and fzf.utils.ansi_from_hl(hl, icon) or icon

            local mod = item.changed and " ●" or ""

            local bufnr_str = "[" .. string.format("%" .. max_bufnr_w .. "d", item.bufnr) .. "]"
            local bufnr_colored = fzf.utils.ansi_codes.magenta(bufnr_str)

            local left_w = vim.fn.strdisplaywidth(icon .. " " .. labels[i] .. mod)
            local right_w = #bufnr_str

            local pad = math.max(1, content_max_w - left_w - right_w)
            local pad_str = string.rep(" ", pad)

            local display = icon_colored .. " " .. labels[i] .. mod .. pad_str .. bufnr_colored
            cb(item.path .. "\t" .. display)
        end
        cb()
    end, {
        winopts = {
            width = WIN_W,
        },

        fzf_opts = {
            ["--delimiter"] = "\t",
            ["--with-nth"] = "2..",
            ["--nth"] = "1",
        },

        actions = {
            ["default"] = function(selected)
                local s = selected and selected[1]
                if not s then
                    return
                end

                local fpath = s:match("^(.-)\t")
                for _, item in ipairs(items) do
                    if item.path == fpath then
                        vim.api.nvim_set_current_buf(item.bufnr)
                        return
                    end
                end
            end,
        },
    })
end

return {
    "ibhagwan/fzf-lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local fzf = require("fzf-lua")
        fzf.setup({
            files = {
                winopts = { preview = { hidden = true } },
            },

            oldfiles = {
                winopts = { preview = { hidden = true } },
            },

            buffers = {
                winopts = { preview = { hidden = true } },
            },
        })

        fzf.register_ui_select()

        vim.keymap.set({ "n" }, "<leader>ff", fzf.files, {
            desc = "find file",
        })

        vim.keymap.set({ "n" }, "<leader>fg", fzf.live_grep, {
            desc = "search text in files",
        })

        vim.keymap.set({ "n" }, "<leader>fb", smart_buffers, {
            desc = "find buffer",
        })

        vim.keymap.set({ "n" }, "<leader>fs", fzf.lgrep_curbuf, {
            desc = "search text on current file",
        })

        vim.keymap.set({ "n" }, "<leader>fo", fzf.lsp_document_symbols, {
            desc = "search for lsp symbols on current file",
        })

        vim.keymap.set({ "n" }, "<leader>fu", fzf.undotree, {
            desc = "undo history",
        })
    end,
}
