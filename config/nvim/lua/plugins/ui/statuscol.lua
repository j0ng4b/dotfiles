return {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    config = function()
        local builtin = require("statuscol.builtin")

        require("statuscol").setup({
            relculright = true,

            ft_ignore = { "neo-tree" },
            bt_ignore = { "terminal", "nofile", "prompt" },

            -- Order: signs | line number | fold column
            segments = {
                {
                    text = { "%s" },
                    click = "v:lua.ScSa",
                },

                {
                    text = { builtin.lnumfunc },
                    click = "v:lua.ScLa",
                },

                {
                    text = { " ", builtin.foldfunc, " " },
                    click = "v:lua.ScFa",
                },
            },
        })
    end,
}
