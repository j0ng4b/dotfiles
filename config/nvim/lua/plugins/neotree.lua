local set_cursor_visible = function(visible)
    local blend = visible and 0 or 100

    vim.cmd(string.format("highlight! Cursor blend=%d cterm=reverse gui=reverse", blend))
    vim.cmd(string.format("highlight! SmearCursorHideable blend=%d cterm=reverse gui=reverse", blend))
end

local config = function()
    local icons = require("core.utils.icons")
    require("neo-tree").setup({
        close_if_last_window = true,

        sources = {
            "filesystem",
        },

        window = {
            position = "left",
            width = 40,
            mappings = {
                ["e"] = function()
                    vim.api.nvim_exec("Neotree focus filesystem left", true)
                end,
            },
        },

        filesystem = {
            filtered_items = {
                visible = true,
                hide_gitignored = true,
                use_libuv_file_watcher = true,
            },
        },

        default_component_configs = {
            indent = {
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "╰",
                indent_size = 2,
            },

            modified = {
                symbol = icons.file.modified,
                highlight = "NeoTreeModified",
            },

            git_status = {
                symbols = {
                    -- Change type, I don't use it anymore
                    added = "",
                    deleted = "",
                    modified = "",
                    renamed = "",

                    -- Status type
                    untracked = icons.git.untracked,
                    ignored = icons.git.ignored,
                    unstaged = icons.git.unstaged,
                    staged = icons.git.staged,
                    conflict = icons.git.conflict,
                },
            },

            diagnostics = {
                symbols = icons.diagnostics,
                highlights = {
                    hint = "DiagnosticSignHint",
                    info = "DiagnosticSignInfo",
                    warn = "DiagnosticSignWarn",
                    error = "DiagnosticSignError",
                },
            },
        },

        source_selector = {
            winbar = true,
            statusline = false,
            content_layout = "center",
            tabs_layout = "equal",

            separator = {
                left = "",
                right = "",
            },

            sources = {
                {
                    source = "filesystem",
                    display_name = "󰉓 Files",
                },
            },
        },

        event_handlers = {
            {
                event = "neo_tree_popup_input_ready",
                handler = function()
                    -- On NeoTree buffers movement with left and right arrows
                    -- are needed to move on pop-up.
                    pcall(vim.keymap.del, { "i" }, "<Left>")
                    pcall(vim.keymap.del, { "i" }, "<Right>")

                    set_cursor_visible(true)
                end,
            },

            {
                event = "neo_tree_window_after_open",
                handler = function(args)
                    if args.position == "left" or args.position == "right" then
                        vim.cmd("wincmd =")
                    end
                end,
            },

            {
                event = "neo_tree_window_after_close",
                handler = function(args)
                    if args.position == "left" or args.position == "right" then
                        vim.cmd("wincmd =")
                    end
                end,
            },
        },

        nesting_rules = {
            ["package.json"] = {
                pattern = "^package%.json$",
                files = { "package-lock.json" },
            },

            ["js"] = {
                pattern = "(.+)%.js$",
                files = { "%1.js.map", "%1.min.js", "%1.d.ts" },
            },

            ["docker"] = {
                pattern = "^dockerfile$",
                files = { ".dockerignore", "docker-compose.*", "dockerfile*", "compose.*" },
                ignore_case = true,
            },
        },
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
            if vim.bo.filetype == "neo-tree" then
                set_cursor_visible(false)
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        pattern = "*",
        callback = function()
            if vim.bo.filetype == "neo-tree" then
                set_cursor_visible(true)
            end
        end,
    })

    local command = require("neo-tree.command")
    vim.keymap.set({ "n" }, "<leader>ef", function()
        command.execute({ toggle = true, source = "filesystem" })
    end, { desc = "toggle files explorer" })

    vim.keymap.set({ "n" }, "<leader>eb", function()
        command.execute({ toggle = true, source = "buffers" })
    end, { desc = "toggle buffers explorer" })

    vim.keymap.set({ "n" }, "<leader>eg", function()
        command.execute({ toggle = true, source = "git_status" })
    end, { desc = "toggle git status explorer" })

    vim.keymap.set({ "n" }, "<leader>es", function()
        command.execute({ toggle = true, source = "document_symbols" })
    end, { desc = "lsp document symbols explorer" })
end

return {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        "saifulapm/neotree-file-nesting-config",
    },
    config = config,
}
