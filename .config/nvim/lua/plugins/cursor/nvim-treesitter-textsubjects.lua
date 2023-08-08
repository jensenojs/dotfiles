-- https://github.com/RRethy/nvim-treesitter-textsubjects
-- 根据光标位置自动决定要选中什么textobject
-- 使用方式：快捷键使用（以v选中模式举例）
-- v.：根据光标位置，智能选择
-- v,：选中上一次选中的范围
-- v;：选中容器外围
-- vi;：选中容器内
-- <leader>+a : 
return {
    "RRethy/nvim-treesitter-textsubjects",
    -- lazy = true,
    -- event = {"User FileOpened"},
    after = "nvim-treesitter",
    dependencies = {"nvim-treesitter/nvim-treesitter"},
    config = function()
        require("nvim-treesitter.configs").setup({
            textsubjects = {
                enable = true,
                prev_selection = ",",
                keymaps = {
                    ["."] = "textsubjects-smart",
                    [";"] = "textsubjects-container-outer",
                    ["i;"] = "textsubjects-container-inner"
                },
                include_surrounding_whilespace = false
            }
        })
    end
}
