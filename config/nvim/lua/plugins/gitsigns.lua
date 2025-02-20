local config = function()
    local gitsigns = require('gitsigns')

    gitsigns.setup({
        signs = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },

        signs_staged = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
        },

        signs_staged_enable = false,
        on_attach = function(bufnr)
            local map = require('core.utils.map')

            -- Enable which-key
            map.use_which_key()
            map.group('󰊢 Git', '<Leader>h')

            -- Navigation
            map({ 'n' }, '<Leader>hn', function()
                    gitsigns.nav_hunk('next')
                end,
                {
                    desc = 'jump to next hunk',
                    remap = false,
                }
            )

            map({ 'n' }, '<Leader>hp', function()
                    gitsigns.nav_hunk('prev')
                end,
                {
                    desc = 'jump to previous hunk',
                    remap = false,
                }
            )


            -- Actions
            map({ 'n' }, '<leader>hS',
                gitsigns.stage_buffer,
                {
                    desc = 'stage all hunks on buffer',
                    remap = false,
                }
            )

            map({ 'n', 'v' }, '<leader>hs', function()
                    local range = nil
                    local mode = vim.api.nvim_get_mode().mode

                    if mode == 'v' or mode == 'V' or mode == '<C-v>' then
                        range = {
                            vim.fn.getpos('v')[2],
                            vim.fn.getpos('.')[2],
                        }
                    end

                    gitsigns.stage_hunk(range)
                end,
                {
                    desc = 'stage lines of the hunk at cursor position',
                    remap = false,
                }
            )


            map({ 'n' }, '<leader>hR', function()
                    local range = nil
                    local mode = vim.api.nvim_get_mode().mode

                    if mode == 'v' or mode == 'V' or mode == '<C-v>' then
                        range = {
                            vim.fn.getpos('v')[2],
                            vim.fn.getpos('.')[2],
                        }
                    end

                    gitsigns.reset_buffer(range)
                end,
                {
                    desc = 'reset the lines of all hunks on buffer',
                    remap = false,
                }
            )

            map({ 'n', 'v' }, '<leader>hr',
                gitsigns.reset_hunk,
                {
                    desc = 'reset the lines of the hunk',
                    remap = false,
                }
            )


            map({ 'n' }, '<leader>hv',
                gitsigns.preview_hunk,
                {
                    desc = 'preview hunk at cursor position',
                    remap = false,
                }
            )


            map({ 'n' }, '<leader>hb',
                gitsigns.blame_line,
                {
                    desc = 'show line last modification revision and author',
                    remap = false,
                }
            )
        end,
    })
end

return {
    'lewis6991/gitsigns.nvim',
    config = config,
}

