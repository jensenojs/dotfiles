-- https://github.com/rcarriga/nvim-dap-ui
-- 调试界面的配置
_G._debugging = false

local bind = require("utils.bind")
local map_cmd = bind.map_cmd

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

local icons = {
    ui = require("utils.icons").get("ui"),
    dap = require("utils.icons").get("dap")
}

return {
    "rcarriga/nvim-dap-ui",
    config = function()
        local dap = require('dap')
        local dapui = require("dapui")
        local status, mason_dap = pcall(require, "mason-nvim-dap")
        if not status then
            vim.notify("not found mason-nvim-dap")
            return
        end

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
                border = "single", -- Border style. Can be "single", "double" or "rounded"
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
        -- 打开调试界面的时候, 代码窗口关闭目录树和大纲
        dap.listeners.after.event_initialized["dapui_config"] = function()
            _G._debugging = true
            M.load_extras()
            local NvimTree = require "nvim-tree.api"
            NvimTree.tree.close()
            require("aerial").close()
            dapui.open({
                reset = true
            })
        end
        -- 关闭调试界面的时候, 代码窗口打开目录树和大纲
        dap.listeners.before.event_terminated["dapui_config"] = function()
            if _debugging then
                _G._debugging = false
                dapui.close()
                local NvimTree = require "nvim-tree.api"
                NvimTree.tree.open()
                require('aerial').toggle({
                    focus = false
                })
            end
        end
        -- 关闭调试界面的时候, 代码窗口打开目录树和大纲
        dap.listeners.before.event_exited["dapui_config"] = function()
            if _debugging then
                _G._debugging = false
                dapui.close()
                local NvimTree = require "nvim-tree.api"
                NvimTree.tree.open()
                require('aerial').toggle({
                    focus = false
                })
            end
        end

        ---A handler to setup all clients defined under `plugins/dap/clients/*.lua`
        ---@param config table
        local function mason_dap_handler(config)
            local dap_name = config.name
            ok, custom_handler = pcall(require, "plugins.dap.clients." .. dap_name)
            vim.notify(string.format("dap_name is %s ", dap_name), vim.log.levels.INFO, {
                title = "nvim-dap"
            })
            if not ok then
                -- Default to use factory config for clients(s) that doesn't include a spec
                mason_dap.default_setup(config)
                return
            elseif type(custom_handler) == "function" then
                -- Case where the protocol requires its own setup
                -- Make sure to set
                -- * dap.adpaters.<dap_name> = { your config }
                -- * dap.configurations.<lang> = { your config }
                -- See `codelldb.lua` for a concrete example.
                custom_handler(config)
            else
                vim.notify(string.format(
                    "Failed to setup [%s].\n\nClient definition under `plugins/dap/clients` must return\na fun(opts) (got '%s' instead)",
                    config.name, type(custom_handler)), vim.log.levels.ERROR, {
                    title = "nvim-dap"
                })
            end
        end

        -- require("utils").load_plugin("mason-nvim-dap", {
        mason_dap.setup({
            ensure_installed = require("utils.mason-list").get("dap", true),
            automatic_installation = true,
            handlers = {mason_dap_handler}
        })

    end
}
