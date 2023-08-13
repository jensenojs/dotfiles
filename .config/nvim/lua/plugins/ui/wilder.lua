-- https://github.com/gelguy/wilder.nvim
-- wilder.nvim adds new features and capabilities to wildmenu.
-- Automatically provides suggestions as you type
--  : cmdline support - autocomplete commands, expressions, filenames, etc.
--  / search support - get search suggestions from the current buffer
-- High level of customisation
--  build your own custom pipeline to suit your needs
--  customisable look and appearance
return {
    'gelguy/wilder.nvim',
    config = function()
        local wilder = require('wilder')
        wilder.setup({
            modes = {":", "/", "?"}
        })
    end
}
