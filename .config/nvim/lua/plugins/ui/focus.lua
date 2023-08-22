-- https://github.com/nvim-focus/focus.nvim
-- Always have a nice view over your split windows
local ignore_filetypes = {'NvimTree', 'NvimTree_'}
local ignore_buftypes = {'nofile', 'prompt', 'popup'}

local augroup = vim.api.nvim_create_augroup('FocusDisable', {
    clear = true
})

vim.api.nvim_create_autocmd('WinEnter', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) 
        then
            vim.w.focus_disable = true
        else
            vim.w.focus_disable = false
        end
    end,
    desc = 'Disable focus autoresize for BufType'
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) 
        then
            vim.w.focus_disable = true
        else
            vim.w.focus_disable = false
        end
    end,
    desc = 'Disable focus autoresize for FileType'
})

return {
    'nvim-focus/focus.nvim',
    config = function()
        require'focus'.setup({
            excluded_filetypes = {"NvimTree"}
        })
    end
}
