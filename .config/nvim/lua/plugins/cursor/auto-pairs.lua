-- https://github.com/windwp/nvim-autopairs
-- 自动匹配添加括号
return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {
        -- this is equalent to setup({}) function
        enable_check_bracket_line = true
    }
}
