-- https://github.com/stevearc/aerial.nvim
-- 文件大纲, 用telescope 集成的快捷键做大纲
local bind = require("utils.bind")

return {
    "stevearc/aerial.nvim",
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"},

    config = function()
        require("aerial").setup({})
    end
}
