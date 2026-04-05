--  ╔╗ ┬ ┬┌─┐┌─┐┌─┐┬─┐
--  ╠╩╗│ │├┤ ├┤ ├┤ ├┬┘
--  ╚═╝└─┘└  └  └─┘┴└─

local M = {}

local ignored_buftypes = {
    "help",
    "qf",
    "terminal",
    "prompt",
}

local ignored_filetypes = {
    "lazy",
    "neo-tree",
    "TelescopePrompt",
    "alpha",
    "mason",
}

local function is_ignored(bufnr)
    bufnr = bufnr or 0
    local bt = vim.bo[bufnr].buftype
    local ft = vim.bo[bufnr].filetype
    return vim.tbl_contains(ignored_buftypes, bt) or vim.tbl_contains(ignored_filetypes, ft)
end

-- Safely closes a buffer without messing up the window layout (splits).
-- It replaces the dying buffer with another open buffer or an empty one before deleting it.
function M.close(bufnum)
    local bufnr = bufnum or vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()

    if vim.bo[bufnr].modified then
        vim.notify("Can't close: the buffer was modified!", vim.log.levels.WARN)
        return
    end

    if is_ignored(bufnr) then
        vim.cmd("silent! bdelete " .. bufnr)
        return
    end

    -- List all window with the buffer marked to be deleted
    local windowsBuffer = vim.fn.filter(vim.fn.range(1, vim.fn.winnr("$")), "winbufnr(v:val) == " .. bufnr)

    -- List all buffers available excepted the buffer marked to be deleted
    local listedBuffers = vim.fn.filter(vim.fn.range(1, vim.fn.bufnr("$")), "buflisted(v:val) && v:val != " .. bufnr)

    for _, window in ipairs(windowsBuffer) do
        vim.cmd(window .. "wincmd w")

        local hiddenBuffers = vim.fn.filter(listedBuffers, "bufwinnr(v:val) < 0")
        local buffers = { unpack(hiddenBuffers), unpack(listedBuffers) }

        -- Try to set a new buffer to the window with marked buffer
        -- priority: hidden buffer > any visible buffer > new empty buffer
        if buffers[1] then
            vim.cmd.buffer(buffers[1])
        else
            vim.cmd.enew()
        end
    end

    vim.cmd("silent! bdelete " .. bufnr)
    pcall(vim.api.nvim_set_current_win, winid)
end

-- Cycles through buffers (next/prev) while skipping ignored filetypes/buftypes
function M.go(direction)
    if direction ~= "next" and direction ~= "prev" then
        error("Invalid buffer direction: " .. direction)
    end

    if is_ignored() then
        return
    end

    -- Use bufferline commands if installed to respect visual tab order,
    -- fallback to native commands
    local cmd = nil
    local is_bufferline = pcall(require, "bufferline")
    if is_bufferline then
        cmd = direction == "next" and "BufferLineCycleNext" or "BufferLineCyclePrev"
    else
        cmd = direction == "next" and "bnext" or "bprevious"
    end

    local start_buf = vim.api.nvim_get_current_buf()

    vim.cmd(cmd)
    while is_ignored() do
        local cur_buf = vim.api.nvim_get_current_buf()
        if cur_buf == start_buf then
            break
        end

        vim.cmd(cmd)
    end
end

return M
