local auto = require('core.utils.autocmd')

-- Highlight search only searching
auto.group('VimHighlightOnSearch')
auto.cmd('CmdlineEnter', '/,?', 'set hlsearch', 'VimHighlightOnSearch')
auto.cmd('CmdlineLeave', '/,?', 'set nohlsearch', 'VimHighlightOnSearch')

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

