local status, incline = pcall(require, 'incline')
if not status then
    return
end

local icons = require('utils.icons')
local navic = require('nvim-navic')
local helpers = require('incline.helpers')
local devicons = require('nvim-web-devicons')

local render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
    if filename == '' then
        filename = '[No Name]'
    end

    local ft_icon, ft_color = devicons.get_icon_color(filename)
    local modified = vim.bo[props.buf].modified
    local readonly = vim.bo[props.buf].readonly

    local winbar = {
        ft_icon and {
            ' ', ft_icon,  ' ',
            guibg = ft_color,
            guifg = helpers.contrast_color(ft_color)
        } or '',

        ' ',
        { filename, gui = modified and 'bold,italic' or '' },
        ' ',
        modified and icons.file.modified .. ' ' or '',
        readonly and icons.file.readonly .. ' ' or ''
    }

    if props.focused then
        for _, item in ipairs(navic.get_data(props.buf) or {}) do
            table.insert(winbar, {
                { ' > ', group = 'NavicSeparator' },
                { item.icon .. ' ', group = 'NavicIcons' .. item.type },
                { item.name, group = 'NavicText' },
            })
        end
    end

    return winbar
end

incline.setup({
    render = render,

    window = {
        padding = 0,
        margin = {
            vertical = 0,
            horizontal = 0,
        },

        overlap = {
            borders = true,
        },
    },

    hide = {
        cursorline = 'focused_win',
    },
})

