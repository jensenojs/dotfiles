# AGENTS.md - Neovim Config

## Commands
- **Format**: `make format` or `<leader>F`
- **Check format**: `make check` (lint-style check)
- **Lint**: `make lint` (luacheck)
- **Validate config**: `make validate`
- **Run tests**: `make test` or `<space>tn` (neotest)
- **Debug test**: `<space>td` (neotest + dap)
- **File tests**: `<space>tf` | **All tests**: `<space>tA`
- **Install tools**: `make install`

## Style Guidelines
- **Lua**: 4 spaces, `local` everything, require() at top
- **Functions**: `local function name() ... end`
- **Variables**: `snake_case` locals, `CamelCase` globals
- **Error handling**: Use `pcall()` with detailed messages
- **Imports**: Group at top, use local aliases
- **Files**: `snake_case.lua` naming
- **Performance**: Lazy load plugins, bytecode cache

## Formatters
- **Lua**: stylua | **Python**: ruff/ruff_format/black | **Go**: goimports/gofmt | **C/C++**: clang-format | **Rust**: rustfmt | **Shell**: shfmt -i 2 | **JSON**: jq | **SQL**: sqlfmt</content>
<parameter name="filePath">AGENTS.md