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
        build = input.build,
        priority = input.priority or 0,
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
    local auto = require("core.utils.autocmd")

    local specs = {}
    local configs = {}
    local builds = {}

    table.sort(specs_ext, function(a, b)
        local pa = (type(a) == "table" and a.priority) or 0
        local pb = (type(b) == "table" and b.priority) or 0
        return pa > pb
    end)

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

        if spec.build then
            builds[spec.name] = spec.build
        end
    end

    auto.group("PackHooks", { clear = true })
    auto.cmd("PackChanged", nil, function(args)
        local data = args.data
        if not data or not data.spec then
            return
        end

        local build = builds[data.spec.name]
        if not build then
            return
        end

        if data.kind ~= "install" and data.kind ~= "update" then
            return
        end

        if not data.active then
            vim.cmd.packadd(data.spec.name)
        end

        if type(build) == "function" then
            pcall(build, data)
        elseif type(build) == "string" then
            if build:sub(1, 1) == ":" then
                vim.cmd(build:sub(2))
            else
                vim.fn.system(build)
            end
        end
    end)

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
