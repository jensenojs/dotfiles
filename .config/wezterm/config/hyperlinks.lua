-- 超链接处理模块
-- 参考 https://wezterm.org/recipes/hyperlinks.html
-- 职责: 拦截 WezTerm 发出的 open-uri 事件, 对 file:// 链接执行上下文感知的动作
local wezterm = require('wezterm')

-- By default, ls doesn't generate hyperlinks, here is an example of aliases to enable them in some common tools:
local M = {}

--- 判定当前前台进程是否为交互式 shell
--- 设计动机: 只有在 shell 中我们才可以安全地发送 cd/ls/nvim 等命令
--- @param foreground_process_name string 完整的进程路径或名称
--- @return boolean
local function is_shell(foreground_process_name)
    local shell_names = {'bash', 'zsh', 'fish', 'sh', 'ksh', 'dash', 'nu', 'pwsh'}
    local process = string.match(foreground_process_name, '[^/\\]+$') or foreground_process_name
    for _, shell in ipairs(shell_names) do
        if process == shell then
            return true
        end
    end
    return false
end

--- 注册 open-uri 事件处理器
--- 功能流程:
---   1. 仅处理 file:// 且当前 pane 不处于 Alt Screen (如 less/nvim)
---   2. 若前台为 shell, 使用本地 `file` 命令区分目录/文本
---   3. 目录 -> `cd` 并 `ls`
---      文本 -> `nvim` 打开, 支持 fragment(#L) 行号跳转
---   4. 若不是 shell (如 SSH 远端), 构造回退命令在远端执行
function M.setup()
    wezterm.on('open-uri', function(window, pane, uri)
        local editor = 'nvim' -- 可按需替换首选编辑器

        if uri:find('^file:') == 1 and not pane:is_alt_screen_active() then
            local url = wezterm.url.parse(uri)

            if is_shell(pane:get_foreground_process_name()) then
                -- Shell 场景: 利用本地 `file` 命令确定目标类型
                local success, stdout, _ = wezterm.run_child_process({'file', '--brief', '--mime-type', url.file_path})

                if success then
                    if stdout:find('directory') then
                        -- 点击目录: 进入并列出内容, 同时保留超链接属性
                        pane:send_text(wezterm.shell_join_args({'cd', url.file_path}) .. '\r')
                        pane:send_text(wezterm.shell_join_args({'ls', '-a', '-p', '--group-directories-first'}) .. '\r')
                        return false
                    end

                    if stdout:find('text') then
                        -- 点击文本: 按需跳转行号并打开
                        if url.fragment then
                            pane:send_text(wezterm.shell_join_args({editor, '+' .. url.fragment, url.file_path}) .. '\r')
                        else
                            pane:send_text(wezterm.shell_join_args({editor, url.file_path}) .. '\r')
                        end
                        return false
                    end
                end
            else
                -- 非 shell (例如 SSH pane): 构造在远端执行的脚本, 保留原有能力
                local edit_cmd = url.fragment and editor .. ' +' .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
                local cmd = '_f="' .. url.file_path .. '"; ' ..
                                '{ test -d "$_f" && { cd "$_f" ; ls -a -p --hyperlink --group-directories-first; }; } ' ..
                                '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && ' ..
                                edit_cmd .. '; }; echo'
                pane:send_text(cmd .. '\r')
                return false
            end
        end
    end)
end

return M
