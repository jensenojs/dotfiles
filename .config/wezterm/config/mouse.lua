-- Mouse bindings configuration
-- Handles trackpad gestures and mouse events
local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config, platform)
    local mod = platform.mod -- SUPER (Cmd) on macOS, ALT on Linux

    -- ============================================================================
    -- Mouse Bindings
    -- ============================================================================

    config.mouse_bindings = { -- 触控板双指轻点 -> 粘贴 / 选区复制
    -- macOS 会把双指轻点映射为右键点击
    {
        event = {
            Down = {
                streak = 1,
                button = 'Right'
            }
        },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act.PasteFrom('Clipboard'), pane)
            end
        end)
    }, -- Cmd+点击(或 Alt+点击 on Linux) 打开超链接
    -- macOS: Cmd+点击是标准行为
    -- Linux: Alt+点击(因为 Ctrl+点击常用于多选)
    {
        event = {
            Up = {
                streak = 1,
                button = 'Left'
            }
        },
        mods = mod,
        action = act.OpenLinkAtMouseCursor
    }, {
        event = {
            Down = {
                streak = 1,
                button = 'Left'
            }
        },
        mods = mod,
        action = act.Nop
    }}

    -- ============================================================================
    -- Quick Select Patterns (智能选择增强)
    -- ============================================================================

    -- 增强快速选择, 支持更多模式
    config.quick_select_patterns = { -- 匹配文件路径(支持相对路径和绝对路径)
    '[./~]?[a-zA-Z0-9._/-]+\\.[a-zA-Z0-9]+', -- 匹配 URL(支持 http/https)
    'https?://[a-zA-Z0-9._/-]+(?:\\?[a-zA-Z0-9._/-&=]*)?', -- 匹配 Git 提交哈希(7-40位)
    '[0-9a-f]{7,40}', -- 匹配邮箱地址
    '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}', -- 匹配 IP 地址
    '\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b', -- 匹配端口号
    ':\\d{1,5}\\b', -- 匹配 UUID
    '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', -- 匹配时间戳(Unix 时间戳)
    '\\b\\d{10}\\b', -- 匹配容器 ID(Docker 等)
    '[a-f0-9]{12,64}'}
end

return M
