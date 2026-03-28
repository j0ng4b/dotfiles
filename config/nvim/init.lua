require("core.settings")
require("core.autocmd")

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

-- Some maps requires plugins
require("core.keymaps")

-- Colorschemes re-loader must run after plugins and colorschemes load
require("core.reloader")
