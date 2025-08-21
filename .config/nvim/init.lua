-- 环境特征可选打印, 便于调试
local ok_env, env = pcall(require, "config.env")
if ok_env and not vim.g.__tmp_env_printed then
	vim.g.__tmp_env_printed = true
	vim.schedule(function()
		vim.notify("[tmp] config.env => " .. env.summary(), vim.log.levels.INFO, { title = "tmp/init" })
	end)
end

-- 避免重复加载
if vim.g.__tmp_config_bootstrapped then
	return
end
vim.g.__tmp_config_bootstrapped = true

require("config.global")
pcall(function()
	require("config.clipboard").setup()
end)
pcall(function()
	require("config.shell").setup()
end)
require("config.keymaps")
require("config.options")
require("config.autocmds")
require("config.lsp.bootstrap")
require("config.lazy")

