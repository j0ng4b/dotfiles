-- Colorscheme `theme-reloader`: base16 fallback used when the current theme has
-- no native colorscheme.

local utils = require("core.utils")

-- `dofile` instead of `require`: the palette changes whenever the theme does,
-- so it must never come from the module cache.
local palette_file = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "colors.lua")
local ok, palette = pcall(dofile, palette_file)
if not ok or type(palette) ~= "table" then
    error(("could not load palette %s: %s"):format(palette_file, tostring(palette)), 0)
end

local base16_pro = utils.safe_require("base16-pro-max")
if base16_pro then
    base16_pro.setup({
        colors = palette,
        styles = { italic = true },
        plugins = { enable_all = true },
    })

    -- Applies base16-pro-max highlights
    base16_pro.colorscheme()

    -- Must come after the line above, which sets its own name.
    vim.g.colors_name = "theme-reloader"
    return
end

local mini_base16 = utils.safe_require("mini.base16")
if mini_base16 then
    -- mini.base16 only creates highlight groups, it does not register a
    -- colorscheme, so the name must be set after setup().
    mini_base16.setup({ palette = palette })
    vim.g.colors_name = "theme-reloader"
    return
end

error("install base16-pro-max.nvim or mini.base16", 0)
