-- Generic names are shown with their folder: "index.ts" -> "components/index.ts".
local GENERIC = {
    index = true,
    init = true,
    main = true,
    mod = true,
    __init__ = true,
}

--- Return file name include path if file name is generic.
---
---@param path string
---
---@return string
local function label(path)
    local name = vim.fn.fnamemodify(path, ":t")
    if GENERIC[vim.fn.fnamemodify(name, ":r")] then
        return vim.fn.fnamemodify(path, ":h:t") .. "/" .. name
    end

    return name
end

--- Return the correspondent icon and color to given file name.
---
---@param name string
---
---@return string[]
local function get_icon(name)
    return require("nvim-web-devicons").get_icon_color(name, nil, {
        default = true,
    })
end

return {
    "b0o/incline.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local icons = require("core.utils.icons")
        local helpers = require("incline.helpers")
        local navic = require("core.utils").safe_require("nvim-navic")

        require("incline").setup({
            render = function(props)
                local buf = props.buf
                local path = vim.api.nvim_buf_get_name(buf)
                local name = path ~= "" and label(path) or "[No Name]"

                local ft_icon, ft_color = get_icon(vim.fn.fnamemodify(name, ":t"))
                local modified = vim.bo[buf].modified
                local readonly = vim.bo[buf].readonly

                local winbar = {
                    ft_icon and {
                        " ",
                        ft_icon,
                        " ",
                        guibg = ft_color,
                        guifg = helpers.contrast_color(ft_color),
                    } or "",

                    " ",
                    { name, gui = modified and "bold,italic" or "" },
                    " ",

                    modified and icons.file.modified .. " " or "",
                    readonly and icons.file.readonly .. " " or "",
                }

                if props.focused and navic then
                    for _, item in ipairs(navic.get_data(buf) or {}) do
                        table.insert(winbar, {
                            { " > ", group = "NavicSeparator" },
                            { item.icon .. " ", group = "NavicIcons" .. item.type },
                            { item.name, group = "NavicText" },
                        })
                    end
                end

                return winbar
            end,

            window = {
                padding = 0,

                placement = {
                    vertical = "top",
                    horizontal = "right",
                },

                margin = {
                    vertical = 0,
                    horizontal = 0,
                },

                overlap = {
                    borders = true,
                },
            },

            hide = {
                cursorline = "focused_win",
            },
        })
    end,
}
