local function load_codestral_api_key()
    local key = vim.fn.getenv("CODESTRAL_API_KEY")
    if key ~= vim.NIL and key ~= "" then
        vim.env.CODESTRAL_API_KEY = key
    end
end

load_codestral_api_key()

local ok_env, env = pcall(require, "config.environment")
-- if ok_env and not vim.g.__tmp_env_printed then
-- 	vim.g.__tmp_env_printed = true
-- 	vim.schedule(function()
-- 		vim.notify("[config.environment] => " .. env.summary(), vim.log.levels.INFO, { title = "tmp/init" })
-- 	end)
-- end

-- 加载核心配置（按键、选项、自动命令）
require("config.keymaps")
require("config.options")
require("config.autocmds")

-- 加载 LSP 基础配置（命令、handlers、diagnostic 设置）
-- 注意：这里只加载基础配置，不启动 LSP 服务器
-- LSP 服务器在 lazy.nvim 加载完成后启动，确保 neotest 等插件已就绪
require("config.lsp.bootstrap")

-- 加载 lazy.nvim 插件管理器
require("config.lazy")

-- 在 lazy.nvim 加载完成后，为已打开的 buffer 启用 LSP
-- 这确保了 neotest 等插件已就绪，避免测试识别问题
vim.schedule(function()
    local ok, bootstrap = pcall(require, "config.lsp.bootstrap")
    if ok and bootstrap.enable_lsp_for_opened_buffers then
        bootstrap.enable_lsp_for_opened_buffers()
    end
end)
