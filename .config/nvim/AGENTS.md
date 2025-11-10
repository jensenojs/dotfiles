# AGENTS.md

## Build/Lint/Test Commands

### Formatting
- **Lua**: `stylua` (via conform.nvim)
- **Python**: `ruff_format` or `isort` + `black`
- **Go**: `goimports` + `gofmt`
- **C/C++**: `clang-format`
- **Rust**: `rustfmt`
- **Shell**: `shfmt -i 2`
- **JSON**: `jq`
- **SQL**: `sqlfmt`

### Linting
- **Lua**: `selene` (recommended), `luacheck` (available)

### Testing
- **Framework**: neotest with language-specific adapters
- **Run nearest test**: `<space>tn`
- **Debug nearest test**: `<space>td`
- **Run file tests**: `<space>tf`
- **Run all tests**: `<space>tA`
- **Toggle test summary**: `<space>ts`
- **Show test output**: `<space>to`
- **Toggle watch mode**: `<space>tw`

## Code Style Guidelines

### Lua Style
- Use `local` for all variable/function declarations
- Use `vim.opt` for Neovim options (e.g., `vim.opt.expandtab = true`)
- Use `require()` for module imports at file top
- Use `pcall()` for error handling when loading optional modules
- Functions: `local function name() ... end`
- Tables: Use consistent indentation, trailing commas optional
- Comments: Chinese comments preferred, English for technical terms

### Naming Conventions
- Functions: `camelCase` or `snake_case` (consistent within file)
- Variables: `snake_case` for locals, `CamelCase` for globals
- Files: `snake_case.lua`
- Modules: Match directory structure

### Imports and Dependencies
- Group imports at file top
- Use local aliases: `local bind = require("utils.bind")`
- Check module availability: `local ok, module = pcall(require, "module")`
- Remove unused imports immediately

### Error Handling
- Use `pcall()` for all module loading with detailed error messages
- Include error context in notifications: `tostring(error)`
- Add notification titles for better error tracking
- Graceful degradation for missing dependencies
- Validate loaded modules before use

### Performance Optimizations
- Enable Lua bytecode cache: `vim.loader.enable()` in init.lua
- Use lazy loading for plugins when possible
- Minimize synchronous operations during startup

### Formatting
- 4 spaces indentation (configured in options.lua)
- No tabs (expandtab = true)
- Trim trailing whitespace
- Auto-format on save (conform.nvim)</content>
<parameter name="filePath">AGENTS.md