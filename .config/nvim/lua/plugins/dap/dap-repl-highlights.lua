-- https://github.com/LiadOz/nvim-dap-repl-highlights
-- Add syntax highlighting to the nvim-dap REPL buffer using treesitter.
return {
    "LiadOz/nvim-dap-repl-highlights",
    dependencies = {"mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter"},
    config = function()
        require("nvim-dap-repl-highlights").setup()
    end,
    build = function()
      if not require("nvim-treesitter.parsers").has_parser("dap_repl") then vim.cmd(":TSInstall dap_repl") end
    end,
}
