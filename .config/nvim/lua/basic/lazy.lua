-- 来自nvim-tree的要求
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 如果没有安装 lazy.nvim
-- 则自动安装
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
                   lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- 配置lazy.nvim
require("lazy").setup({
    spec = {{
        -- 让neo-vim更漂亮的插件
        import = "plugins.beautify"
    }, {
        -- 让neo-vim输入/移动更高效的插件
        import = "plugins.cursor"
    }, {
        -- 让neo-vim有能匹敌ide能力的插件
        import = "plugins.ide"
    }, {
        -- which-key
        import = "plugins"
    }},

    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false, -- 不懒加载, 目前懒加载会导致coc-nvim有些问题
        -- version = "*" -- 尝试安装支持语义化版本控制的插件的最新稳定版本。
        version = false   -- 不显示版本信息, 总是使用最新的插件
    },

    install = {
        colorscheme = {"gruvbox"}
    }, -- 安装颜色主题插件

    checker = {
        -- 每次打开的时候尝试自动更新
        enabled = false
    },

    concurrency = 24,
    performance = {
        rtp = {
            -- 禁用一些rtp插件
            disabled_plugins = {"gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin"}
        }
    }
})
