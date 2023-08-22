-- https://github.com/mfussenegger/nvim-dap/tree/master
-- 
local bind = require("utils.bind")
local map_callback = bind.map_callback

local keymaps = {
    ["n|<F5>"] = map_callback(function()
        require('telescope').extensions.dap.configurations{}
    end):with_noremap():with_silent():with_desc("调试: 选择配置文件进入"),

    ["n|<F9>"] = map_callback(function()
        require('dap').toggle_breakpoint()
    end):with_noremap():with_silent():with_desc("调试: 添加/删除断点"),

    ["n|<F10>"] = map_callback(function()
        require('dap').step_over()
    end):with_noremap():with_silent():with_desc("调试: 单步调试"),

    ["n|<F11>"] = map_callback(function()
        require('dap').step_into()
    end):with_noremap():with_silent():with_desc("调试: 跳入"),

    ["n|<F12>"] = map_callback(function()
        require('dap').step_out()
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["n|<leader>lp"] = map_callback(function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["n|<leader>dr"] = map_callback(function()
        require('dap').repl.open()
    end):with_noremap():with_silent():with_desc("调试: 跳出"),
   
    ["n|<leader>dl"] = map_callback(function()
        require('dap').run_last()
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["nv|<leader>lp"] = map_callback(function()
        require('dap.ui.widgets').hover()
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["nv|<leader>dp"] = map_callback(function()
        require('dap.ui.widgets').preview()
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["nv|<leader>df"] = map_callback(function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
    end):with_noremap():with_silent():with_desc("调试: 跳出"),

    ["nv|<leader>ds"] = map_callback(function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
    end):with_noremap():with_silent():with_desc("调试: 跳出"),
}

bind.nvim_load_mapping(keymaps)

--- go
-- dap.adapters.delve = {
--     type = 'server',
--     port = '${port}',
--     executable = {
--         command = 'dlv',
--         args = {'dap', '-l', '127.0.0.1:${port}'}
--     }
-- }

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
-- dap.configurations.go = {{
--     type = "delve",
--     name = "Debug",
--     request = "launch",
--     program = "${file}"
-- }, {
--     type = "delve",
--     name = "Debug test", -- configuration for debugging test files
--     request = "launch",
--     mode = "test",
--     program = "${file}"
-- }, -- works with go.mod packages and sub packages 
-- {
--     type = "delve",
--     name = "Debug test (go.mod)",
--     request = "launch",
--     mode = "test",
--     program = "./${relativeFileDirname}"
-- }}

return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'nvim-telescope/telescope-dap.nvim',
    },

    config = function()
        local dap = require('dap')

        dap.adapters.python = {
            type = 'executable',
            command = '/usr/bin/python3',
            args = {'-m', 'debugpy.adapter'}
        }

        dap.configurations.python = {{
            type = 'python',
            request = 'launch',
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
                return '/usr/bin/python3'
            end
        }}
    end
}
