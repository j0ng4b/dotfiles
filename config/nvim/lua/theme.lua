-- Applies the theme managed by `scripter color-reloader`.
-- Native colorschemes are preferred when available; otherwise, use mini.base16.

local M = {}

local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local palette_file = vim.fs.joinpath(config_home, "nvim", "lua", "colors.lua")
local theme_file = vim.fs.joinpath(config_home, "sysconf", "theme")

-- Native colorscheme overrides by scheme and mode.
M.native = {
    catppuccin = {
        dark = "catppuccin-mocha",
        light = "catppuccin-latte",
    },

    gruvbox = {
        dark = { name = "gruvbox", background = "dark" },
        light = { name = "gruvbox", background = "light" },
    },

    everforest = {
        dark = { name = "everforest", background = "dark" },
        light = { name = "everforest", background = "light" },
    },

    nord = {
        dark = "nord",
    },
}

local function read_theme()
    local file = io.open(theme_file, "r")
    if not file then
        return nil, "dark"
    end

    local theme = file:read("*l") or ""
    file:close()

    local scheme, mode = theme:match("^([^/]+)/(.+)$")
    return scheme or theme, mode or "dark"
end

local function apply_native(scheme, mode)
    local entry = M.native[scheme] and M.native[scheme][mode]
    if not entry then
        return false
    end

    local name = type(entry) == "table" and entry.name or entry
    local background = type(entry) == "table" and entry.background

    if background then
        vim.o.background = background
    end

    local ok = pcall(vim.cmd.colorscheme, name)
    return ok
end

local function apply_palette(mode)
    local ok, palette = pcall(dofile, palette_file)
    if not ok or type(palette) ~= "table" then
        return false
    end

    vim.o.background = mode == "light" and "light" or "dark"
    require("mini.base16").setup({ palette = palette })
    return true
end

function M.reload()
    local scheme, mode = read_theme()

    if scheme and apply_native(scheme, mode) then
        return
    end

    apply_palette(mode)
end

function M.setup()
    M.reload()

    -- :Theme gruvbox/dark | :Theme light | :Theme toggle
    vim.api.nvim_create_user_command("Theme", function(opts)
        vim.system({ "scripter", "color-reloader", "set", opts.args })
    end, {
        nargs = 1,
        desc = "Change the system theme",
    })
end

return M
