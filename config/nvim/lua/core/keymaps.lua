--   ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--   ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--   ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

local map = vim.keymap.set
local buffer = require("core.utils.buffer")

-- Mode switch
map({ "i", "v" }, "jk", "<Esc>", { desc = "Move back to normal mode" })
map({ "t" }, "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Disable arrow keys.
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
    map({ "", "i" }, key, "<Nop>", { desc = "Disable arrow keys" })
end

-- Move by screen line on wrapped lines.
-- With a count use real lines.
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (screen line)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (screen line)" })

-- Save
map({ "n", "i", "x" }, "<C-s>", "<Cmd>update<CR>", { desc = "Save (if modified)" })
map({ "n", "i", "x" }, "<C-S-s>", "<Cmd>wall<CR>", { desc = "Save all" })

-- Quit
map({ "n" }, "<C-q>", "<Cmd>qall<CR>", { desc = "Quit all (asks to save)" })
map({ "n" }, "<C-S-q>", "<Cmd>qall!<CR>", { desc = "Quit all, discarding changes" })

-- Buffers
map({ "n" }, "bo", "<Cmd>enew<CR>", { desc = "New buffer" })

map({ "n" }, "bd", function()
    buffer.close()
end, { desc = "Close buffer" })

map({ "n" }, "bn", function()
    buffer.go("next")
end, { desc = "Next buffer" })

map({ "n" }, "bp", function()
    buffer.go("prev")
end, { desc = "Previous buffer" })

-- Window management
map({ "n" }, "wo", "<Cmd>wincmd n<CR>", { desc = "New window" })
map({ "n" }, "wc", "<Cmd>wincmd c<CR>", { desc = "Close window" })

map({ "n" }, "we", "<Cmd>wincmd =<CR>", { desc = "Equalize window sizes" })
map({ "n" }, "ws", "<Cmd>wincmd s<CR>", { desc = "Split horizontal" })
map({ "n" }, "wv", "<Cmd>wincmd v<CR>", { desc = "Split vertical" })

map({ "n" }, "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Go to left window" })
map({ "n" }, "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Go to bottom window" })
map({ "n" }, "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Go to top window" })
map({ "n" }, "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Go to right window" })

-- Tab management
map({ "n" }, "to", "<Cmd>tabnew<CR>", { desc = "New tab" })
map({ "n" }, "tc", "<Cmd>tabclose<CR>", { desc = "Close tab" })

map({ "n" }, "tn", "<Cmd>tabnext<CR>", { desc = "Next tab" })
map({ "n" }, "tp", "<Cmd>tabprevious<CR>", { desc = "Previous tab" })

-- Move single line
map({ "n" }, "<A-k>", "<Cmd>move .-2<CR>==", { desc = "Move line up" })
map({ "n" }, "<A-j>", "<Cmd>move .+1<CR>==", { desc = "Move line down" })

-- Move multi line
--
-- Must be ":" and not <Cmd> because ":" leaves visual mode, which updates the
-- '< and '> marks (and prefills the range).
map({ "x" }, "<A-k>", ":move '<-2<CR>gv=gv", {
    silent = true,
    desc = "Move selection up",
})

map({ "x" }, "<A-j>", ":move '>+1<CR>gv=gv", {
    silent = true,
    desc = "Move selection down",
})

-- Editing
map({ "x" }, "p", '"_dP', { desc = "Paste without loses clipboard content" })

-- Indentation
map({ "x" }, "<Tab>", ">gv", { desc = "Indent and keep selection" })
map({ "x" }, "<S-Tab>", "<gv", { desc = "Dedent and keep selection" })

-- Diagnostics
map({ "n" }, "<Leader>dv", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

map({ "n" }, "<Leader>dp", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map({ "n" }, "<Leader>dn", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
