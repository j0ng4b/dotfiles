return {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
        local animate = require("mini.animate")

        -- Mouse wheel scrolls are not animated.
        local mouse_scrolled = false
        for _, scroll in ipairs({ "Up", "Down" }) do
            local key = "<ScrollWheel" .. scroll .. ">"
            vim.keymap.set({ "", "i" }, key, function()
                mouse_scrolled = true
                return key
            end, { expr = true })
        end

        animate.setup({
            cursor = {
                enable = false,
            },

            scroll = {
                timing = animate.gen_timing.linear({ duration = 300, unit = "total" }),
                subscroll = animate.gen_subscroll.equal({
                    predicate = function(total_scroll)
                        -- While a scroll animation runs, mini.animate overrides
                        -- the window-local 'virtualedit' (=all) and 'scrolloff'
                        -- (=0) and restores them when it finishes.
                        --
                        -- Declining a scroll that arrives mid-animation (mouse
                        -- wheel, 1-line scroll) cuts the animation off without
                        -- restoring them: 'virtualedit' stays "all" and the
                        -- cursor can go past the end of lines.
                        --
                        -- Reproduced with <C-d> + mouse wheel before the
                        -- animation ends.
                        --
                        -- See: https://github.com/nvim-mini/mini.nvim/issues/2587
                        if animate.is_active("scroll") then
                            mouse_scrolled = false
                            return true
                        end

                        if mouse_scrolled then
                            mouse_scrolled = false
                            return false
                        end

                        return total_scroll > 1
                    end,
                }),
            },
        })
    end,
}
