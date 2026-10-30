--  ╔╦╗┌─┐┬┌┐┌  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐
--  ║║║├─┤││││  │  │ ││││├┤ ││ ┬
--  ╩ ╩┴ ┴┴┘└┘  └─┘└─┘┘└┘└  ┴└─┘

-- Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Byte-code cache for Lua modules; faster startup.
vim.loader.enable()

require("core")

--   ╔═╗┬  ┬ ┬┌─┐┬┌┐┌┌─┐
--   ╠═╝│  │ ││ ┬││││└─┐
--   ╩  ┴─┘└─┘└─┘┴┘└┘└─┘

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })

    if vim.v.shell_error ~= 0 then
        error("Failed to clone lazy.nvim:\n" .. out)
    end
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins.coding" },
        { import = "plugins.coding.editing" },
        { import = "plugins.coding.syntax" },

        { import = "plugins.editor" },
        { import = "plugins.git" },
        { import = "plugins.integrations" },
        { import = "plugins.navigation" },

        { import = "plugins.ui" },
        { import = "plugins.ui.alpha" },
        { import = "plugins.ui.animations" },

        { import = "plugins.miscellaneous" },

        { import = "colorschemes" },
    },

    install = {
        -- Colorscheme used while installing plugins on the first run.
        colorscheme = { "habamax" }
    },

    change_detection = {
        enabled = true,
        notify = false,
    },

    performance = {
        rtp = {
            -- Built-in plugins never used.
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin"
            },
        },
    },
})

-- Colorschemes re-loader must run after colorschemes load
require("theme").setup()
