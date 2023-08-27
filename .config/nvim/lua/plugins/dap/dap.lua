-- https://github.com/mfussenegger/nvim-dap
-- 调试器的协议
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd

local keymaps = {
    ["n|<F5>"] = map_callback(function()
        -- require('telescope').extensions.dap.configurations{}
        require('dap').continue()
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
    end):with_noremap():with_silent():with_desc("调试: 跳出")
}

bind.nvim_load_mapping(keymaps)

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
return {
    'mfussenegger/nvim-dap',
    dependencies = {'theHamsta/nvim-dap-virtual-text', "rcarriga/nvim-dap-ui", "LiadOz/nvim-dap-repl-highlights"},

    config = function()
        local icons = {
            dap = require("utils.icons").get("dap")
        }

        -- 设置icon
        vim.fn.sign_define("DapBreakpoint", {
            text = icons.dap.Breakpoint,
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapBreakpointCondition", {
            text = icons.dap.BreakpointCondition,
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapStopped", {
            text = icons.dap.Stopped,
            texthl = "DapStopped",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapBreakpointRejected", {
            text = icons.dap.BreakpointRejected,
            texthl = "DapBreakpoint",
            linehl = "",
            numhl = ""
        })
        vim.fn.sign_define("DapLogPoint", {
            text = icons.dap.LogPoint,
            texthl = "DapLogPoint",
            linehl = "",
            numhl = ""
        })

    end
}
