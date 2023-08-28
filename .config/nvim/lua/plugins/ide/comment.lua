-- https://github.com/terrortylor/nvim-comment
-- 注释
return {
    "terrortylor/nvim-comment",
    config = function()
        require('nvim_comment').setup({
            line_mapping = "<c-/>",
            operator_mapping = "<c-?>",
        })
    end
}
