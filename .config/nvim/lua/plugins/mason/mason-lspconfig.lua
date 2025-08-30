-- Purpose: use mason-lspconfig only for installation (ensure_installed)

return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      local ensure = {}
      pcall(function()
        ensure = require("utils.mason").servers()
      end)
      return {
        ensure_installed = ensure,
        automatic_installation = function()
          return not require("config.environment").offline
        end,
      }
    end,
  },
}
