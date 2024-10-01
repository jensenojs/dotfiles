-- https://github.com/daipeihust/im-select
return {
    -- should install im-select first, see
    "keaising/im-select.nvim",
    event = "InsertEnter",
    config = function()
      require("im_select").setup({})
    end,
  }