-- Filetypes where ufo is disabled entirely.
local IGNORE_FT = { "git", "neo-tree" }

-- Fold chain: LSP -> treesitter -> indent. Each step runs when the previous one
-- raises UfoFallbackException (no LSP client, no parser, ...).
---@param bufnr integer
---@param provider string
---@return fun(err: any): any
local function fallback_to(bufnr, provider)
    return function(err)
        if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, provider)
        end

        return require("promise").reject(err)
    end
end

---@param bufnr integer
---@param filetype string
---@return string|table|fun(): any
local function provider_selector(bufnr, filetype)
    if vim.tbl_contains(IGNORE_FT, filetype) then
        return ""
    end

    return function()
        return require("ufo").getFolds(bufnr, "lsp")
            :catch(fallback_to(bufnr, "treesitter"))
            :catch(fallback_to(bufnr, "indent"))
    end
end

-- Appends " 󰁂 N " (hidden line count) to the folded line, truncating the text
-- to fit.
---@param virt_text table[]
---@param lnum integer
---@param end_lnum integer
---@param width integer
---@param truncate fun(str: string, width: integer): string
---@return table[]
local function fold_text(virt_text, lnum, end_lnum, width, truncate)
    local suffix = (" 󰁂 %d "):format(end_lnum - lnum)
    local target = width - vim.fn.strdisplaywidth(suffix)
    local result, used = {}, 0

    for _, chunk in ipairs(virt_text) do
        local text, hl = chunk[1], chunk[2]
        local w = vim.fn.strdisplaywidth(text)

        if used + w >= target then
            text = truncate(text, target - used)
            result[#result + 1] = { text, hl }

            -- Pad so the suffix stays right-aligned.
            suffix = suffix .. (" "):rep(target - used - vim.fn.strdisplaywidth(text))
            break
        end

        result[#result + 1] = chunk
        used = used + w
    end

    result[#result + 1] = { suffix, "MoreMsg" }
    return result
end

return {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
        local ufo = require("ufo")
        ufo.setup({
            open_fold_hl_timeout = 150,

            close_fold_kinds_for_ft = {
                default = { "imports", "comment" },
            },

            fold_virt_text_handler = fold_text,
            provider_selector = provider_selector,
        })

        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc })
        end

        map("zr", ufo.openFoldsExceptKinds, "open folds but keep foldlevel value")
        map("zm", ufo.closeFoldsWith, "close folds but keep foldlevel value")
        map("zR", ufo.openAllFolds, "open all folds but keep foldlevel value")
        map("zM", ufo.closeAllFolds, "close all folds but keep foldlevel value")

        -- Peek the fold under the cursor; otherwise show LSP hover.
        map("K", function()
            if not ufo.peekFoldedLinesUnderCursor() then
                vim.lsp.buf.hover()
            end
        end, "peek fold / show symbol documentation")

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "neo-tree",
            callback = function()
                vim.schedule(function()
                    ufo.detach()

                    vim.opt_local.foldenable = false
                    vim.opt_local.foldcolumn = "0"
                    vim.opt_local.statuscolumn = ""
                end)
            end,
            desc = "Disable folds and fold column in neo-tree",
        })
    end,
}
