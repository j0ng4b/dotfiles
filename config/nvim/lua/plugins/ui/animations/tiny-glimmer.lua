return {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    priority = 10,
    config = function()
        require("tiny-glimmer").setup({
            autoreload = true,

            overwrite = {
                yank = {
                    enabled = true,
                    default_animation = "fade",
                },

                paste = {
                    enabled = true,
                    default_animation = {
                        name = "reverse_fade",
                        settings = {
                            from_color = "DiffAdd",
                        },
                    },
                },

                search = {
                    enabled = true,
                    default_animation = "pulse",
                },

                undo = {
                    enabled = true,
                    default_animation = {
                        name = "fade",
                        settings = {
                            from_color = "DiffDelete",
                        },
                    },
                },

                redo = {
                    enabled = true,
                    default_animation = {
                        name = "fade",
                        settings = {
                            from_color = "DiffAdd",
                        },
                    },
                },
            },

            animations = {
                fade = {
                    max_duration = 1500,
                    min_duration = 1000,
                },

                reverse_fade = {
                    max_duration = 1200,
                    min_duration = 800,
                },

                pulse = {
                    intensity = 0.8,
                    pulse_count = 3,
                    max_duration = 1000,
                    min_duration = 800,
                    chars_for_max_duration = 15,
                },
            },

            hijack_ft_disabled = {
                "alpha",
                "neo-tree",
            },
        })
    end,
}
