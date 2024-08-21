local auto = require('core.utils.autocmd')
local json = require('core.utils.json')

-- Load colorscheme
-- Default colorscheme
local colorscheme = 'everblush'

local config_home = os.getenv('XDG_CONFIG_HOME') or '~/.config/'
local config_file = vim.fs.joinpath(config_home, 'system-configs.json')
local config = json.read(config_file)
if config and config.theme then
    colorscheme = config.theme
end

local status, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not status then
    return
end

-- Trigger reloader on colorscheme change
auto.group('ColorschemeReloader')
auto.cmd('Colorscheme', '', function()
    vim.schedule(function()
        if vim.g._update_colorscheme then
            vim.g._update_colorscheme = nil
            return
        end

        local config_home = os.getenv('XDG_CONFIG_HOME') or '~/.config/'
        local config_file = vim.fs.joinpath(config_home, 'system-configs.json')
        local config = json.read(config_file)

        if config.theme ~= vim.g.colors_name then
            if vim.g.colors_name == 'catppuccin-mocha' then
                config.theme = 'catppuccin'
            else
                config.theme = vim.g.colors_name
            end

            json.write(config_file, config)
        end
    end)
end, 'ColorschemeReloader')

