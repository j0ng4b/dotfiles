vim.api.nvim_create_autocmd({
    "CmdlineEnter",
    "CmdlineLeave",
}, {
    group = vim.api.nvim_create_augroup("VimHighlightOnSearch", {
        clear = true,
    }),
    pattern = { "/", "?" },
    callback = function(args)
        vim.opt.hlsearch = args.event == "CmdlineEnter"
    end,
    desc = "Highlight matches only while searching",
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = vim.api.nvim_create_augroup("ChangeTimeoutLenByMode", {
        clear = true,
    }),
    pattern = {
        "*:[vV\x16iR]*",
        "[vV\x16iR]*:*",
    },
    callback = function()
        local mode = vim.api.nvim_get_mode().mode
        local short_timeout = mode:match("^[vV\x16iR]") ~= nil

        vim.opt.timeoutlen = short_timeout and 250 or 1000
    end,
    desc = "Adjust mapping timeout according to mode",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("DockerComposeFiletype", { clear = true }),
    pattern = {
        "docker-compose.yml",
        "docker-compose.yaml",
        "docker-compose.*.yml",
        "docker-compose.*.yaml",
        "compose.yml",
        "compose.yaml",
        "compose.*.yml",
        "compose.*.yaml",
    },
    callback = function()
        vim.bo.filetype = "yaml.docker-compose"
        vim.wo.spell = false
    end,
    desc = "Set filetype yaml.docker-compose",
})
