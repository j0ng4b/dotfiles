-- TODO: colorscheme auto reload mechanics
local colorscheme = 'catppuccin'

-- Load colorscheme configurations
local configs = vim.api.nvim_get_runtime_file('lua/colorscheme/config/*.lua', true)
for _, config in ipairs(configs) do
    if vim.fn.filereadable(config) == 1 then
        local filename = config:match('.+/([^/]+%.lua)'):gsub('.lua', '')
        require('colorscheme.config.' .. filename)
    end
end

-- Load colorscheme
local status, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not status then
    return
end

