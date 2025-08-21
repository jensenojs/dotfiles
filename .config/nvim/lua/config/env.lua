--[[
模块: config.env

意图:
  以“单一配置可在离线/受限网络环境下工作”为目标, 提供最小但可扩展的环境感知能力.
  该模块无副作用, 仅暴露探测结果与简单的派生策略, 供 config.lazy 或插件配置按需降级/裁剪.

设计要点:
  - 避免耗时与不稳定的外网探测; 以显式环境变量为主, 可执行文件可用性为辅.
  - 提供稳定的布尔特征位, 不直接耦合具体插件名, 以支持上层灵活组合.
  - 兼容 Neovim 0.9/0.10: 不依赖 0.10 的 vim.system.

使用建议:
  - 通过设置环境变量 NVIM_OFFLINE=1 显式进入离线模式.
  - 在插件层按 env.minimal_mode/has_* 进行条件加载或禁用更新.
]]

local M = {}

-- 平台特征
local sys = vim.loop.os_uname().sysname
M.is_mac = sys == "Darwin"
M.is_linux = sys == "Linux"
M.is_windows = sys == "Windows_NT"
M.is_wsl = vim.fn.has("wsl") == 1

-- 可执行文件探测
local function has(exe)
  return vim.fn.executable(exe) == 1
end

M.has = {
  git = has("git"),
  rg = has("rg"),
  fd = has("fd") or has("fdfind"),
  nvr = has("nvr"),
  im_select = has("im-select"),
}

-- 离线/最小模式
-- 优先由环境变量控制, 避免网络探测带来的不可预期延迟
M.offline = tostring(vim.env.NVIM_OFFLINE or "") == "0"
M.minimal_mode = M.offline or not M.has.git

-- 简要说明, 便于日志/诊断
function M.summary()
  return string.format(
    "offline=%s, minimal=%s, has(git=%s, rg=%s, fd=%s, nvr=%s, im-select=%s)",
    tostring(M.offline), tostring(M.minimal_mode),
    tostring(M.has.git), tostring(M.has.rg), tostring(M.has.fd), tostring(M.has.nvr), tostring(M.has.im_select)
  )
end

return M
