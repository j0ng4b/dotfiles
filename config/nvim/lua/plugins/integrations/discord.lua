return {
    "vyfor/cord.nvim",
    config = function()
        require("cord").setup({
            display = {
                theme = "classic",
                flavor = "accent",
                view = "full",
            },

            idle = {
                state = "Be right back",
                tooltip = "😴",
                details = function(opts)
                    return "Taking a break from " .. opts.workspace
                end,
            },
        })
    end,
}
