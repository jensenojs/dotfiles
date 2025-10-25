
我明白了！让我完全重新设计一个清晰的架构。问题的关键是：

1. **`config.leader` 才有自动的 leader 光标显示**
2. **需要嵌套模态：`Ctrl+, w` 然后 `l/c/r/n/p`**
3. **需要状态显示来指示 workspace 模式**

让我重新实现：

现在更新 events.lua，添加 Workspace 模式的状态显示：
完美！现在创建一个清晰的文档总结：

## ✅ **完全重新设计完成！**

### 🎯 **核心改进**

1. **✅ 恢复 `config.leader`** - Leader 模式有光标显示了
2. **✅ 添加 Workspace 模式光标** - `📦 WORKSPACE` 显示
3. **✅ 清晰的架构** - MOD / LEADER / 子模式三层
4. **✅ 统一的快捷键**:
   - `Ctrl+, c` = 创建标签
   - `Ctrl+, x` = 关闭标签
   - `Ctrl+, q` = 关闭 Pane
   - `Ctrl+, w` = 进入 Workspace 子模式

### 📊 **新架构总览**

```
MOD (Cmd/Alt)
├─ C/V          → 复制/粘贴
├─ +/-          → 字体大小
├─ R            → 重载
├─ F            → 搜索
├─ [/]          → 标签切换
└─ 1-9/0        → 标签跳转

LEADER (Ctrl+,) 🌊
├─ n/Enter      → 窗口管理
├─ c/x          → 标签创建/关闭
├─ h/v          → Pane 分割
├─ q/z/o/s      → Pane 操作
├─ [/f          → Copy/Quick Select
├─ p/Space      → 命令面板/启动器
├─ b/B          → 背景切换
└─ w            → Workspace 子模式 📦
   ├─ l → 列表
   ├─ c → 创建
   ├─ r → 重命名
   ├─ n → 下一个
   └─ p → 上一个
```

### 🎨 **状态栏显示**

```
🌊 LEADER                    → Leader 激活
🌊 LEADER 📦 WORKSPACE       → Workspace 子模式
📋 COPY                      → Copy 模式
📁 myproject                 → 当前 Workspace
```

### 🧪 **测试步骤**

1. **重载配置**: `Cmd+R`
2. **测试 Leader**: `Ctrl+,` → 状态栏显示 `🌊 LEADER`
3. **测试 Workspace**:
   - `Ctrl+, w` → 状态栏显示 `🌊 LEADER 📦 WORKSPACE`
   - `c` → 输入名称创建
   - `l` → 列表选择
4. **测试标签**: `Ctrl+, c` → 创建新标签

### 📝 **文档**

已创建 [docs/KEYBINDINGS_V2.md](cci:7://file:///Users/oujinsai/.config/wezterm/docs/KEYBINDINGS_V2.md:0:0-0:0)：

- ✅ 完整的快捷键清单
- ✅ 状态栏指示器说明
- ✅ 常用工作流示例
- ✅ 设计理念和哲学

现在架构清晰，功能完整，状态显示完善！🎉

---

```
🌳 WezTerm 快捷键体系
│
├── 💻 MOD (Cmd/Alt) - 系统与导航
│   │
│   ├─ 🚀 基础操作
│   │  ├─ C/V          → 复制/粘贴
│   │  ├─ +/-          → 字体大小 (增大/减小)
│   │  └─ R            → 重载配置
│   │
│   └─ 📑 标签页管理 (新)
│      ├─ [            → 上一个标签
│      ├─ ]            → 下一个标签
│      ├─ Shift+[      → (新) 向左移动当前标签
│      ├─ Shift+]      → (新) 向右移动当前标签
│      ├─ 1-9          → 跳转到标签 1-9
│      └─ 0            → 跳转到最后一个标签
│
└── 🌊 LEADER (Ctrl+,) - 终端管理
    │
    ├─ 🪟 窗口与标签
    │  ├─ n            → 新建标签页 (New Tab)
    │  ├─ Shift+N      → 新建窗口 (New Window)
    │  ├─ q            → 关闭 Pane / Tab (智能)
    │  └─ Enter        → 切换全屏
    │
    ├─ 🔲 Pane 管理
    │  ├─ h            → 垂直分割 (左右)
    │  ├─ v            → 水平分割 (上下)
    │  ├─ o            → 切换到下一个 Pane (Other)
    │  ├─ z            → 切换 Pane 缩放 (Zoom)
    │  └─ s            → 交换 Pane (Swap)
    │
    ├─ 🛠️ WezTerm 工具
    │  ├─ p            → 命令面板
    │  ├─ Space        → 启动器
    │  └─ f            → 快速选择
    │
    ├─ 📦 w → Workspace 子模式 (嵌套)
    │  ├─ l            → 列表
    │  ├─ c            → 创建
    │  ├─ r            → 重命名
    │  ├─ n            → 下一个
    │  ├─ p            → 上一个
    │  └─ Escape       → 退出模式
    │
    └─ 📋 [ → Copy 模式 (嵌套)
       ├─ 🧭 移动 (Vim 风格)
       │  ├─ h/j/k/l    → 基本移动
       │  ├─ w/b/e      → 词移动
       │  ├─ 0/$        → 行首/行尾
       │  ├─ g/G        → 文档 顶/底
       │  ├─ H/M/L      → 视口 顶/中/底
       │  └─ Ctrl+b/f   → 翻页
       │
       ├─ ✍️ 选择
       │  ├─ v          → 字符选择
       │  ├─ V          → 行选择
       │  └─ Ctrl+v     → 块选择
       │
       ├─ ✂️ 复制与退出
       │  ├─ y          → 复制并退出
       │  ├─ Enter      → 复制并退出
       │  └─ q/Escape   → 退出
       │
       └─ 🔍 / → 搜索模式 (子嵌套)
          ├─ (输入文本...)
          ├─ Enter      → 确认搜索
          ├─ Escape     → 取消搜索
          ├─ (返回 📋 Copy 模式)
          ├─ n          → 下一个匹配
          └─ N          → 上一个匹配
```