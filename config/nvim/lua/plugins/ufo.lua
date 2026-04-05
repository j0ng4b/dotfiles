local function get_provider(bufnr, filetype)
    local ignore_ft = { "git", "neo-tree" }
    if vim.tbl_contains(ignore_ft, filetype) then
        return ""
    end

    return function()
        local ufo = require("ufo")

        local function handle_exception(err, provider_name)
            if type(err) == "string" and err:match("UfoFallbackException") then
                return ufo.getFolds(bufnr, provider_name)
            end

            return require("promise").reject(err)
        end

        return ufo.getFolds(bufnr, "lsp")
            :catch(function(err)
                return handle_exception(err, "treesitter")
            end)
            :catch(function(err)
                return handle_exception(err, "indent")
            end)
    end
end

local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
end

local config = function()
    local ufo = require("ufo")
    ufo.setup({
        open_fold_hl_timeout = 150,

        close_fold_kinds_for_ft = {
            default = { "imports", "comment" },
        },

        enable_get_fold_virt_text = true,
        fold_virt_text_handler = handler,
        provider_selector = get_provider,
    })

    vim.keymap.set({ "n" }, "zr", ufo.openFoldsExceptKinds, { desc = "open folds but keep foldlevel value" })
    vim.keymap.set({ "n" }, "zm", ufo.closeFoldsWith, { desc = "close folds but keep foldlevel value" })

    vim.keymap.set({ "n" }, "zR", ufo.openAllFolds, { desc = "open all folds but keep foldlevel value" })
    vim.keymap.set({ "n" }, "zM", ufo.closeAllFolds, { desc = "close all folds but keep foldlevel value" })

    vim.keymap.set({ "n" }, "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        end
    end)
end

return {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = config,
}
