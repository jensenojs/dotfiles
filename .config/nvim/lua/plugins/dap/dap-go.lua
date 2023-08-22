-- https://github.com/leoluz/nvim-dap-go
-- An extension for nvim-dap providing configurations for launching go debugger (delve) and debugging individual tests.
return {
    'leoluz/nvim-dap-go',
    dependencies = {'mfussenegger/nvim-dap'},
    require('dap-go').setup()
}
