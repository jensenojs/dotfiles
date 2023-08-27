-- https://github.com/b0o/incline.nvim
-- 给每个window一个标签显示它的名字
return {
    "b0o/incline.nvim",
    config = function()
        require('incline').setup()
    end
}
