-- triggers CursorHold event faster
vim.opt.updatetime = 200

vim.api.nvim_create_autocmd({"WinScrolled", -- or WinResized on NVIM-v0.9 and higher
"BufWinEnter", "CursorHold", "InsertLeave", -- include this if you have set `show_modified` to `true`
"BufModifiedSet"}, {
    group = vim.api.nvim_create_augroup("barbecue.updater", {}),
    callback = function()
        require("barbecue.ui").update()
    end
})

-- https://github.com/utilyre/barbecue.nvim/issues/35
return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {"SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons"},
    opts = {
        -- configurations go here
    },
    config = function()
        require("barbecue").setup({})

    end

}
