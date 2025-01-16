local button = function(text, shortcut, action)
    return {
        type = 'button',
        val = text,

        on_press = function()
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(shortcut, true, false, true),
                'normal',
                false
            )
        end,

        opts = {
            position = 'center',

            cursor = 2,
            width = 35,

            keymap = {
                'n', shortcut, action,

                {
                    noremap = true,
                    silent = true
                },
            },

            shortcut = shortcut,
            align_shortcut = 'right',
        },
    }
end

local layout = function()
    local centralize = function(layout)
        function get_height(layout)
            local height = 0

            for _, item in ipairs(layout) do
                if item.type == 'group' then
                    if item.opts and item.opts.spacing then
                        height = height + get_height(item.val) * (item.opts.spacing + 1)
                    else
                        height = height + get_height(item.val)
                    end
                elseif item.type == 'button' then
                    height = height + 1
                end
            end

            return height
        end

        local height = get_height(layout)
        local offset = vim.api.nvim_win_get_height(0) / 2 - height / 2

        table.insert(layout, 1, {
            type = 'padding',
            val = math.floor(offset + 0.5),
        })

        return layout
    end

    local layout = {
        {
            type = 'group',

            val = {
                button(' New file', 'n', '<Cmd>enew<CR>'),
                button('󰈞 Open file', 'o', '<Cmd>Telescope find_files<CR>'),
                button('󱋡 Recent files', 'r', '<Cmd>Telescope oldfiles<CR>'),
                button(' Files explorer', 'e', '<Cmd>Neotree source=filesystem<CR>'),
                button(' Settings', 's', '<Cmd>Neotree reveal_force_cwd ' .. vim.fn.stdpath('config') .. '<CR>'),
                button('󰩈 Quit', 'q', '<Cmd>qall<CR>'),
            },

            opts = {
                spacing = 1,
            },
        },
    }

    return centralize(layout)
end


local config = function()
    local alpha = require('alpha')
    local term = require('alpha.term')


    alpha.setup({
        layout = layout(),

        opts = {
            noautocmd = true,

            setup = function()
                local auto = require('core.utils.autocmd')

                auto.cmd(
                    'User', 'AlphaReady',
                    function()
                        if vim.g.alpha_closed then
                            return
                        end

                        vim.opt.cmdheight = 0
                        vim.opt.laststatus = 0
                        vim.opt.showtabline = 0
                    end
                )

                auto.cmd(
                    'BufUnload', nil,
                    function()
                        vim.opt.cmdheight = 1
                        vim.opt.laststatus = 3
                        vim.opt.showtabline = 2

                        vim.g.alpha_closed = true
                    end,
                    {
                        buffer = 0,
                    }
                )
            end,
        },
    })
end

return {
    'goolord/alpha-nvim',
    config = config,
    dependencies = 'nvim-tree/nvim-web-devicons',
}

