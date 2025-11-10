.PHONY: help format check clean

# 默认目标
help:
	@echo "WezTerm 配置管理"
	@echo ""
	@echo "可用命令:"
	@echo "  make format    - 格式化所有 Lua 文件"
	@echo "  make check     - 检查格式但不修改"
	@echo "  make clean     - 清理临时文件"
	@echo "  make validate  - 验证 WezTerm 配置"

# 格式化所有 Lua 文件
format:
	@echo "🎨 格式化 Lua 代码..."
	@stylua --config-path .stylua.toml .
	@echo "✅ 格式化完成"

# 检查格式（不修改）
check:
	@echo "🔍 检查代码格式..."
	@stylua --config-path .stylua.toml --check .
	@echo "✅ 格式检查完成"

# 验证 WezTerm 配置
validate:
	@echo "🔧 验证 WezTerm 配置..."
	@wezterm --config-file wezterm.lua --version > /dev/null && echo "✅ 配置有效" || echo "❌ 配置无效"

# 清理临时文件
clean:
	@echo "🧹 清理临时文件..."
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete
	@echo "✅ 清理完成"
