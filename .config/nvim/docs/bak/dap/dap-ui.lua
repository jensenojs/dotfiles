-- https://github.com/rcarriga/nvim-dap-ui
-- 调试界面的配置
_G._debugging = false

local bind = require("utils.bind")
local map_cmd = bind.map_cmd
local icons = {
    ui = require("utils.icons").get("ui"),
    dap = require("utils.icons").get("dap")
}

-- 在debug期间, 覆盖K的原来的含义
local M = {}
local did_load_debug_mappings = false
local debug_keymap = {
    ["nv|K"] = map_cmd("<Cmd>lua require('dapui').eval()<CR>"):with_noremap():with_nowait():with_desc(
        "Evaluate expression under cursor")
}
function M.load_extras()
    if not did_load_debug_mappings then
        require("utils.keymap").amend("Debugging", "_debugging", debug_keymap)
        did_load_debug_mappings = true
    end
end

return {
    "rcarriga/nvim-dap-ui",
    dependencies = {"nvim-neotest/nvim-nio"},

    opts = function()
        local dap = require('dap')
        local dapui = require("dapui")

        require("dapui").setup({
            force_buffers = true,
            icons = {
                expanded = icons.ui.ArrowOpen,
                collapsed = icons.ui.ArrowClosed,
                current_frame = icons.ui.Indicator
            },
            mappings = {
                -- Use a table to apply multiple mappings
                edit = "e",
                expand = {"<CR>", "<2-LeftMouse>"},
                open = "o",
                remove = "d",
                repl = "r",
                toggle = "t"
            },
            controls = {
                enabled = true,
                -- Display controls in this session
                element = "repl",
                icons = {
                    pause = icons.dap.Pause,
                    play = icons.dap.Play,
                    step_into = icons.dap.StepInto,
                    step_over = icons.dap.StepOver,
                    step_out = icons.dap.StepOut,
                    step_back = icons.dap.StepBack,
                    run_last = icons.dap.RunLast,
                    terminate = icons.dap.Terminate
                }
            },
            floating = {
                max_height = nil, -- These can be integers or a float between 0 and 1.
                max_width = nil, -- Floats will be treated as percentage of your screen.
                mappings = {
                    close = {"q", "<Esc>"}
                }
            },
            render = {
                indent = 1,
                max_value_lines = 85
            }
        })

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            _G._debugging = true
            M.load_extras()
            require("focus").setup({
                enable = false
            })
            dapui.open({
                reset = true
            })
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            if _debugging then
                _G._debugging = false
                dapui.close()
                require("focus").setup({
                    enable = true
                })
            end
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            if _debugging then
                _G._debugging = false
                dapui.close()
                require("focus").setup({
                    enable = true
                })
            end
        end
    end
}
