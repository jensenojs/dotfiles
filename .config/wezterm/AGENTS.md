# Repository Guidelines

## Project Structure & Module Organization
Everything runs through `wezterm.lua`, which wires the feature modules under `config/`. Platform detection loads first (`config/platform.lua`), then option, appearance, keymap, mouse, event, and hyperlink modules add their scopes via `apply`/`setup` functions. Shared helpers (GPU adapter logic, backdrop utilities, palettes) live in `utils/`, while `backdrops/` stores optional images referenced by `utils/backdrops.lua`. Architecture notes, keybinding matrices, and feature specs are in `docs/`—treat those as the source of truth before touching behavior.

## Build, Test, and Development Commands
- `wezterm start --config-file "$(pwd)/wezterm.lua"` — launches a disposable terminal using the local tree; fastest way to validate syntax and leader workflows.
- `wezterm cli reload-config` — reloads a running WezTerm instance after you edit files; use it before committing to ensure hot-reload safety.
- `wezterm --config-file "$(pwd)/wezterm.lua" ls-fonts` — confirms the configured font fallback chain and surfaces font-missing warnings without opening a window.

## Coding Style & Naming Conventions
Lua modules return a table named `M` and expose `apply` or `setup` entry points; follow that API so `wezterm.lua` can require modules without additional glue. Use three-space indentation and keep sections separated by banner comments, matching the existing visual anchors. File names stay lowercase with words separated by dots (e.g., `config.hyperlinks`). Prefer descriptive tables over magic numbers, and log via `wezterm.log_*` for any diagnostics that might help during reloads.

## Testing Guidelines
Changes must preserve hot reload, leader key ergonomics, and status-bar cues. After editing, run the start command above, trigger `Ctrl+Space` to confirm the LEADER indicator, then walk through the updated bindings listed in `docs/KEYBINDINGS.md`. For events or status modules, start with `WEZTERM_LOG=wezterm=trace wezterm start --config-file ...` to watch for warnings. Visual tweaks should be smoke-tested across macOS (blur/backdrop paths) and Linux/Windows (fallback shell) because `config/platform.lua` branches per OS.

## Commit & Pull Request Guidelines
This configuration is often vendored without its `.git` folder, but the upstream history follows Conventional Commits (`feat:`, `fix:`, `chore:`) with imperative subjects—keep that format so changelog automation keeps working. Document observable impact in the body (e.g., “maps Leader+F to toggle full screen”) and link to any docs you touched. Pull requests should summarize motivation, note the manual test commands you ran, attach before/after screenshots for appearance tweaks, and reference related docs (ARCHITECTURE, KEYBINDINGS, EVENTS) so reviewers can trace every change back to its spec.

## Security & Configuration Tips
Do not embed secrets or host-specific paths inside modules; route OS differences through `config/platform.lua` helpers instead. When adding new assets, prefer relative references under `backdrops/` and keep optional features disabled by default, mirroring how `utils/backdrops.lua` is gated. Always leave strict mode enabled in `wezterm.lua` so configuration errors fail fast during reload.
