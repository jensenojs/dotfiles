-- lua/utils/lsp.lua
-- LSP 运行时辅助: 通知/可选加载/能力合并/可执行探测/条件启用
local M = {}

-- 一次性通知, 避免噪音
function M.notify_once(flag, msg, level)
    local key = "__lsp_bootstrap_notified_" .. flag
    if vim.g[key] then
        return
    end
    vim.g[key] = true
    vim.schedule(function()
        vim.notify(msg, level or vim.log.levels.WARN, {
            title = "lsp/utils"
        })
    end)
end

-- 温和可选加载: 返回模块或 nil
function M.require_opt(mod)
    local ok, res = pcall(require, mod)
    if not ok then
        M.notify_once("missing_" .. mod, string.format("可选模块未找到: %s (已跳过)", mod),
            vim.log.levels.DEBUG)
        return nil, res
    end
    return res
end

-- 合并全局 capabilities: 优先对接 blink.cmp
function M.apply_caps()
    local caps
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink and blink and type(blink.get_lsp_capabilities) == "function" then
        caps = blink.get_lsp_capabilities()
    end
    if type(vim.lsp.config) == "function" then
        local cfg = {}
        if caps ~= nil then
            cfg.capabilities = caps
        end
        vim.lsp.config("*", cfg)
    end
end

-- 检测任一可执行是否存在
function M.has_any_exec(cmds)
    local list = type(cmds) == "table" and cmds or {cmds}
    for _, c in ipairs(list) do
        if vim.fn.executable(c) == 1 then
            return true, c
        end
    end
    return false, nil
end

-- 若存在对应可执行文件则启用 LSP, 否则给出一次性温和提醒
function M.enable_if_present(server, opts)
    opts = opts or {}
    local ok_exec = true
    if opts.execs then
        ok_exec = M.has_any_exec(opts.execs)
    end
    if ok_exec then
        pcall(vim.lsp.enable, server)
    else
        local hint = opts.missing_hint or ("未检测到依赖, 已跳过自动启动: " .. server)
        M.notify_once("missing_exec_" .. server, hint, vim.log.levels.INFO)
    end
end

return M
