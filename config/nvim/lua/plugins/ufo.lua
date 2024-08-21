local config = function()
    local ufo = require('ufo')
    local map = require('core.utils.map')

    map({ 'n' }, 'zr', ufo.openFoldsExceptKinds, { desc = 'open folds but keep foldlevel value' })
    map({ 'n' }, 'zm', ufo.closeFoldsWith, { desc = 'close folds but keep foldlevel value' })

    map({ 'n' }, 'zR', ufo.openAllFolds, { desc = 'open all folds but keep foldlevel value' })
    map({ 'n' }, 'zM', ufo.closeAllFolds, { desc = 'close all folds but keep foldlevel value' })

    map({ 'n' }, 'K', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()

        if not winid then
            vim.lsp.buf.hover()
        end
    end)


    local function get_provider(bufnr)
        local function handle_exception(err, provider_name)
            if type(err) == 'string' and err:match('UfoFallbackException') then
                return ufo.getFolds(bufnr, provider_name)
            end

            return require('promise').reject(err)
        end

        return ufo.getFolds(bufnr, 'lsp'):catch(function(err)
            return handle_exception(err, 'treesitter')
        end):catch(function(err)
            return handle_exception(err, 'indent')
        end)
    end

    local handler = function(virt_text, lnum, end_lnum, width, truncate, ctx)
        local new_virt_text = {}

        local end_line_virt_text = {}
        local end_line_real_text = ''

        for _, virt in ipairs(ctx.get_fold_virt_text(end_lnum)) do
            if virt[2] ~= 'UfoFoldedFg' then
                table.insert(end_line_virt_text, virt)
                end_line_real_text = end_line_real_text .. virt[1]
            end
        end

        local suffix = (' 󰁂 %d '):format(end_lnum - lnum)

        local cur_width = 0
        local max_width = width - vim.fn.strdisplaywidth(suffix)
            - vim.fn.strdisplaywidth(end_line_real_text)

        for _, chunk in ipairs(virt_text) do
            local text = chunk[1]
            local text_width = vim.fn.strdisplaywidth(text)

            if max_width > cur_width + text_width then
                table.insert(new_virt_text, chunk)
            else
                text = truncate(text, max_width - cur_width)
                table.insert(new_virt_text, { text, chunk[2] })

                text_width = vim.fn.strdisplaywidth(text)
                if cur_width + text_width < max_width then
                    suffix = suffix .. (' '):rep(max_width - cur_width - text_width)
                end

                break
            end

            cur_width = cur_width + text_width
        end

        table.insert(new_virt_text, { suffix, 'MoreMsg' })
        for _, virt in ipairs(end_line_virt_text) do
            table.insert(new_virt_text, virt)
        end

        return new_virt_text
    end


    local fold_methods_by_filetype = {
        git = '',
    }

    ufo.setup({
        open_fold_hl_timeout = 150,

        close_fold_kinds_for_ft = {
            default = { 'imports', 'comment' },
        },

        enable_get_fold_virt_text = true,
        fold_virt_text_handler = handler,

        provider_selector = function(bufnr, filetype, buftype)
            return fold_methods_by_filetype[filetype] or get_provider
        end
    })
end


return {
    'kevinhwang91/nvim-ufo',
    config = config,
    dependencies = 'kevinhwang91/promise-async',
}

