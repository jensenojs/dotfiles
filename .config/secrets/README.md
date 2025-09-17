# Secrets 管理(yadm + GPG)

本目录用于集中存放需要加密同步的环境密钥文件。当前“单一入口”文件：`~/.config/secrets/llm`。

zsh 加载点(已配置于 `~/.config/zsh/zshrc_ext` 开头)：

```zsh
[ -s "${XDG_CONFIG_HOME:-$HOME/.config}/secrets/llm" ] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/secrets/llm"
```

---

## 目录结构

- `llm`：明文密钥文件(被 yadm 加密归档管理)
- `README.md`：使用说明(本文件)

yadm 加密清单：`~/.config/yadm/encrypt`(明文)，包含：

```
.config/secrets/llm
```

注意：`~/.config/yadm/encrypt` 只是“要加密的文件列表”，不要把密钥写进这个清单。

---

## 快速开始(首次配置)

1) 准备 GPG(若已配置可跳过生成)

```zsh
gpg --list-secret-keys --keyid-format=long
# 如无密钥：
# gpg --full-generate-key
```

2) 告诉 yadm 使用哪个接收者(把 <KEY_ID> 替换为你的 GPG Key ID)

```zsh
yadm config yadm.gpg-recipient <KEY_ID>
```

3) 将密钥写入 `~/.config/secrets/llm`

```zsh
# 示例：
export OPENAI_API_KEY="..."
export GH_TOKEN="..."
```

4) 生成加密归档并提交

```zsh
yadm encrypt
yadm add ~/.local/share/yadm/archive ~/.config/yadm/encrypt
yadm commit -m "chore(secrets): encrypt .config/secrets/llm"
yadm push
```

---

## 从旧路径迁移(原：~/.config/zsh/.secrets)

1) 将旧内容复制到新入口：

```zsh
# 建议用编辑器拷贝粘贴内容到：
# ~/.config/secrets/llm
```

2) 如果旧文件曾被 yadm 跟踪，先从索引移除(保留本地明文)：

```zsh
yadm ls-files --error-unmatch ~/.config/zsh/.secrets && \
  yadm rm --cached --force ~/.config/zsh/.secrets || true
```

3) 重新生成加密归档并提交：

```zsh
yadm encrypt
yadm add ~/.local/share/yadm/archive ~/.config/yadm/encrypt
yadm commit -m "chore(secrets): migrate to .config/secrets/llm"
yadm push
```

---

## 新机器使用

```zsh
yadm clone <repo-url> --bootstrap
# 确保本机有解密用的 GPG 私钥

yadm decrypt
# 如需修复权限
chmod 600 ~/.config/secrets/llm
```

可选：添加 `~/.config/yadm/bootstrap` 自动尝试执行 `yadm decrypt`。

---

## 更新密钥的正确姿势

1) 编辑 `~/.config/secrets/llm`
2) 重新加密与提交

```zsh
yadm encrypt
yadm add ~/.local/share/yadm/archive
yadm commit -m "chore(secrets): update"
yadm push
```

---

## 安全建议

- 不要把密钥写进 `~/.config/yadm/encrypt`(那只是清单)。
- 建议将明文路径加入仓库级 `.gitignore`，避免误 `yadm add`：

  ```
  .config/secrets/llm
  ```

- 给 `llm` 设置严格权限：`chmod 600 ~/.config/secrets/llm`
- 验证不泄露：测试存在性而非打印值，例如：

  ```zsh
  [ -n "$OPENAI_API_KEY" ] && echo OK: OPENAI_API_KEY loaded
  ```

---

## 故障排查

- `yadm encrypt`/`decrypt` 只处理清单内文件；新增敏感文件记得写入 `~/.config/yadm/encrypt`。
- 如 `brew` 或 `go` PATH 异常，参考 `~/.config/zsh/.zshllm` 与 `~/.config/zsh/zshrc_ext` 的幂等配置。
- GPG 解密失败：确认本机已经导入对应私钥，并可 `gpg --list-secret-keys` 查看。
