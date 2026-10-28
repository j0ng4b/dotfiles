local M = {}

local ignored_buftypes = {
    help = true,
    qf = true,
    terminal = true,
    prompt = true,
}

local ignored_filetypes = {
    lazy = true,
    ["neo-tree"] = true,
    TelescopePrompt = true,
    alpha = true,
    mason = true,
}

---@param bufnr integer? Buffer number; defaults to the current buffer.
---@return boolean ignored Whether the buffer should be ignored.
local function is_ignored(bufnr)
    local bt = vim.bo[bufnr or 0].buftype
    local ft = vim.bo[bufnr or 0].filetype
    return ignored_buftypes[bt] or ignored_filetypes[ft]
end

---A buffer that can take over a window when another one is closed.
---@param bufnr integer
---@param target integer Buffer being closed.
---@return boolean
local function is_candidate(bufnr, target)
    return bufnr ~= target
        and bufnr > 0
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].buflisted
        and not is_ignored(bufnr)
end

---Picks the buffer that should replace `target` in `win`.
---Preference: alternate buffer > listed buffer not shown anywhere > any listed
---buffer.
---@param target integer
---@param win integer
---@return integer? bufnr nil when there is nothing suitable.
local function find_replacement(target, win)
    local alternate = vim.api.nvim_win_call(win, function()
        return vim.fn.bufnr("#")
    end)

    if is_candidate(alternate, target) then
        return alternate
    end

    local fallback = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if is_candidate(buf, target) then
            -- If the buffer isn't displayed on none window use it
            if #vim.fn.win_findbuf(buf) == 0 then
                return buf
            end
            fallback = fallback or buf
        end
    end

    return fallback
end

---@param bufnr integer
---@param force boolean?
local function delete_buffer(bufnr, force)
    pcall(vim.cmd, string.format("bdelete%s %d", force and "!" or "", bufnr))
end

---Closes a buffer while preserving the current window layout.
---Windows displaying the target buffer are switched to another listed buffer
---(or a throwaway empty one) before the target is deleted.
---Refuses to close a modified buffer. Special buffers are simply deleted.
---@param bufnr integer? Buffer number to close; defaults to the current buffer.
---@return nil
function M.close(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    -- Special buffers (terminal, help, qf, neo-tree...) bypass the layout
    -- logic.
    --
    -- Checked before `modified` because terminals are always flagged as
    -- modified.
    if is_ignored(bufnr) then
        delete_buffer(bufnr, vim.bo[bufnr].buftype == "terminal")
        return
    end

    if vim.bo[bufnr].modified then
        vim.notify("Can't close: the buffer was modified!", vim.log.levels.WARN)
        return
    end

    -- Swap the buffer in every window showing it, without moving focus.
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        local replacement = find_replacement(bufnr, win)

        if not replacement then
            -- Empty buffer that disappears as soon as it is replaced.
            replacement = vim.api.nvim_create_buf(true, false)
            vim.bo[replacement].bufhidden = "wipe"
        end

        vim.api.nvim_win_set_buf(win, replacement)
    end

    delete_buffer(bufnr)
end

---Navigates to the next or previous non-ignored buffer.
---Uses bufferline commands when available, falling back to native commands.
---Does nothing when the current buffer is ignored.
---@param direction "next"|"prev"
---@return nil
function M.go(direction)
    if direction ~= "next" and direction ~= "prev" then
        error(("Invalid buffer direction: %s"):format(tostring(direction)))
    end

    if is_ignored() then
        return
    end

    local next_dir = direction == "next"
    local cmd

    -- Prefer bufferline to respect the visual tab order, without force-loading it.
    if vim.fn.exists(":BufferLineCycleNext") == 2 then
        cmd = next_dir and "BufferLineCycleNext" or "BufferLineCyclePrev"
    else
        cmd = next_dir and "bnext" or "bprevious"
    end

    local start_buf = vim.api.nvim_get_current_buf()
    -- Upper bound guarantees termination even if the cycle never returns to start_buf.
    local max_attempts = #vim.api.nvim_list_bufs()

    for _ = 1, max_attempts do
        vim.cmd(cmd)

        local current = vim.api.nvim_get_current_buf()
        if current == start_buf or not is_ignored(current) then
            return
        end
    end
end

return M
