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

        { import = "plugins.coding" },
        { import = "plugins.coding.editing" },
        { import = "plugins.coding.lsp" },
        { import = "plugins.coding.syntax" },

        { import = "plugins.editor" },
        { import = "plugins.git" },
        { import = "plugins.integrations" },
        { import = "plugins.navigation" },

        { import = "plugins.ui" },
        { import = "plugins.ui.alpha" },
        { import = "plugins.ui.animations" },

        { import = "colorschemes" },
    },

    change_detection = {
        enabled = true,
        notify = false,
    },
})

-- Colorschemes re-loader must run after colorschemes load
require("theme").setup()
