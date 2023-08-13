-- https://github.com/ibhagwan/smartyank.nvim
-- 在"dd"等不希望将内容复制到系统剪贴板的时候不复制到系统剪贴板。支持在SSH等情况复制到系统剪贴板
return {
    'ibhagwan/smartyank.nvim',
    lazy = true,
    event = {"BufRead", "BufNewFile"},
    config = true
}
