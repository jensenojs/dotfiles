-- 超链接处理模块
-- 参考 https://wezterm.org/recipes/hyperlinks.html
-- 职责: 拦截 WezTerm 发出的 open-uri 事件, 对 file:// 链接执行上下文感知的动作
local wezterm = require('wezterm')

-- By default, ls doesn't generate hyperlinks, here is an example of aliases to enable them in some common tools:
local M = {}

-- 已知的交互式 shell 列表
local SHELLS = {
    bash = true,
    zsh = true,
    fish = true,
    sh = true,
    ksh = true,
    dash = true,
    nu = true,
    pwsh = true
}

--- 判定当前前台进程是否为交互式 shell
--- 设计动机: 只有在 shell 中才可以安全地发送 cd/ls/nvim 等命令
--- @param foreground_process_name string|nil 完整的进程路径或名称
--- @return boolean
local function is_shell(foreground_process_name)
    if not foreground_process_name or foreground_process_name == '' then
        return false
    end
    local process = foreground_process_name:match('[^/\\]+$') or foreground_process_name
    return SHELLS[process] == true
end

--- 注册 open-uri 事件处理器
--- 功能流程:
---   1. 仅处理 file:// URI 且当前 pane 不处于 Alt Screen(如 less/nvim)
---   2. 本地 shell: 使用 `file` 命令判断类型
---      - 目录 -> cd + ls
---      - 文本 -> nvim(支持 #L 行号跳转)
---   3. 远程 pane(如 SSH): 构造在远端执行的命令
--- @param editor string|nil 可选的编辑器命令,默认 'nvim'
function M.setup(editor)
    editor = editor or 'nvim'

    wezterm.on('open-uri', function(window, pane, uri)
        -- 只处理 file:// 协议且不在 Alt Screen 模式(如 nvim/less)
        if not uri:find('^file:') or pane:is_alt_screen_active() then
            return false -- 让 WezTerm 处理其他协议(http/https)
        end

        do
            local url = wezterm.url.parse(uri)
            if not url or not url.file_path then
                return false
            end

            if is_shell(pane:get_foreground_process_name()) then
                -- ============================================================
                -- 本地 shell 场景: 使用 `file` 命令判断类型
                -- ============================================================
                local success, stdout, _ = wezterm.run_child_process({'file', '--brief', '--mime-type', url.file_path})

                if success and stdout then
                    if stdout:find('directory') then
                        -- 目录: cd + ls
                        pane:send_text(wezterm.shell_join_args({'cd', url.file_path}) .. '\r')
                        pane:send_text(wezterm.shell_join_args({'ls', '-a', '-p', '--group-directories-first'}) .. '\r')
                        return false
                    elseif stdout:find('text') then
                        -- 文本文件: 用编辑器打开(支持行号跳转)
                        local args = {editor}
                        if url.fragment then
                            table.insert(args, '+' .. url.fragment)
                        end
                        table.insert(args, url.file_path)
                        pane:send_text(wezterm.shell_join_args(args) .. '\r')
                        return false
                    end
                end
            else
                -- ============================================================
                -- 远程 pane(如 SSH): 构造在远端执行的命令
                -- ============================================================
                local fragment_arg = url.fragment and (' +' .. url.fragment) or ''
                local cmd = string.format('_f=%s; ' ..
                                              '{ test -d "$_f" && { cd "$_f"; ls -a -p --group-directories-first 2>/dev/null || ls -a; }; } || ' ..
                                              '{ test "$(file --brief --mime-type "$_f" 2>/dev/null | cut -d/ -f1)" = "text" && %s%s "$_f"; }',
                    wezterm.shell_quote_arg(url.file_path), editor, fragment_arg)
                pane:send_text(cmd .. '\r')
                return false
            end
        end
    end)
end

--- 快捷设置函数,使用自定义编辑器
--- @param editor string 编辑器命令,如 'vim', 'nano', 'code --wait'
--- @return table 模块引用
function M.setup_with_editor(editor)
    return M.setup(editor)
end

return M
