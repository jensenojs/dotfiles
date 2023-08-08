-- https://github.com/jesseduffield/lazygit
-- 符合vim直觉的git CUI 
local opts = {
    noremap = true, -- non-recursive
    silent = true -- do not show message
}

return {
    'kdheepak/lazygit.nvim',
    -- optional for floating window border decoration
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
        vim.g.lazygit_floating_window_winblend = 0
        vim.g.lazygit_use_neovim_remote = true
        vim.keymap.set('n', '<leader>G', ':LazyGit<CR>', opts, {
            desc = '<leader>+G : 打开LazyGit'
        })
    end
}
