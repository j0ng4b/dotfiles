local TOOL_GROUPS = {
    {
        name = "Web",
        tools = {
            "css-lsp",
            "html-lsp",
            "tailwindcss-language-server",
            "typescript-language-server",
            "vue-language-server",
            "emmet-language-server",

            "prettier",

            "eslint_d",
            "stylelint",
        },
    },

    {
        name = "C and C++",
        tools = {
            "clangd",
        },
    },

    {
        name = "Java",
        tools = {
            "jdtls",
        },
    },

    {
        name = "Python",
        tools = {
            "pyright",

            "isort",
            "black",

            "ruff",

            "debugpy",
        },
    },

    {
        name = "Lua",
        tools = {
            "lua-language-server",
            "stylua",
        },
    },

    {
        name = ".NET",
        requires = "dotnet",
        tools = {
            "roslyn-language-server",
            "csharpier",
            "netcoredbg",
        },
    },

    {
        name = "Go",
        requires = "go",
        tools = {
            "gopls",

            "goimports",
            "gofumpt",

            "delve",
        },
    },

    {
        name = "QML",
        requires = "quickshell",
        tools = {
            "qmlls",
        },
    },

    {
        name = "General",
        tools = {
            "tree-sitter-cli",
        },
    },
}

local function build_tool_list()
    local tools = {}

    for _, group in ipairs(TOOL_GROUPS) do
        local condition = nil
        if group.requires then
            condition = function()
                return vim.fn.executable(group.requires) == 1
            end
        end

        for _, tool in ipairs(group.tools) do
            tools[#tools + 1] = { tool, condition = condition }
        end
    end

    return tools
end

return {
    "mason-org/mason.nvim",
    priority = 100,

    dependencies = {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },

    config = function()
        require("mason").setup()
        require("mason-tool-installer").setup({
            ensure_installed = build_tool_list(),

            auto_update = true,
            run_on_start = true,

            start_delay = 1000,
            debounce_hours = 24,
        })
    end,
}
