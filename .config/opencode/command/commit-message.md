---
description: 生成规范的 Git 提交信息
---

# 生成 Git 提交信息

基于当前的代码变更生成规范的提交信息，遵循约定式提交规范:

## 格式要求

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## 类型 (type)

- **feat**: 新功能
- **fix**: 修复 bug
- **docs**: 文档更新
- **style**: 代码格式调整 (不影响功能)
- **refactor**: 重构 (既不是新功能也不是修复)
- **perf**: 性能优化
- **test**: 测试相关
- **chore**: 构建过程或辅助工具的变动

## 任务

1. 分析当前的 git diff
2. 识别变更的主要类型和范围
3. 生成简洁明确的描述 (50字符以内)
4. 如有必要，添加详细说明
5. 提供中英文两个版本

请先运行 `git diff --staged` 查看暂存的变更。
