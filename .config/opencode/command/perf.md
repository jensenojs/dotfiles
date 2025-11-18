---
description: 性能分析和基准测试
---

# 性能分析工具

协助进行系统性能分析和基准测试:

## 分析任务

1. **检查可用工具**
   - 检测 perf、ftrace、bpftrace、systemtap 等工具
   - 确认内核配置和权限

2. **性能分析建议**
   - 根据问题类型推荐合适的分析方法
   - CPU 性能: perf record/report, flame graphs
   - 内存分析: valgrind, AddressSanitizer
   - I/O 分析: iotop, blktrace
   - 网络分析: tcpdump, wireshark

3. **结果解读**
   - 解释 perf 输出和热点函数
   - 分析调用栈和性能瓶颈
   - 提供优化建议和下一步行动

4. **基准测试**
   - 设计合适的基准测试
   - 对比优化前后的性能数据
   - 统计分析和结果验证

请描述你要分析的性能问题或提供现有的性能数据。
