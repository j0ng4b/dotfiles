local function count_files(dir)
    local uv = vim.loop
    local count = 0
    local iter, err = uv.fs_scandir(dir)

    if not iter then
        error('Could not scan directory: ' .. err)
    end

    while true do
        local name, type = uv.fs_scandir_next(iter)
        if not name then break end
        if type == 'file' then
            count = count + 1
        end
    end

    return count
end

local banner = function()
    math.randomseed(os.time())

    local banners_count = count_files(
        vim.fn.stdpath('config') .. '/lua/plugins/alpha-banners'
    )

    local banner = require('plugins.alpha-banners/banner-' .. math.random(banners_count))

    -- used to reset highlight when colorscheme changes
    _G.alpha_cur_banner = banner

    return banner.header
end

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

            cursor = -2,
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
                elseif item.type == 'text' then
                     if type(item.val) == 'string' then
                         height = height + 1
                     elseif type(item.val) == 'table' then
                         height = height + #item.val
                     end
                elseif item.type == 'padding' then
                     height = height + item.val
                end
            end

            return height
        end

        local height = get_height(layout)
        local offset = vim.api.nvim_win_get_height(0) / 2 - height / 2

        if offset > 0 then
            table.insert(layout, 1, {
                type = 'padding',
                val = math.floor(offset + 0.5),
            })
        end

        return layout
    end

    local layout = {
        banner(),

        {
            type = 'padding',
            val = 2,
        },

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

                        _G.alpha_win_num = vim.api.nvim_get_current_win()

                        vim.opt.laststatus = 0
                        vim.opt.showtabline = 0
                    end
                )

                auto.cmd(
                    'BufUnload', nil,
                    function()
                        vim.opt.laststatus = 3
                        vim.opt.showtabline = 2

                        vim.g.alpha_closed = true
                    end,
                    {
                        buffer = 0,
                    }
                )

                auto.cmd(
                    'VimResized', nil,
                    function()
                        if vim.api.nvim_get_current_win() == _G.alpha_win_num then
                            package.loaded.alpha.default_config.layout = layout()
                            alpha.redraw()
                        end
                    end,
                    {
                        buffer = 0,
                    }
                )

                -- Due the reloader thats changes colorscheme the highlight are
                -- lost so we need to set them again
                _G.alpha_cur_banner.set_highlights()
                auto.cmd('Colorscheme', '',
                    function()
                        _G.alpha_cur_banner.set_highlights()
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

