local auto = require('core.utils.autocmd')
local file = require('core.utils.file')

-- Load colorscheme
-- Default colorscheme
local colorscheme = 'catppuccin-mocha'

local config_home = os.getenv('XDG_CONFIG_HOME')
local config_file = vim.fs.joinpath(config_home, 'sysconf', 'theme')

local theme = file.read(config_file)
if theme then
    if theme == 'catppuccin' then
        theme = 'catppuccin-mocha'
    end

    local status, _ = pcall(vim.cmd, 'colorscheme ' .. theme)
    if not status then
        return
    end
end


-- Trigger re-loader on colorscheme change
auto.group('ColorschemeReloader')
auto.cmd('Colorscheme', '', function()
    vim.schedule(function()
        if vim.g._update_colorscheme then
            vim.g._update_colorscheme = nil
            return
        end

        local config_home = os.getenv('XDG_CONFIG_HOME')
        local config_file = vim.fs.joinpath(config_home, 'sysconf', 'theme')

        local theme = file.read(config_file)
        if theme ~= vim.g.colors_name then
            if vim.g.colors_name == 'catppuccin-mocha' then
                theme = 'catppuccin'
            else
                theme = vim.g.colors_name
            end

            file.write(config_file, theme)
        end
    end)
end, 'ColorschemeReloader')

