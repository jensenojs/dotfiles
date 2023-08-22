-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- 修复markdown缩进设置
vim.g.markdown_recommended_style = 0

-- 来自nvim-tree的要求
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- 设置nvim显示语法高亮
opt.syntax = "true"

-- 设置背景色
opt.background = "dark"

-- 禁用与vi兼容的模式，以便使用nvim的所有高级功能
opt.compatible = false

-- 总是显示标签页
opt.showtabline = 2

-- 命令行高为2，提供足够的显示空间
opt.cmdheight = 2

-- 当文件被外部程序修改时，自动加载
opt.autoread = true

-- 弹出菜单透明度
opt.pumblend = 10

-- 弹出菜单中的最大条目数
opt.pumheight = 10

-- 使用空格代替制表符
opt.expandtab = true

-- 格式化选项
opt.formatoptions = "jcroqlnt"

-- grep命令的输出格式
opt.grepformat = "%f:%l:%c:%m"

-- grep命令使用的工具
opt.grepprg = "rg --vimgrep"

-- 自动折行
opt.wrap = true

-- 禁用掉按键失效时的vim的回应
opt.report = 99999
opt.shortmess = astWAIc

-- 关闭错误提示声音
opt.errorbells = false

-- 让光标在有得选的情况下, 不会在最底部或者最顶部
opt.scrolloff = 10

-- 让光标在有得选的情况下, 不会在最左或者最右
opt.sidescrolloff = 8

-- 不显示模式，因为有状态栏
opt.showmode = false

-- 总是显示signcolumn，否则每次都会移动文本
opt.signcolumn = "yes"

-- 取消持久高亮
opt.hlsearch = false

-- vim命令的补全
opt.wildmenu = true

-- 打开 24 位真彩色支持
opt.termguicolors = true

-- 解决vim中delete键无法向左删除的问题
opt.backspace = 'indent,eol,start'

-- 设置制表符宽度为 4
opt.tabstop = 4

-- 设置缩进宽度为 4
opt.shiftwidth = 4

-- 缩进自动对齐
opt.shiftround = true

-- 在状态栏中显示（部分）命令
opt.showcmd = true

-- 显示匹配的括号
opt.showmatch = true

-- 隐藏粗体和斜体的*标记
opt.conceallevel = 3

-- 忽略大小写进行匹配
opt.ignorecase = true

-- 智能大小写匹配（当搜索文本有大写字母的时候会进行匹配）
opt.smartcase = true

-- 与系统剪贴板同步
opt.clipboard = "unnamedplus"

-- 增量搜索
opt.incsearch = true

-- 启用鼠标使用（所有模式）
opt.mouse = 'a'

-- 显示行号
opt.number = true

-- 设置相对行号
opt.relativenumber = true

-- 如果是nvim-0.9.0版本以上，则设置splitkeep和shortmess选项
if vim.fn.has("nvim-0.9.0") == 1 then
    opt.splitkeep = "screen"
    opt.shortmess:append({
        C = true
    })
end
