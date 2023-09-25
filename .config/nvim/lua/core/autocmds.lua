-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- 定义一个函数，用于创建自动命令组
local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, {
        clear = true
    })
end

-- 当光标焦点重新回到neovim窗口（FocusGained）、关闭终端（TermClose）或离开终端（TermLeave）时
-- 检查文件是否被修改，并决定是否重新加载
vim.api.nvim_create_autocmd({"FocusGained", "TermClose", "TermLeave"}, {
    group = augroup("checktime"),
    command = "checktime"
})

-- 当文本被yank（复制）后，高亮该文本
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end
})

-- 当窗口大小被调整时，调整窗口内的分屏大小
vim.api.nvim_create_autocmd({"VimResized"}, {
    group = augroup("resize_splits"),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end
})

-- 对于一些特定的文件类型，按下q键即可关闭该buffer
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {"PlenaryTestPopup", "help", "lspinfo", "man", "notify", "qf", "spectre_panel", "startuptime",
               "tsplayground", "neotest-output", "checkhealth", "neotest-summary", "neotest-output-panel"},
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer = event.buf,
            silent = true
        })
    end
})

-- 对于一些文本文件类型，自动开启换行和拼写检查
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = {"gitcommit", "markdown"},
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- fix couldn't fold any code segments in files which were opened using telescope
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337#issuecomment-1397639999
vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*"},
    command = "normal zx"
})
