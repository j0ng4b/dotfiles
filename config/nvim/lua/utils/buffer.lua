--   ╦ ╦┌┬┐┬┬  ┌─┐
--   ║ ║ │ ││  └─┐
--   ╚═╝ ┴ ┴┴─┘└─┘

local M = {}

function M.close(bufnum)
    local bufnr = bufnum or vim.fn.bufnr()
    local winnr = vim.fn.winnr()

    if vim.fn.getbufvar(bufnr, '&modified') ~= 0 then
        print('Can\'t close: the buffer was modified!')
        return
    end

    local windowsBuffer = vim.fn.filter(
        vim.fn.range(1, vim.fn.winnr('$')),
        'winbufnr(v:val) == ' .. bufnr
    )

    local listedBuffers = vim.fn.filter(
        vim.fn.range(1, vim.fn.bufnr('$')),
        'buflisted(v:val) && v:val != ' .. bufnr
    )

    for _, window in ipairs(windowsBuffer) do
        vim.cmd(window .. 'wincmd w')

        local hiddenBuffers = vim.fn.filter(listedBuffers, 'bufwinnr(v:val) < 0')
        local buffers = { unpack(hiddenBuffers), unpack(listedBuffers) }

        if buffers[1] then
            vim.cmd.buffer(buffers[1])
        else
            vim.cmd.enew()
        end
    end

    vim.cmd.bdelete(bufnr)
    vim.cmd(winnr .. 'wincmd w')
end

function M.move(bufcmd)
    if bufcmd ~= 'bnext' and bufcmd ~= 'bprevious' then
        return
    end

    vim.cmd(bufcmd)
    while vim.fn.getbufvar('%', '&buftype') == 'terminal' do
        vim.cmd(bufcmd)
    end
end

return M
