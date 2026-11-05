local BANNERS = "plugins.ui.alpha.banners"

local state = {
    win = nil, -- window showing the dashboard
    ui = nil, -- 'laststatus' / 'showtabline' before the dashboard hid them
    closed = false, -- the dashboard was closed once: don't hide the UI again
    banner = nil, -- banner module picked for this session
}

--- Hides the status line and tab line while the dashboard is open.
local function hide_ui()
    -- Keep the first snapshot: saving again would store the hidden values.
    if state.ui then
        return
    end

    state.ui = {
        laststatus = vim.o.laststatus,
        showtabline = vim.o.showtabline,
    }

    vim.o.laststatus = 0
    vim.o.showtabline = 0
end

local function restore_ui()
    if not state.ui then
        return
    end

    vim.o.laststatus = state.ui.laststatus
    vim.o.showtabline = state.ui.showtabline

    state.ui = nil
end

--- Picks one banner per session: any module in the banners folder is a
--- candidate.
---
--- New banners can be generated with:
---    https://github.com/Asthestarsfalll/img2art
---
---@return table
local function get_banner()
    if state.banner then
        return state.banner
    end

    local dir = vim.fn.stdpath("config") .. "/lua/" .. (BANNERS:gsub("%.", "/"))
    local names = {}

    for name, kind in vim.fs.dir(dir) do
        local module = kind == "file" and name:match("^(.+)%.lua$")
        if module then
            names[#names + 1] = module
        end
    end

    if #names == 0 then
        error("No Alpha banners found in: " .. dir)
    end

    state.banner = require(BANNERS .. "." .. names[math.random(#names)])
    return state.banner
end

--- fzf-lua first, telescope as a fallback.
local function picker(fzf_fn, telescope_fn)
    return function()
        local utils = require("core.utils")

        local fzf = utils.safe_require("fzf-lua")
        if fzf then
            return fzf[fzf_fn]()
        end

        local telescope = utils.safe_require("telescope.builtin")
        if telescope then
            return telescope[telescope_fn]()
        end
    end
end

--- Opens neo-tree rooted at dir(); evaluated on press, so it follows :cd.
local function explorer(dir)
    return function()
        vim.cmd("Neotree source=filesystem reveal_force_cwd " .. vim.fn.fnameescape(dir()))
    end
end

--- { label, shortcut, action }. Labels start with a Nerd Font glyph.
local BUTTONS = {
    {
        " New file",
        "n",
        "<Cmd>enew<CR>",
    },

    {
        "󰈞 Open file",
        "o",
        picker("files", "find_files"),
    },

    {
        "󱋡 Recent files",
        "r",
        picker("oldfiles", "oldfiles"),
    },

    {
        " Files explorer",
        "e",
        explorer(vim.fn.getcwd),
    },

    {
        " Settings",
        "s",
        explorer(function()
            return vim.fn.stdpath("config")
        end),
    },

    {
        "󰩈 Quit",
        "q",
        "<Cmd>qall<CR>",
    },
}

local function button(text, shortcut, action)
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

--- Number of screen lines taken by a list of layout elements.
local function height_of(items)
    local height = 0

    for _, item in ipairs(items) do
        if item.type == "group" then
            local spacing = item.opts and item.opts.spacing or 0
            height = height + height_of(item.val) * (spacing + 1)
        elseif item.type == "button" then
            height = height + 1
        elseif item.type == "text" then
            height = height + (type(item.val) == "table" and #item.val or 1)
        elseif item.type == "padding" then
            height = height + item.val
        end
    end

    return height
end

--- Built on demand (and again on resize), centered in the current window.
local function layout()
    local items = {
        get_banner().header,

        {
            type = "padding",
            val = 2,
        },

        {
            type = "group",
            val = vim.tbl_map(function(b)
                return button(b[1], b[2], b[3])
            end, BUTTONS),
            opts = { spacing = 1 },
        },
    }

    local offset = math.floor((vim.api.nvim_win_get_height(0) - height_of(items)) / 2 + 0.5)
    if offset > 0 then
        table.insert(items, 1, {
            type = "padding",
            val = offset,
        })
    end

    return items
end

return {
    "goolord/alpha-nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        math.randomseed(vim.uv.hrtime())

        local alpha = require("alpha")
        local group = vim.api.nvim_create_augroup("AlphaDashboard", {
            clear = true,
        })

        alpha.setup({
            layout = layout(),

            opts = {
                noautocmd = true,

                setup = function()
                    vim.api.nvim_create_autocmd("User", {
                        group = group,
                        pattern = "AlphaReady",
                        callback = function()
                            if state.closed then
                                return
                            end

                            state.win = vim.api.nvim_get_current_win()
                            hide_ui()
                        end,
                        desc = "Hide global UI while Alpha is open",
                    })
                end,
            },
        })

        vim.api.nvim_create_autocmd("BufUnload", {
            group = group,
            buffer = 0,
            callback = function()
                state.closed = true
                restore_ui()
            end,
            desc = "Restore global UI after closing Alpha",
        })

        vim.api.nvim_create_autocmd("VimResized", {
            group = group,
            callback = function()
                if
                    state.win
                    and vim.api.nvim_win_is_valid(state.win)
                    and vim.api.nvim_get_current_win() == state.win
                then
                    alpha.default_config.layout = layout()
                    alpha.redraw()
                end
            end,
            desc = "Recenter Alpha dashboard after resizing",
        })

        -- The theme reloader changes the colorscheme, which clears the
        -- banner highlights: set them again.

        local banner = get_banner()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = group,
            callback = banner.set_highlights,
            desc = "Restore Alpha banner highlights after changing colorscheme",
        })
    end,
}
