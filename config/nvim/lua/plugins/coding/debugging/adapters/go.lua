local dap = require("dap")

dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
        command = "dlv",
        args = { "dap", "--listen=127.0.0.1:${port}" },
    },
}

dap.configurations.go = {
    {
        type = "go",
        request = "launch",
        mode = "debug",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
    },

    {
        type = "go",
        request = "launch",
        mode = "debug",
        name = "Launch package",
        program = "${fileDirname}",
        cwd = "${workspaceFolder}",
    },

    {
        type = "go",
        request = "launch",
        mode = "test",
        name = "Debug package tests",
        program = "${fileDirname}",
        cwd = "${workspaceFolder}",
    },

    {
        type = "go",
        request = "attach",
        mode = "local",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
    },
}
