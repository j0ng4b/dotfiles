function get_search_command()
    local cmd = 'rg'
    local args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
    }

    if vim.fn.executable('rg') == 0 then
        cmd = 'grep'
        args = {
            '--extended-regexp',
            '--color=never',
            '--with-filename',
            '--line-number',
            '-b',
            '--ignore-case',
            '--recursive',
            '--no-messages',
            '--exclude-dir=*cache*',
            '--exclude-dir=*.git',
            '--exclude=.*',
            '--binary-files=without-match',
        }
    end

    return {
        command = cmd,
        args = args,
    }
end


local config = function()
    require('todo-comments').setup({
        signs = false,
        search = get_search_command(),
    })
end

return {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = config,
}
