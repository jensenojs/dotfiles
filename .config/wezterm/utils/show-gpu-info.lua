#!/usr/bin/env -S wezterm --config-file
-- ============================================================================
-- GPU 信息诊断工具
-- ============================================================================
-- 用法: wezterm start --cwd . -- lua utils/show-gpu-info.lua
-- 或者在 wezterm 中执行: require('utils.show-gpu-info')
-- ============================================================================

local wezterm = require('wezterm')

-- 加载 GPU 适配器
local gpu_adapter = require('utils.gpu-adapter')

print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print('                WezTerm GPU 适配器信息')
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print()

-- 显示所有可用的 GPU
local all_gpus = gpu_adapter:get_all()
print('🖥️  可用的 GPU 适配器:')
print()

for i, gpu in ipairs(all_gpus) do
   print(string.format('  [%d] %s', i, gpu.name))
   print(string.format('      Backend:     %s', gpu.backend))
   print(string.format('      Type:        %s', gpu.device_type))
   print(string.format('      Device ID:   %d', gpu.device))
   print(string.format('      Vendor:      %d', gpu.vendor))
   
   if gpu.driver then
      print(string.format('      Driver:      %s', gpu.driver))
   end
   if gpu.driver_info then
      print(string.format('      Driver Info: %s', gpu.driver_info))
   end
   print()
end

-- 显示当前选择的 GPU
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
local best = gpu_adapter:pick_best()
if best then
   print('✅ 当前选择的 GPU (自动选择):')
   print()
   print(string.format('  名称:    %s', best.name))
   print(string.format('  Backend: %s', best.backend))
   print(string.format('  类型:    %s', best.device_type))
   if best.driver then
      print(string.format('  驱动:    %s', best.driver))
   end
   if best.driver_info then
      print(string.format('  驱动版本: %s', best.driver_info))
   end
else
   print('⚠️  未找到合适的 GPU 适配器')
   print('   WezTerm 将使用默认的 OpenGL 后端')
end
print()

-- 显示平台信息
local platform = require('config.platform')
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print('🖥️  平台信息:')
print()
print(string.format('  操作系统: %s', platform.is_mac and 'macOS' or (platform.is_linux and 'Linux' or 'Windows')))
print(string.format('  架构:     %s', wezterm.target_triple))
print()

-- 显示支持的 Backend
local os_name = platform.is_mac and 'mac' or (platform.is_linux and 'linux' or 'windows')
local available_backends = gpu_adapter.AVAILABLE_BACKENDS[os_name]
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print('🎨 支持的 Backend (按优先级):')
print()
for i, backend in ipairs(available_backends) do
   print(string.format('  %d. %s', i, backend))
end
print()

-- 显示选择策略
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print('📊 GPU 选择策略:')
print()
print('  1. GPU 类型优先级:')
print('     DiscreteGpu > IntegratedGpu > Other > Cpu')
print()
print('  2. Backend 优先级 (macOS):')
print('     Metal (唯一选项)')
print()
print('  3. Backend 优先级 (Linux):')
print('     Vulkan > OpenGL')
print()
print('  4. Backend 优先级 (Windows):')
print('     DirectX 12 > Vulkan > OpenGL')
print()

print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
print('💡 提示:')
print()
print('  - 如需手动选择 GPU, 编辑 config/options.lua')
print('  - 取消注释 webgpu_preferred_adapter 的手动配置行')
print('  - 使用 gpu_adapter:pick_manual(backend, device_type)')
print()
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
