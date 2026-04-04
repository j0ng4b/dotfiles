--  ╔╦╗┌─┐┬┌┐┌  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐
--  ║║║├─┤││││  │  │ ││││├┤ ││ ┬
--  ╩ ╩┴ ┴┴┘└┘  └─┘└─┘┘└┘└  ┴└─┘

-- Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("core")

--   ╔═╗┬  ┬ ┬┌─┐┬┌┐┌┌─┐
--   ╠═╝│  │ ││ ┬││││└─┐
--   ╩  ┴─┘└─┘└─┘┴┘└┘└─┘

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
        { import = "colorschemes" },
    },

    change_detection = {
        enabled = true,
        notify = false,
    },
})

-- Colorschemes re-loader must run after colorschemes load
require("core.reloader")
