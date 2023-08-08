-- https://github.com/ellisonleao/glow.nvim
-- 一个轻量的markdown预览器
return {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",

    vim.keymap.set('c', 'md', "Glow", {}, {
        desc = '<leader>+<space> : 查找当前打开的buffer'
    })

}
