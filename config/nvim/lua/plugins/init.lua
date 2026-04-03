--  ╔═╗┬  ┬ ┬┌─┐┬┌┐┌┌─┐
--  ╠═╝│  │ ││ ┬││││└─┐
--  ╩  ┴─┘└─┘└─┘┴┘└┘└─┘

local function normalize_src(src)
    if src:match("^[a-z]+://") then
        return src
    end

    return "https://github.com/" .. src:gsub("^/", "")
end

local function normalize_name(name)
    -- remove common prefixes
    name = name:gsub("^nvim%-", ""):gsub("^vim%-", "")

    -- remove common suffixes
    name = name:gsub("%.nvim$", ""):gsub("%.vim$", ""):gsub("%-vim$", ""):gsub("%.lua$", "")

    return name
end

local function parse_spec(input)
    if type(input) == "string" then
        return { src = input }
    end

    return {
        src = input.src or input[1],
        version = input.version,
        name = input.name,
        config = input.config,
        dependencies = input.dependencies,
    }
end

local function resolve_name(src, name)
    if name then
        return name
    end

    local repo = src:match("/([^/]+)%.git$") or src:match("/([^/]+)$")
    return normalize_name(repo)
end

local function setup_plugins(specs_ext)
    local specs = {}
    local configs = {}

    for _, raw in ipairs(specs_ext) do
        local spec = parse_spec(raw)

        -- dependencies
        if spec.dependencies then
            for _, dep in ipairs(spec.dependencies) do
                local d = parse_spec(dep)
                table.insert(specs, {
                    src = normalize_src(d.src),
                    version = d.version,
                })
            end
        end

        -- main spec
        spec.src = normalize_src(spec.src)
        spec.name = resolve_name(spec.src, spec.name)

        table.insert(specs, spec)

        if spec.config then
            configs[#configs + 1] = spec.config
        end
    end

    vim.pack.add(specs, { confirm = false })

    for _, config in ipairs(configs) do
        pcall(config)
    end
end

setup_plugins({
    require("plugins.alpha"),
    require("plugins.autopairs"),
    require("plugins.autotag"),
    require("plugins.bufferline"),
    require("plugins.cmp"),
    require("plugins.conform"),
    require("plugins.gitsigns"),
    require("plugins.highlight-colors"),
    require("plugins.hop"),
    require("plugins.incline"),
    require("plugins.indent-blankline"),
    require("plugins.lsp"),
    require("plugins.lualine"),
    require("plugins.mason"),
    require("plugins.mini-animate"),
    require("plugins.navic"),
    require("plugins.neocord"),
    require("plugins.neotree"),
    require("plugins.noice"),
    require("plugins.smear-cursor"),
    require("plugins.statuscol"),
    require("plugins.surround"),
    require("plugins.tmux-navigator"),
    require("plugins.treesitter"),
    require("plugins.which-key"),

    "https://github.com/mattn/emmet-vim",
    "https://github.com/tpope/vim-commentary",
})
