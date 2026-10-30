return {
    settings = {
        gopls = {
            semanticTokens = true,
            usePlaceholders = true,

            hints = {
                constantValues = true,
                rangeVariableTypes = true,
                assignVariableTypes = true,
                compositeLiteralTypes = true,
                compositeLiteralFields = true,
            },
        },
    },
}
