--   ╔═╗┬ ┬┌┬┐┌─┐┌─┐┌┬┐┌┬┐┌─┐
--   ╠═╣│ │ │ │ ││  │││ ││└─┐
--   ╩ ╩└─┘ ┴ └─┘└─┘┴ ┴─┴┘└─┘

---@param name string
---@return integer
local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = augroup("HighlightOnSearch"),
    desc = "Highlight matches only while searching",
    pattern = { "/", "?" },
    callback = function(args)
        vim.o.hlsearch = args.event == "CmdlineEnter"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("DockerComposeSpell"),
    desc = "Disable spell in docker compose files",
    pattern = "yaml.docker-compose",
    callback = function()
        vim.opt_local.spell = false
    end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = augroup("ChangeTimeoutLenByMode"),
    desc = "Adjust mapping timeout according to mode",
    -- Patterns are "old_mode:new_mode" ("\x16" is <C-v>).
    --
    -- Fires only when entering or leaving visual (v, V, <C-v>), insert (i) or
    -- replace (R).
    pattern = {
        "*:[vV\x16iR]*",
        "[vV\x16iR]*:*",
    },
    callback = function(args)
        local new_mode = args.match:gsub(".:", "")
        local short_timeout = new_mode:match("^[vV\x16iR]") ~= nil

        -- Short in insert/visual/replace (so mappings like 'jk' don't lag),
        -- long in normal mode (room to type <leader> sequences)
        vim.o.timeoutlen = short_timeout and 250 or 1000
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup("PersistHighlights"),
    desc = "Re-apply custom highlights after a colorscheme change",
    callback = function()
        vim.cmd.highlight({ "PmenuSel", "blend=0" }) -- selected item stays opaque
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("CreateParentDirs"),
    desc = "Create missing parent directories when saving",
    callback = function(args)
        -- Skip URLs and plugin buffers (oil://, scp://, ...)
        if args.match:match("^%w[%w+.-]*://") then
            return
        end

        vim.fn.mkdir(vim.fn.fnamemodify(args.file, ":p:h"), "p")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("CloseWithQ"),
    pattern = { "help", "qf", "man", "checkhealth", "notify", "query" },
    desc = "Close utility windows with q",
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = args.buf,
            silent = true,
        })
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup("TerminalUI"),
    desc = "Clean UI in terminal buffers",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.spell = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
    end,
})
