.PHONY: help format check lint clean test install

# 默认目标
help:
	@echo "Neovim 配置管理"
	@echo ""
	@echo "可用命令:"
	@echo "  make format     - 格式化所有 Lua 文件"
	@echo "  make check      - 检查格式但不修改"
	@echo "  make lint       - 运行 luacheck 检查代码质量"
	@echo "  make clean      - 清理临时文件和缓存"
	@echo "  make test       - 运行测试"
	@echo "  make install    - 安装依赖工具"
	@echo "  make validate   - 验证配置文件"

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

# Lua 代码质量检查
lint:
	@echo "🔍 运行 luacheck..."
	@if command -v luacheck >/dev/null 2>&1; then \
		luacheck lua/ --globals vim; \
	else \
		echo "⚠️  luacheck 未安装，跳过"; \
		echo "   安装: brew install luacheck"; \
	fi

# 验证配置
validate:
	@echo "🔧 验证 Neovim 配置..."
	@nvim --headless -c "lua require('lazy').sync()" -c "qa" 2>&1 | grep -v "^$$" || true
	@echo "✅ 配置验证完成"

# 清理临时文件
clean:
	@echo "🧹 清理临时文件..."
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete
	@rm -rf .tests/
	@echo "✅ 清理完成"

# 安装依赖工具
install:
	@echo "📦 安装依赖工具..."
	@if ! command -v stylua >/dev/null 2>&1; then \
		echo "安装 stylua..."; \
		brew install stylua; \
	fi
	@if ! command -v luacheck >/dev/null 2>&1; then \
		echo "安装 luacheck..."; \
		brew install luacheck; \
	fi
	@echo "✅ 工具安装完成"

# 运行测试（如果有）
test:
	@echo "🧪 运行测试..."
	@if [ -d "test_dir" ]; then \
		nvim --headless -c "luafile test_dir/neotest_debug.lua" -c "qa"; \
	else \
		echo "⚠️  没有找到测试目录"; \
	fi
