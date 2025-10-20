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
require("config.keymaps")
require("config.options")
require("config.autocmds")
require("config.lsp.bootstrap")
require("config.lazy")
