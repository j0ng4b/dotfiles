return {
    src = "luukvbaal/statuscol.nvim",
    config = function()
        local statuscol = require("statuscol")
        local builtin = require("statuscol.builtin")

        local ft_ignore = {
            "neo-tree",
        }

        statuscol.setup({
            relculright = true,

            ft_ignore = ft_ignore,
            bt_ignore = ft_ignore,

            segments = {
                {
                    text = { "%s" },
                    click = "v:lua.ScSa",
                },
                {
                    text = { builtin.lnumfunc },
                    condition = { true, builtin.not_empty },
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
