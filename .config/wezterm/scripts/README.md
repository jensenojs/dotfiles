# WezTerm 系统指标采集脚本

## 概述

这些脚本用于采集系统指标(CPU、内存、磁盘、网络),供 WezTerm 状态栏显示。

## 脚本文件

- `metrics-macos.sh` - macOS 系统指标采集
- `metrics-linux.sh` - Linux 系统指标采集

## 输出格式

```
CPU=15 MEM=65 DISK=58 RX=192558727132 TX=66589572526
```

- **CPU**: CPU 使用率百分比(0-100)
- **MEM**: 内存使用率百分比(0-100)
- **DISK**: 当前目录所在磁盘使用率百分比(0-100)
- **RX**: 累计接收字节数
- **TX**: 累计发送字节数

## 优化说明

### macOS 脚本

- **CPU 采集**: 优先使用 `top -l 1`,失败时降级到 `ps`
- **内存采集**: 优先使用 `memory_pressure`,失败时降级到 `vm_stat`
- **网络统计**: 使用 `netstat -ib`,排除 loopback 和 utun 接口

### Linux 脚本

- **CPU 采集**:
    - ✅ **优化**: 直接读取 `/proc/stat`,避免 `top` 命令开销
    - 降级方案: 使用 `top -bn1`
- **内存采集**: 读取 `/proc/meminfo`,计算 `(Total - Available) / Total`
- **网络统计**: 读取 `/proc/net/dev`,排除 loopback 接口

## 性能对比

### CPU 采集方法对比(Linux)

| 方法 | 开销 | 延迟 | 说明 |
|------|------|------|------|
| `top -bn1` | 高 | ~100ms | 需要 fork 进程,解析输出 |
| `/proc/stat` | 极低 | <1ms | 直接读取内核数据 |

**优化效果**:

- 减少 CPU 采集开销 **99%**
- 降低高负载时的延迟影响

## 独立运行测试

```bash
# macOS
~/.config/wezterm/scripts/metrics-macos.sh

# Linux
~/.config/wezterm/scripts/metrics-linux.sh
```

## 降级机制

如果脚本文件不存在或无法执行,WezTerm 会自动降级到内联脚本(嵌入在 `events.lua` 中)。

## 自定义

如需修改采集逻辑,直接编辑对应的脚本文件即可,无需重启 WezTerm。

## 故障排查

### 脚本不执行

1. 检查文件权限:

   ```bash
   ls -l ~/.config/wezterm/scripts/*.sh
   ```

   应该显示 `-rwxr-xr-x`(可执行)

2. 手动执行测试:

   ```bash
   ~/.config/wezterm/scripts/metrics-macos.sh
   ```

3. 查看 WezTerm 日志:

   ```bash
   tail -f ~/.local/share/wezterm/wezterm-gui-log-*.txt | grep metrics
   ```

### 输出格式错误

确保脚本输出严格遵循 `KEY=VALUE` 格式,多个指标用空格分隔。

## 扩展

可以添加更多指标,只需:

1. 在脚本中添加采集逻辑
2. 在 `events.lua` 的 `parse_metrics()` 中添加解析
3. 在 `update_metrics_cache()` 中添加缓存更新
4. 在 `update-status` 事件中添加显示逻辑
