-- Only editor-side tools live here (LSPs, DAP adapters) plus tools for
-- ecosystems where per-project installation is not trivial.
--
-- Groups with `requires` are skipped when that executable is not on PATH.
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
            "debugpy", -- DAP adapter
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
            "netcoredbg", -- DAP adapter
        },
    },

    {
        name = "Go",
        requires = "go",
        tools = {
            "gopls",
            "goimports",
            "gofumpt",
            "delve", -- DAP adapter
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
        name = "Docker",
        tools = {
            "dockerfile-language-server",
            "docker-compose-language-service",
        },
    },

    {
        name = "JSON and YAML",
        tools = {
            "json-lsp",
            "yaml-language-server",
        },
    },

    {
        name = "General",
        tools = {
            "tree-sitter-cli", -- nvim-treesitter needs it to build parsers
        },
    },
}

-- Flattens TOOL_GROUPS into a plain list, skipping groups whose required
-- executable is missing.
---@return string[]
local function build_tool_list()
    local tools = {}

    for _, group in ipairs(TOOL_GROUPS) do
        if not group.requires or vim.fn.executable(group.requires) == 1 then
            vim.list_extend(tools, group.tools)
        end
    end

    return tools
end

return {
    "mason-org/mason.nvim",
    -- Load early so installed binaries are on PATH before LSP/lint/format
    -- start.
    priority = 100,
    dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",

    config = function()
        require("mason").setup()
        require("mason-tool-installer").setup({
            ensure_installed = build_tool_list(),

            -- Install missing tools only; updates are done manually.
            auto_update = false,
            run_on_start = true,

            -- Wait a bit so the installer doesn't compete with startup,
            -- and don't re-check more than once a day.
            start_delay = 1000,
            debounce_hours = 24,
        })
    end,
}
