return {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },

            diagnostics = {
                globals = { "vim", "love" },
            },

            hint = {
                enable = true,
                setType = true,
                arrayIndex = "Disable",
            },

            semantic = {
                enable = true,
                keyword = true,
            },

            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                },

                checkThirdParty = "Apply",
                useThirdParty = { vim.env.HOME .. "/.local/share/LuaAddons" },
            },

            telemetry = {
                enable = false,
            },
        },
    },
}
