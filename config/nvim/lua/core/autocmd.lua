local auto = require('core.utils.autocmd')

-- Highlight search only searching
local update_search_higlight = function(event)
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype ~= '/' and cmdtype ~= '?' then
        return
    end

    if event == 'enter' then
        vim.opt.hlsearch = true
    elseif event == 'change' then
        if vim.fn.exists('minimap#vim#UpdateColorSearch') ~= 0 then
            -- For some way NeoVim set v:hlsearch to 0 at every command line
            -- change but minimap relies on v:hlsearch being 1 so set hlsearch
            -- again set v:hlsearch to 1.
            vim.opt.hlsearch = true

            vim.fn['minimap#vim#UpdateColorSearch'](vim.fn.getcmdline())
        end
    elseif event == 'leave' then
        vim.opt.hlsearch = false
    end
end


auto.group('VimHighlightOnSearch')
auto.cmd('CmdlineEnter', '/,?', function(args)
    update_search_higlight('enter')
end, 'VimHighlightOnSearch')

auto.cmd('CmdlineChanged', '/,?', function()
    update_search_higlight('change')
end, 'VimHighlightOnSearch')

auto.cmd('CmdlineLeave', '/,?', function()
    update_search_higlight('leave')
end, 'VimHighlightOnSearch')


-- Timeout
local update_timeoutlen = function()
    local mode = vim.api.nvim_get_mode().mode

    if mode == 'i' or mode == 'R' or mode == 'v' or mode == 'V' or mode == '\x16' then
        vim.opt.timeoutlen = 250
    else
        vim.opt.timeoutlen = 1000
    end
end

auto.group('ChangeTimeoutLenByMode')
auto.cmd('ModeChanged', '*:[vV\x16iR]*', update_timeoutlen, 'ChangeTimeoutLenByMode')
auto.cmd('ModeChanged', '[vV\x16iR]*:*', update_timeoutlen, 'ChangeTimeoutLenByMode')

