return {
    src = "IogaMaster/neocord",
    config = function()
        require("neocord").setup({
            logo = "auto",
            logo_tooltip = nil,
            main_image = "language",

            show_time = true,
            global_timer = true,

            debounce_timeout = 5,
        })
    end,
}
