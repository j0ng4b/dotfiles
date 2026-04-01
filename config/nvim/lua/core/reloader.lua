local auto = require("core.utils.autocmd")
local file = require("core.utils.file")

local get_theme_file = function()
    local config_home = os.getenv("XDG_CONFIG_HOME")
    if config_home == nil then
        config_home = os.getenv("HOME") .. "/.config"
    end

    return vim.fs.joinpath(config_home, "sysconf", "theme")
end

-- Set colorscheme from file
local theme_name = file.read(get_theme_file())
if theme_name then
    if theme_name == "catppuccin" then
        theme_name = "catppuccin-mocha"
    end

    local status, _ = pcall(vim.cmd, "colorscheme " .. theme_name)
    if not status then
        return
    end
end

-- Trigger re-loader on colorscheme change
auto.group("ColorschemeReloader")
auto.cmd("Colorscheme", "", function()
    vim.schedule(function()
        -- If set from outside do nothing
        if vim.g._update_colorscheme then
            vim.g._update_colorscheme = nil
            return
        end

        local theme_file = get_theme_file()
        theme_name = file.read(theme_file)

        if theme_name ~= vim.g.colors_name then
            if vim.g.colors_name == "catppuccin-mocha" then
                theme_name = "catppuccin"
            else
                theme_name = vim.g.colors_name
            end

            file.write(theme_file, theme_name)
        end
    end)
end, "ColorschemeReloader")
