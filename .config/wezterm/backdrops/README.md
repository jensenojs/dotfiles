# 背景图片目录

将你的背景图片放在这里。

## 支持的格式

- jpg, jpeg
- png
- gif
- bmp
- ico
- tiff

## 使用方法

1. **添加图片**:

   ```bash
   cp ~/Pictures/*.jpg ~/.config/wezterm/backdrops/
   ```

2. **启用背景**:
   编辑 `config/appearance.lua`, 设置 `enabled = true`

3. **重载配置**:
   - Mac: `Cmd+R`
   - Linux/Win: `Alt+R`

4. **快捷键切换**:
   - `Leader+B` - 下一张
   - `Leader+Shift+B` - 上一张
   - `Leader+Ctrl+B` - 随机

## 配置选项

```lua
local backdrops = require("utils.backdrops"):new({
   enabled = true,                   -- 启用背景
   images_dir = wezterm.config_dir .. "/backdrops/",
   opacity = 0.96,                   -- 背景透明度 (0.0-1.0)
   blur = 0,                         -- 模糊程度 (0-100)
})
```

### opacity(透明度)

- `1.0` - 完全不透明(图片清晰但遮挡终端)
- `0.96` - 轻微透明(推荐, 平衡可见性)
- `0.90` - 较透明(终端内容更清晰)
- `0.80` - 很透明(背景若隐若现)

### blur(模糊)

- `0` - 不模糊(默认)
- `20-40` - 轻微模糊(推荐, 减少干扰)
- `60-80` - 中等模糊
- `100` - 高度模糊

**注意**: 模糊会影响性能, 建议配合高 opacity 使用。

## 示例配置

### 清晰背景

```lua
opacity = 0.90,
blur = 0,
```

### 模糊背景(推荐)

```lua
opacity = 0.96,
blur = 30,
```

### 极简背景

```lua
opacity = 0.98,
blur = 60,
```
