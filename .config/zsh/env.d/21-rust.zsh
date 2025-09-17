# Rust 工具链配置 - Rust Toolchain Configuration

# Rust 环境变量(符合 XDG 规范)
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"

# 加载 Cargo 环境配置
source_if_exists "$CARGO_HOME/env"
