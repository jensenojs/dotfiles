-- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)
return function()
    local dap = require("dap")
    local utils = require("utils.dap")
    local is_windows = require("core.global").is_windows

    if not require("mason-registry").is_installed("codelldb") then
        vim.notify("Automatically installing `codelldb` for go debugging", vim.log.levels.INFO, {
            title = "nvim-dap"
        })

        local go_dbg = require("mason-registry").get_package("codelldb")
        go_dbg:install():once("closed", vim.schedule_wrap(function()
            if go_dbg:is_installed() then
                vim.notify("Successfully installed `codelldb`", vim.log.levels.INFO, {
                    title = "nvim-dap"
                })
            end
        end))
    end

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = vim.fn.exepath("codelldb"), -- Find codelldb on $PATH
            args = {"--port", "${port}"},
            detached = is_windows and false or true
        }
    }
    dap.configurations.c = {{
        name = "Debug",
        type = "codelldb",
        request = "launch",
        program = utils.input_exec_path(),
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        terminal = "integrated"
    }, {
        name = "Debug (with args)",
        type = "codelldb",
        request = "launch",
        program = utils.input_exec_path(),
        args = utils.input_args(),
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        terminal = "integrated"
    }, {
        name = "Attach to a running process",
        type = "codelldb",
        request = "attach",
        program = utils.input_exec_path(),
        stopOnEntry = false,
        waitFor = true
    }}
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c
end
