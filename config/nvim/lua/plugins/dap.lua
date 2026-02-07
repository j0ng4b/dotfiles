local config = function ()
    local icons = require('core.utils.icons')

    local dap = require('dap')
    local repl = require('dap.repl')
    local ui = require('dapui')

    -- Mason - DAP integration
    require('mason-nvim-dap').setup({
        ensure_installed = {
            'python',
        },

        handlers = {
            function(config)
                require('mason-nvim-dap').default_setup(config)
            end,
        },
    })


    -- DAP configuration
    dap.configurations = {
        python = {
            {
                type = 'python',
                request = 'launch',
                name = 'Launch file',

                program = '${file}',
                pythonPath = function()
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                        return cwd .. '/venv/bin/python'
                    elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                        return cwd .. '/.venv/bin/python'
                    else
                        return '/usr/bin/python'
                    end
                end,
            },
        },
    }

    repl.commands = vim.tbl_extend('force', repl.commands, {
        continue         = { 'c',  'continue' },
        next_            = { 'n',  'next' },
        nexti            = { 'ni', 'nexti' },
        step_back        = { 'b',  'back' },
        step_backi       = { 'bi', 'backi' },
        reverse_continue = { 'rc', 'reverse-continue' },
        into             = { 'i',  'into' },
        intoi            = { 'ii', 'intoi' },
        out              = { 'o',  'out' },
        scopes           = { 's',  'scopes' },
        threads          = { 't',  'threads' },
        frames           = { 'f',  'frames' },
        exit             = { 'e',  'exit' },
        up               = { 'u',  'up' },
        down             = { 'd',  'down' },
        goto_            = { 'g',  'goto' },
        pause            = { 'p',  'pause' },
    })

    vim.fn.sign_define('DapBreakpoint', {
        text = icons.debug.breakpoint,
        texthl = 'DapBreakpoint',
    })

    vim.fn.sign_define('DapLogPoint', {
        text = icons.debug.logpoint,
        texthl = 'DapLogPoint',
    })

    vim.fn.sign_define('DapStopped', {
        text = icons.debug.stopped,
        texthl = 'DapStopped',

    })

    vim.fn.sign_define('DapBreakpointCondition', {
        text = icons.debug.condpoint,
        texthl = 'DapBreakpointCondition',
    })

    vim.fn.sign_define('DapBreakpointRejected', {
        text = icons.debug.rejectedpoint,
        texthl = 'DapBreakpointRejected',
    })

    -- -- DAP ui setup
    ui.setup()

    dap.listeners.before.attach.dapui_config = ui.open
    dap.listeners.before.launch.dapui_config = ui.open
    dap.listeners.before.event_terminated.dapui_config = ui.close
    dap.listeners.before.event_exited.dapui_config = ui.close


    -- DAP virtual text
    require('nvim-dap-virtual-text').setup({
        enabled_commands = false,
        virt_text_pos = 'eol',
    })
end


return {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    config = config,
    dependencies = {
        'rcarriga/nvim-dap-ui',
        'nvim-neotest/nvim-nio',
        'jay-babu/mason-nvim-dap.nvim',
        'theHamsta/nvim-dap-virtual-text',
    },}
