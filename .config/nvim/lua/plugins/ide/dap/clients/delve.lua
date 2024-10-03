-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
-- https://github.com/golang/vscode-go/blob/master/docs/debugging.md
return function()

    require('dap-go').setup {
        delve = {
            -- On Windows delve must be run attached or it crashes.
            -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
            detached = vim.fn.has 'win32' == 0
        }
    }
    -- local dap = require("dap")
    -- local utils = require("utils.dap")

    -- if not require("mason-registry").is_installed("go-debug-adapter") then
    --     vim.notify("Automatically installing `go-debug-adapter` for go debugging", vim.log.levels.INFO, {
    --         title = "nvim-dap"
    --     })

    --     local go_dbg = require("mason-registry").get_package("go-debug-adapter")
    --     go_dbg:install():once("closed", vim.schedule_wrap(function()
    --         if go_dbg:is_installed() then
    --             vim.notify("Successfully installed `go-debug-adapter`", vim.log.levels.INFO, {
    --                 title = "nvim-dap"
    --             })
    --         end
    --     end))
    -- end

    -- local function filtered_pick_process()
    --     local opts = {}
    --     vim.ui.input({
    --         prompt = "Search by process name (lua pattern), or hit enter to select from the process list: "
    --     }, function(input)
    --         opts["filter"] = input or ""
    --     end)
    --     return require("dap.utils").pick_process(opts)
    -- end

    -- dap.adapters.go = {
    --     type = "executable",
    --     command = "node",
    --     args = {require("mason-registry").get_package("go-debug-adapter"):get_install_path() ..
    --         "/extension/dist/debugAdapter.js"}
    -- }

    -- dap.configurations.go = {{
    --     type = "go",
    --     name = "Debug (file)",
    --     request = "launch",
    --     cwd = "${workspaceFolder}",
    --     program = utils.input_file_path(),
    --     console = "integratedTerminal",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     showLog = true,
    --     showRegisters = true,
    --     stopOnEntry = false
    -- }, {
    --     type = "go",
    --     name = "Debug (file with args)",
    --     request = "launch",
    --     cwd = "${workspaceFolder}",
    --     program = utils.input_file_path(),
    --     args = utils.input_args(),
    --     console = "integratedTerminal",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     showLog = true,
    --     showRegisters = true,
    --     stopOnEntry = false
    -- }, {
    --     type = "go",
    --     name = "Debug (executable)",
    --     request = "launch",
    --     cwd = "${workspaceFolder}",
    --     program = utils.input_exec_path(),
    --     args = utils.input_args(),
    --     console = "integratedTerminal",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     mode = "exec",
    --     showLog = true,
    --     showRegisters = true,
    --     stopOnEntry = false
    -- }, {
    --     type = "go",
    --     name = "Debug (test file)",
    --     request = "launch",
    --     cwd = "${workspaceFolder}",
    --     program = utils.input_file_path(),
    --     console = "integratedTerminal",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     mode = "test",
    --     showLog = true,
    --     showRegisters = true,
    --     stopOnEntry = false
    -- }, {
    --     type = "go",
    --     name = "Attach",
    --     mode = "local",
    --     request = "attach",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     processId = filtered_pick_process
    -- }, {
    --     type = "go",
    --     name = "Debug (using go.mod)",
    --     request = "launch",
    --     cwd = "${workspaceFolder}",
    --     program = "./${relativeFileDirname}",
    --     console = "integratedTerminal",
    --     dlvToolPath = vim.fn.exepath("dlv"),
    --     mode = "test",
    --     showLog = true,
    --     showRegisters = true,
    --     stopOnEntry = false
    -- }}

end
