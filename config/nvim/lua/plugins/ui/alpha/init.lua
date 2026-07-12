local function count_files(dir)
    local uv = vim.loop
    local count = 0
    local iter, err = uv.fs_scandir(dir)

    if not iter then
        error("Could not scan directory: " .. err)
    end

    while true do
        local name, type = uv.fs_scandir_next(iter)
        if not name then
            break
        end
        if type == "file" then
            count = count + 1
        end
    end

    return count
end

-- New banners can be generated with: https://github.com/Asthestarsfalll/img2art
local banners_dir = vim.fn.stdpath("config") .. "/lua/plugins/ui/alpha/banners"
local current_banner

local get_banner = function()
    if current_banner then
        return current_banner
    end

    local banners_count = count_files(banners_dir)
    if banners_count == 0 then
        error("No Alpha banners found in: " .. banners_dir)
    end

    current_banner = require("plugins.ui.alpha.banners.banner-" .. math.random(banners_count))
    return current_banner
end

local button = function(text, shortcut, action)
    return {
        type = "button",
        val = text,

        on_press = function()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(shortcut, true, false, true), "normal", false)
        end,

        opts = {
            position = "center",

            cursor = -2,
            width = 35,

            keymap = {
                "n",
                shortcut,
                action,

                {
                    noremap = true,
                    silent = true,
                },
            },

            shortcut = shortcut,
            align_shortcut = "right",
        },
    }
end

local layout = function()
    local centralize = function(layout)
        local function get_height(items)
            local height = 0

            for _, item in ipairs(items) do
                if item.type == "group" then
                    if item.opts and item.opts.spacing then
                        height = height + get_height(item.val) * (item.opts.spacing + 1)
                    else
                        height = height + get_height(item.val)
                    end
                elseif item.type == "button" then
                    height = height + 1
                elseif item.type == "text" then
                    if type(item.val) == "string" then
                        height = height + 1
                    elseif type(item.val) == "table" then
                        height = height + #item.val
                    end
                elseif item.type == "padding" then
                    height = height + item.val
                end
            end

            return height
        end

        local height = get_height(layout)
        local offset = vim.api.nvim_win_get_height(0) / 2 - height / 2

        if offset > 0 then
            table.insert(layout, 1, {
                type = "padding",
                val = math.floor(offset + 0.5),
            })
        end

        return layout
    end

    local layout = {
        get_banner().header,

        {
            type = "padding",
            val = 2,
        },

        {
            type = "group",

            val = {
                button(" New file", "n", "<Cmd>enew<CR>"),
                button("󰈞 Open file", "o", function()
                    local utils = require("core.utils")
                    local fzf = utils.safe_require("fzf-lua")
                    if fzf then
                        fzf.files()
                        return
                    end

                    local telescope = utils.safe_require("telescope.builtin")
                    if telescope then
                        telescope.find_files()
                        return
                    end
                end),
                button("󱋡 Recent files", "r", function()
                    local utils = require("core.utils")
                    local fzf = utils.safe_require("fzf-lua")
                    if fzf then
                        fzf.oldfiles()
                        return
                    end

                    local telescope = utils.safe_require("telescope.builtin")
                    if telescope then
                        telescope.oldfiles()
                        return
                    end
                end),
                button(
                    " Files explorer",
                    "e",
                    "<Cmd>Neotree source=filesystem reveal_force_cwd " .. vim.fn.getcwd() .. "<CR>"
                ),
                button(" Settings", "s", "<Cmd>Neotree reveal_force_cwd " .. vim.fn.stdpath("config") .. "<CR>"),
                button("󰩈 Quit", "q", "<Cmd>qall<CR>"),
            },

            opts = {
                spacing = 1,
            },
        },
    }

    return centralize(layout)
end

return {
    "goolord/alpha-nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        math.randomseed(vim.uv.hrtime())

        local alpha = require("alpha")
        alpha.setup({
            layout = layout(),

            opts = {
                noautocmd = true,

                setup = function()
                    local group = vim.api.nvim_create_augroup("AlphaDashboard", {
                        clear = true,
                    })

                    vim.api.nvim_create_autocmd("User", {
                        group = group,
                        pattern = "AlphaReady",
                        callback = function()
                            if vim.g.alpha_closed then
                                return
                            end

                            _G.alpha_win_num = vim.api.nvim_get_current_win()

                            vim.opt.laststatus = 0
                            vim.opt.showtabline = 0
                        end,
                        desc = "Hide global UI while Alpha is open",
                    })

                    vim.api.nvim_create_autocmd("BufUnload", {
                        group = group,
                        buffer = 0,
                        callback = function()
                            vim.opt.laststatus = 3
                            vim.opt.showtabline = 2

                            vim.g.alpha_closed = true
                        end,
                        desc = "Restore global UI after closing Alpha",
                    })

                    vim.api.nvim_create_autocmd("VimResized", {
                        group = group,
                        callback = function()
                            if
                                _G.alpha_win_num
                                and vim.api.nvim_win_is_valid(_G.alpha_win_num)
                                and vim.api.nvim_get_current_win() == _G.alpha_win_num
                            then
                                package.loaded["alpha"].default_config.layout = layout()
                                alpha.redraw()
                            end
                        end,
                        desc = "Recenter Alpha dashboard after resizing",
                    })

                    -- Due the reloader thats changes colorscheme the highlight are
                    -- lost so we need to set them again
                    local selected_banner = get_banner()
                    selected_banner.set_highlights()

                    vim.api.nvim_create_autocmd("ColorScheme", {
                        group = group,
                        callback = function()
                            selected_banner.set_highlights()
                        end,
                        desc = "Restore Alpha banner highlights after changing colorscheme",
                    })
                end,
            },
        })
    end,
}
