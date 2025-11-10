-- 启用 Lua 字节码缓存，提升启动性能
if vim.loader then
    vim.loader.enable()
end

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
local ok_keymaps = pcall(require, "config.keymaps")
if not ok_keymaps then
    vim.notify("加载 keymaps 配置失败", vim.log.levels.ERROR)
end

local ok_options = pcall(require, "config.options")
if not ok_options then
    vim.notify("加载 options 配置失败", vim.log.levels.ERROR)
end

local ok_autocmds = pcall(require, "config.autocmds")
if not ok_autocmds then
    vim.notify("加载 autocmds 配置失败", vim.log.levels.ERROR)
end

-- 加载 LSP 基础配置（命令、handlers、diagnostic 设置、autocmds）
-- 注意：LSP 服务器在此处即注册并启用，不依赖 lazy.nvim
local ok_lsp_bootstrap = pcall(require, "config.lsp.bootstrap")
if not ok_lsp_bootstrap then
    vim.notify("加载 LSP bootstrap 配置失败", vim.log.levels.ERROR)
end

-- 加载 lazy.nvim 插件管理器
local ok_lazy = pcall(require, "config.lazy")
if not ok_lazy then
    vim.notify("加载 lazy.nvim 失败", vim.log.levels.ERROR)
end
