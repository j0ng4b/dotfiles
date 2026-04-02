--  ╔╦╗┌─┐┬┌┐┌  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐
--  ║║║├─┤││││  │  │ ││││├┤ ││ ┬
--  ╩ ╩┴ ┴┴┘└┘  └─┘└─┘┘└┘└  ┴└─┘

-- Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("core")
require("plugins")
require("colorschemes")

-- Colorschemes re-loader must run after colorschemes load
require("core.reloader")
