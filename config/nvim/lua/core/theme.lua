local auto = require("core.utils.autocmd")
local file = require("core.utils.file")

local M = {}

local map = {
    catppuccin = {
        dark = "catppuccin-mocha",
        light = "catppuccin-latte",
    },

    gruvbox = {
        dark = { scheme = "gruvbox", background = "dark" },
        light = { scheme = "gruvbox", background = "light" },
    },
}

local function current_state()
    return {
        scheme = vim.g.colors_name,
        background = vim.o.background,
    }
end

local function get_theme_file()
    local config_home = os.getenv("XDG_CONFIG_HOME")
    if config_home == nil then
        config_home = os.getenv("HOME") .. "/.config"
    end

    return vim.fs.joinpath(config_home, "sysconf", "theme")
end

local function parse(input)
    local theme, mode = input:match("^([^/]+)/(.+)$")
    if not theme then
        return input, "dark"
    end
    return theme, mode
end

local function normalize(resolved)
    if type(resolved) == "string" then
        return {
            scheme = resolved,
            background = nil,
        }
    end

    return {
        scheme = resolved.scheme,
        background = resolved.background,
    }
end

local function is_same(current, target)
    if current.scheme ~= target.scheme then
        return false
    end

    if target.background and current.background ~= target.background then
        return false
    end

    return true
end

function M.apply(input, from_shell)
    local theme, mode = parse(input)
    local entry = map[theme]

    if not entry then
        return
    end

    local resolved = entry[mode] or entry.dark
    local target = normalize(resolved)
    local current = current_state()

    if is_same(current, target) then
        return
    end

    if from_shell then
        vim.g._update_colorscheme = 1
    end

    if target.background then
        vim.o.background = target.background
    end

    if target.scheme then
        vim.cmd.colorscheme(target.scheme)
    end
end

function M.setup()
    local theme_name = file.read(get_theme_file())
    if theme_name then
        M.apply(theme_name, false)
    end

    auto.cmd("Colorscheme", "", function()
        vim.schedule(function()
            -- If set from outside do nothing to avoid looping
            if vim.g._update_colorscheme then
                vim.g._update_colorscheme = nil
                return
            end

            local current = vim.g.colors_name
            local bg = vim.o.background

            local reverse = {
                ["catppuccin-mocha"] = "catppuccin/dark",
                ["catppuccin-latte"] = "catppuccin/light",
                ["gruvbox"] = "gruvbox/" .. bg,
            }

            local result = reverse[current]
            if result then
                file.write(get_theme_file(), result)
            end
        end)
    end, "ColorschemeReloader")
end

return M
