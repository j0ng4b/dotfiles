--- Hides the real cursor inside neo-tree (the current line is already highlighted).
---
---@param visible boolean
local function set_cursor_visible(visible)
    for _, group in ipairs({ "Cursor", "SmearCursorHideable" }) do
        vim.cmd(("highlight! %s blend=%d cterm=reverse gui=reverse"):format(group, visible and 0 or 100))
    end
end

--- Re-equalizes the splits when the tree opens or closes on a side.
local function equalize_windows(args)
    if args.position == "left" or args.position == "right" then
        vim.cmd("wincmd =")
    end
end

return {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        "saifulapm/neotree-file-nesting-config",
    },
    config = function()
        local icons = require("core.utils.icons")

        require("neo-tree").setup({
            enable_cursor_hijack = true,
            close_if_last_window = true,
            auto_clean_after_session_restore = true,

            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "document_symbols",
            },

            window = {
                position = "left",
                width = 40,
            },

            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_gitignored = true,
                },

                -- Refresh the tree when files change outside Neovim.
                use_libuv_file_watcher = true,
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
                        -- File change type
                        added = "",
                        deleted = "",
                        modified = "",
                        renamed = "",

                        -- File status type
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

            event_handlers = {
                {
                    event = "neo_tree_popup_input_ready",
                    handler = function(args)
                        -- The prompt needs the arrow keys: shadow global
                        -- insert-mode mapping disabling arrow keys for this
                        -- buffer only.
                        for _, key in ipairs({ "<Left>", "<Right>" }) do
                            vim.keymap.set("i", key, key, {
                                buffer = args.bufnr,
                                noremap = true,
                            })
                        end

                        set_cursor_visible(true)
                    end,
                },

                {
                    event = "neo_tree_window_after_open",
                    handler = equalize_windows,
                },

                {
                    event = "neo_tree_window_after_close",
                    handler = equalize_windows,
                },
            },

            nesting_rules = require("neotree-file-nesting-config").nesting_rules,
        })

        -- Hidden in the tree, visible everywhere else. ColorScheme reapplies it,
        -- because :colorscheme clears every highlight group.
        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "ColorScheme" }, {
            group = vim.api.nvim_create_augroup("NeoTreeCursor", { clear = true }),
            desc = "Hide the cursor inside neo-tree",
            callback = function()
                set_cursor_visible(vim.bo.filetype ~= "neo-tree")
            end,
        })

        local command = require("neo-tree.command")
        local function map(lhs, source, desc)
            vim.keymap.set("n", lhs, function()
                command.execute({ toggle = true, source = source })
            end, { desc = desc })
        end

        map("<leader>ef", "filesystem", "toggle files explorer")
        map("<leader>eb", "buffers", "toggle buffers explorer")
        map("<leader>eg", "git_status", "toggle git status explorer")
        map("<leader>es", "document_symbols", "toggle lsp document symbols explorer")
    end,
}
