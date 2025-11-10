# WezTerm Configuration Repository

## Project Overview

This is a sophisticated, production-ready WezTerm terminal emulator configuration written in Lua. WezTerm is a GPU-accelerated, cross-platform terminal emulator, and this configuration provides a complete, modular setup with advanced features optimized for performance and usability.

**Key Design Principles:**
- **Simple over Complex** (KISS principle) - Avoid over-abstraction, keep code direct and clear
- **Modular Organization** with single responsibility - 5 core configuration modules
- **Cross-platform Support** - Automatic OS-specific configuration for macOS/Linux/Windows
- **Performance Optimized** - GPU acceleration, throttling, and efficient resource usage
- **Configuration as Documentation** - Self-explanatory code with clear comments

## Technology Stack & Architecture

### Core Technologies
- **Language**: Lua (LuaJIT runtime) - ~800 lines of core code
- **Terminal**: WezTerm (GPU-accelerated cross-platform terminal)
- **Platform Detection**: Automatic OS-specific configuration via `config/platform.lua`
- **GPU Acceleration**: WebGPU/OpenGL with intelligent adapter selection
- **Development Tools**: Luacheck (linting), StyLua (formatting), Lua Language Server (LSP)

### Directory Structure
```
~/.config/wezterm/
├── wezterm.lua           # Entry point (56 lines) - main configuration orchestrator
├── config/               # Core configuration modules
│   ├── platform.lua      # Platform detection & abstraction (must load first)
│   ├── options.lua       # General settings, fonts, performance tuning
│   ├── appearance.lua    # Visual settings, themes, window management
│   ├── keymaps.lua       # Keyboard shortcuts & leader key system
│   ├── mouse.lua         # Mouse bindings & quick select patterns
│   ├── events.lua        # Event handlers, status bar, command palette
│   └── hyperlinks.lua    # Smart file link handling (cd for dirs, nvim for files)
├── utils/                # Utility modules
│   ├── colors.lua        # Gruvbox color scheme definitions
│   ├── backdrops.lua     # Background image management (optional feature)
│   ├── gpu-adapter.lua   # GPU selection logic for performance
│   └── show-gpu-info.lua # GPU diagnostics utility
├── backdrops/            # Optional background images directory
└── docs/                 # Comprehensive documentation
    ├── ARCHITECTURE.md   # Detailed architecture and design decisions
    ├── KEYBINDINGS.md    # Complete keyboard shortcut reference
    ├── EVENTS.md         # Event system and status bar configuration
    └── FEATURES.md       # Feature overview and usage examples
```

## Key Features & Capabilities

### 1. Leader Key System (Tmux-style)
- **Leader Key**: `Ctrl+Space` (configurable timeout: 1000ms)
- **Purpose**: Avoid shortcut conflicts with other applications
- **Status Indicator**: Visual feedback in status bar (🌊 LEADER)
- **Modal Interface**: Nested workspace sub-mode for project management

### 2. Cross-platform Intelligence
- **Smart Modifier Keys**: `Cmd` on macOS, `Alt` on Linux/Windows
- **Shell Detection**: Automatic shell selection per platform
- **Platform-specific Paths**: Home directory, path separators
- **Window Management**: OS-specific decorations and behaviors

### 3. Performance Optimizations
- **GPU Adapter Selection**: Intelligent GPU picking for best performance
- **Frame Rate Limiting**: 60fps cap to prevent resource waste
- **Throttled Updates**: Status bar updates every 5 seconds
- **Optimized Buffers**: 10,000 line scrollback with performance tuning
- **Startup Time**: <100ms cold start

### 4. Advanced Terminal Features
- **Workspace Management**: Project isolation with fuzzy switching
- **Command Palette**: Discoverable command interface (`Leader+P` or `MOD+Shift+P`)
- **Vim Copy Mode**: Efficient keyboard text selection with vim bindings
- **Smart Hyperlinks**: Context-aware file opening
- **Quick Select Patterns**: Enhanced text selection for URLs, paths, git hashes

### 5. Visual Customization
- **Gruvbox Dark Theme**: Complete color palette with custom schemes
- **Optional Backgrounds**: Image cycling with opacity and blur controls
- **Smart Tab Bar**: Bottom placement with Gruvbox styling
- **Font Configuration**: Monaco Nerd Font Mono with fallbacks

## Development Workflow

### Code Quality Standards
- **Linting**: Luacheck (`.luacheckrc`) - Lua static analysis
  - Max line length: 150 characters
  - Max comment line length: 200 characters
  - Ignores unused variables (code 241)
- **Formatting**: StyLua (`.stylua.toml`) - 3-space indentation, 100 char width
- **LSP Support**: Lua Language Server (`.luarc.json`) - IntelliSense and diagnostics

### Essential Development Commands
```bash
# Test configuration syntax and validate leader workflows
wezterm start --config-file "$(pwd)/wezterm.lua"

# Reload running WezTerm instance after editing
wezterm cli reload-config

# Check font configuration and fallback chain
wezterm --config-file "$(pwd)/wezterm.lua" ls-fonts

# Debug with detailed logging
WEZTERM_LOG=wezterm=trace wezterm start --config-file wezterm.lua
```

### Testing Strategy
1. **Hot Reload Safety**: Ensure changes don't break configuration reloading
2. **Leader Key Testing**: Verify `Ctrl+Space` activates leader mode
3. **Cross-platform Testing**: Test on macOS, Linux, and Windows
4. **Performance Testing**: Monitor CPU/memory usage with status bar
5. **Visual Testing**: Smoke-test appearance changes across platforms

## Module API & Conventions

### Configuration Module Pattern
All configuration modules follow consistent patterns:

```lua
-- Module returns table named M
local M = {}

-- Apply function for configuration modules
function M.apply(config, platform)
    -- Configuration logic here
end

-- Setup function for optional features
function M.setup(options)
    -- Optional feature setup
end

return M
```

### Platform Abstraction
The `platform` module provides cross-platform helpers:
- `platform.is_mac/linux/windows` - OS detection
- `platform.mod` - Primary modifier key (Cmd/Alt)
- `platform.get_default_prog()` - Shell selection with login flag support
- `platform.path_separator()` - OS-specific path separators

### Event System Architecture
Events module uses WezTerm's event system for:
- Status bar updates (CPU/memory monitoring)
- Tab title customization
- Command palette enhancement
- GUI startup behavior

## Configuration Highlights

### Font Configuration
- **Primary**: Monaco Nerd Font Mono
- **Fallbacks**: JetBrains Mono, Sarasa Term SC Nerd, SF Pro
- **Features**: Ligatures disabled, custom line height (1.2)
- **Size**: 13.0 points with antialiasing

### Key Binding Architecture
- **MOD Layer**: Minimal system operations (avoiding conflicts)
- **LEADER Layer**: WezTerm-specific functions
- **Workspace Sub-mode**: Nested modal interface
- **Essential Shortcuts**: Tab management, pane splitting, copy mode

### Status Bar Features
- **Left Side**: Leader indicator, current workspace
- **Right Side**: CPU usage, memory usage (throttled updates)
- **Customization**: Configurable via events module setup
- **Performance**: Updates every 5 seconds to prevent CPU usage

## Optional Features

### Background Images (Disabled by Default)
- **Configuration**: Enable in `config/appearance.lua`
- **Controls**: Cycle through images with leader key shortcuts
- **Effects**: Adjustable opacity and blur for visual comfort
- **Directory**: `backdrops/` stores optional background images

### Command Palette Enhancement
- **Discovery**: Easy-to-find commands with icons
- **Fuzzy Search**: Quick command filtering
- **Custom Commands**: Workspace switching, configuration reload
- **Keyboard Access**: `Leader+P` or platform-specific shortcut

## Security & Best Practices

### Configuration Security
- **No Secrets**: Never embed sensitive data in configuration
- **Platform Isolation**: Route OS differences through platform module
- **Strict Mode**: Always enabled to catch errors early
- **Relative Paths**: Use config directory references for portability

### Performance Considerations
- **Throttling**: Status updates limited to prevent CPU usage
- **Lazy Loading**: Optional features disabled by default
- **Resource Management**: Efficient GPU usage and memory management
- **Error Handling**: Graceful fallbacks for missing dependencies

## Documentation Standards

### Code Documentation
- **Comments**: Explain non-obvious logic and platform-specific decisions
- **Module Headers**: Brief description of module purpose
- **Function Documentation**: Parameter and return value descriptions
- **Examples**: Include usage examples for complex features

### User Documentation
- **Chinese Primary**: README.md and docs in Chinese
- **Architecture Docs**: Detailed technical specifications
- **Keybinding References**: Complete shortcut lists
- **Feature Guides**: Step-by-step configuration instructions

## Commit & Contribution Guidelines

### Conventional Commits
Follow Conventional Commits format for changelog automation:
- `feat:` - New features
- `fix:` - Bug fixes
- `chore:` - Maintenance tasks
- `docs:` - Documentation updates

### Pull Request Standards
- **Test Commands**: Document manual testing performed
- **Screenshots**: Include before/after for visual changes
- **Doc References**: Link to updated documentation
- **Motivation**: Explain the reasoning for changes

### Code Review Criteria
- **Hot Reload Safety**: Changes must not break configuration reloading
- **Cross-platform Compatibility**: Test on multiple operating systems
- **Performance Impact**: Monitor for resource usage increases
- **Documentation Updates**: Keep docs synchronized with code changes

This configuration represents a mature, well-engineered terminal setup that balances functionality, performance, and maintainability while providing extensive customization options for power users.