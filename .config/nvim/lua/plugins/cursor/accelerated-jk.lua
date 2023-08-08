-- https://github.com/rainbowhxch/accelerated-jk.nvim
-- 在连续按下j / k 的时候会提高其移速

local opts = {
    noremap = true, -- non-recursive
    silent = true -- do not show message
}

return {
    'rainbowhxch/accelerated-jk.nvim',
    config = function()
        vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_gj)', opts, {
            desc = 'j : 持续按下j键会提高向下的移动速度'
        })
        vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_gk)', opts, {
            desc = 'k : 持续按下k键会提高向上的移动速度'
        })
    end

}
