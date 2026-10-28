-- Applies the theme managed by `scripter color-reloader`.
--
-- Resolution:
--   1. Native colorscheme, when has an entry for the scheme and mode.
--   2. Otherwise `:colorscheme theme-reloader`.

local M = {}

local file = require("core.utils.file")

local config_home = vim.env.XDG_CONFIG_HOME or vim.fs.joinpath(vim.env.HOME, ".config")
local theme_file = vim.fs.joinpath(config_home, "sysconf", "theme")

-- Native colorscheme overrides by scheme.
-- A string is the colorscheme name for any mode; a table maps mode to name,
-- and a missing mode falls back to the base16 palette.
M.native = {
    catppuccin = {
        dark = "catppuccin-mocha",
        light = "catppuccin-latte",
    },

    nord = "nord",
    gruvbox = "gruvbox",
    everforest = "everforest",
}

---@return string scheme, string mode  Defaults to `"", "dark"` when the file is missing.
local function read_theme()
    local theme = vim.trim(file.read(theme_file) or "")
    local scheme, mode = theme:match("^([^/]+)/(.+)$")
    return scheme or theme, mode == "light" and "light" or "dark"
end

---@return boolean applied
local function apply_native(scheme, mode)
    local entry = M.native[scheme]
    if not entry then
        return false
    end

    local name = type(entry) == "table" and entry[mode] or entry
    if type(name) ~= "string" then
        return false
    end

    return pcall(vim.cmd.colorscheme, name)
end

---Applies the base16 palette through colors/theme-reloader.lua.
local function apply_palette()
    local ok, err = pcall(vim.cmd.colorscheme, "theme-reloader")
    if not ok then
        vim.notify("[theme] " .. err, vim.log.levels.WARN)
    end
end

function M.reload()
    local scheme, mode = read_theme()

    -- Drop highlights from the previous theme so they don't leak into the new
    -- one.
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = nil

    vim.o.background = mode
    if not apply_native(scheme, mode) then
        apply_palette()
    end
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
