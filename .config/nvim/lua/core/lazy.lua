local fn, api = vim.fn, vim.api
local global = require("core.global")
local is_mac = global.is_mac
local vim_path = global.vim_path
local data_dir = global.data_dir
local lazy_path = data_dir .. "lazy/lazy.nvim"
local modules_dir = vim_path .. "/lua/modules"

local icons = {
    kind = require("utils.icons").get("kind"),
    documents = require("utils.icons").get("documents"),
    ui = require("utils.icons").get("ui"),
    ui_sep = require("utils.icons").get("ui", true),
    misc = require("utils.icons").get("misc")
}

-- 如果没有安装 lazy.nvim 则自动安装
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
                   lazypath})
end

vim.opt.rtp:prepend(lazypath)

-- 配置lazy.nvim
require("lazy").setup({
    -- 把插件导入
    spec = {{
        -- 让neo-vim更漂亮的插件
        import = "plugins.ui"
    }, {
        -- 让neo-vim输入/移动更高效的插件
        import = "plugins.cursor"
    }, {
        -- 特定语言的支持
        import = "plugins.lang"
    }, {
        -- 让neo-vim有ide能力的插件
        import = "plugins.ide"
    }, {
        -- 让neo-vim有调试能力的插件
        import = "plugins.dap"
    }, {
        -- which-key
        import = "plugins"
    }},

    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false, -- 不懒加载, 目前懒加载会导致coc-nvim有些问题
        -- version = "*" -- 尝试安装支持语义化版本控制的插件的最新稳定版本, 不能用这个, 不然telescope会出问题
        version = false -- 不显示版本信息, 总是使用最新的插件
    },

    install = {
        -- install missing plugins on startup. This doesn't increase startup time.
        missing = true,
        colorscheme = {"gruvbox"}
    },

    checker = {
        -- 每次打开的时候尝试自动更新
        enabled = false
    },

    ui = {
        -- a number <1 is a percentage., >1 is a fixed size
        size = {
            width = 0.88,
            height = 0.8
        },
        wrap = true, -- wrap the lines in the ui
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "rounded",

        icons = {
            cmd = icons.misc.Code,
            config = icons.ui.Gear,
            event = icons.kind.Event,
            ft = icons.documents.Files,
            init = icons.misc.ManUp,
            import = icons.documents.Import,
            keys = icons.ui.Keyboard,
            loaded = icons.ui.Check,
            not_loaded = icons.misc.Ghost,
            plugin = icons.ui.Package,
            runtime = icons.misc.Vim,
            source = icons.kind.StaticMethod,
            start = icons.ui.Play,
            list = {icons.ui_sep.BigCircle, icons.ui_sep.BigUnfilledCircle, icons.ui_sep.Square,
                    icons.ui_sep.ChevronRight}
        }
    },

    concurrency = 24,
    performance = {
        cache = {
            enabled = true,
            path = vim.fn.stdpath("cache") .. "/lazy/cache",
            -- Once one of the following events triggers, caching will be disabled.
            -- To cache all modules, set this to `{}`, but that is not recommended.
            disable_events = {"UIEnter", "BufReadPre"},
            ttl = 3600 * 24 * 2 -- keep unused modules for up to 2 days
        },
        reset_packpath = true -- reset the package path to improve startup time
    }
})
