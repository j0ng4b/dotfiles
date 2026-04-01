local map = require("core.utils.map")
local buffer = require("core.utils.buffer")

--  ╦╔═┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐
--  ╠╩╗├┤ └┬┘│││├─┤├─┘└─┐
--  ╩ ╩└─┘ ┴ ┴ ┴┴ ┴┴  └─┘

-- Sane mode switcher from insert/visual/select to normal mode
map({ "i", "v" }, "jk", "<Esc>", { noremap = true })

--------------------
-- Disable arrow keys
--------------------
map({ "i", "" }, "<Up>", "<Nop>")
map({ "i", "" }, "<Left>", "<Nop>")
map({ "i", "" }, "<Right>", "<Nop>")
map({ "i", "" }, "<Down>", "<Nop>")

--------------------
-- Save
--------------------
map({ "i", "n" }, "<C-s>", "<Cmd>w<CR>")
map({ "i", "n" }, "<C-S-s>", "<Cmd>wall<CR>")

--------------------
-- Quit
--------------------
map({ "n" }, "<C-q>", "<Cmd>qall<CR>")
map({ "n" }, "<C-S-q>", "<Cmd>qall!<CR>")

--------------------
-- Buffer
--------------------
map({ "n" }, "bo", "<Cmd>enew<CR>")
map({ "n" }, "bd", function()
    buffer.close()
end)

map({ "n" }, "bn", function()
    buffer.go("next")
end)

map({ "n" }, "bp", function()
    buffer.go("prev")
end)

--------------------
-- Window management
--------------------
map({ "n" }, "wo", "<Cmd>wincmd n<CR>") -- new
map({ "n" }, "wc", "<Cmd>wincmd c<CR>") -- close

map({ "n" }, "we", "<Cmd>wincmd =<CR>") -- equalize windows size
map({ "n" }, "ws", "<Cmd>wincmd s<CR>") -- split horizontal
map({ "n" }, "wv", "<Cmd>wincmd v<CR>") -- split vertical

--------------------
-- Tab management
--------------------
map({ "n" }, "to", "<Cmd>tabnew<CR>") -- new
map({ "n" }, "tc", "<Cmd>tabclose<CR>") -- close

map({ "n" }, "tn", "<Cmd>tabnext<CR>") -- previous
map({ "n" }, "tp", "<Cmd>tabprevious<CR>") -- next

--------------------
-- Move line
--------------------

-- Single line
map({ "n" }, "<A-k>", "<Cmd>move .-2<CR>==") -- move up
map({ "n" }, "<A-j>", "<Cmd>move .+1<CR>==") -- move down

-- Multi line
map({ "v" }, "<A-k>", "<Cmd>move '>+1<CR>gv=gv") -- move up
map({ "v" }, "<A-j>", "<Cmd>move '<-2<CR>gv=gv") -- move down

--------------------
-- Editing
--------------------
map({ "x" }, "p", '"_dP') -- paste without losing register

--------------------
-- Indentation
--------------------
map({ "v" }, "<Tab>", ">gv")
map({ "n" }, "<Tab>", ">>")

map({ "v" }, "<S-Tab>", "<gv")
map({ "n" }, "<S-Tab>", "<<")
