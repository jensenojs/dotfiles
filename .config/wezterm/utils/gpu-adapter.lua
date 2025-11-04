-- ============================================================================
-- GPU Adapter 智能选择器
-- ============================================================================
-- 基于 wgpu 支持的平台和设备类型, 智能选择最佳的 GPU 适配器
-- 参考: https://github.com/KevinSilvester/wezterm-config
-- wgpu 文档: https://github.com/gfx-rs/wgpu#supported-platforms
-- ============================================================================

local wezterm = require('wezterm')

---@alias WeztermGPUBackend 'Vulkan'|'Metal'|'Gl'|'Dx12'
---@alias WeztermGPUDeviceType 'DiscreteGpu'|'IntegratedGpu'|'Cpu'|'Other'

---@class WeztermGPUAdapter
---@field name string
---@field backend WeztermGPUBackend
---@field device number
---@field device_type WeztermGPUDeviceType
---@field driver? string
---@field driver_info? string
---@field vendor number

---@alias AdapterMap { [WeztermGPUBackend]: WeztermGPUAdapter|nil }|nil

---@class GpuAdapters
---@field __backends WeztermGPUBackend[]
---@field __preferred_backend WeztermGPUBackend
---@field DiscreteGpu AdapterMap
---@field IntegratedGpu AdapterMap
---@field Cpu AdapterMap
---@field Other AdapterMap
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters

-- 各平台支持的 Backend
-- 参考: https://github.com/gfx-rs/wgpu#supported-platforms
GpuAdapters.AVAILABLE_BACKENDS = {
   windows = { 'Dx12', 'Vulkan', 'Gl' },
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' }, -- macOS 只支持 Metal
}

-- 枚举系统所有可用的 GPU
---@type WeztermGPUAdapter[]
GpuAdapters.ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---初始化 GPU 适配器映射表
---@return GpuAdapters
---@private
function GpuAdapters:init()
   local platform = require('config.platform')
   local os_name = platform.is_mac and 'mac' or (platform.is_linux and 'linux' or 'windows')
   
   local initial = {
      __backends = self.AVAILABLE_BACKENDS[os_name],
      __preferred_backend = self.AVAILABLE_BACKENDS[os_name][1],
      DiscreteGpu = nil,
      IntegratedGpu = nil,
      Cpu = nil,
      Other = nil,
   }

   -- 遍历枚举的 GPU, 构建按设备类型分类的映射表
   for _, adapter in ipairs(self.ENUMERATED_GPUS) do
      if not initial[adapter.device_type] then
         initial[adapter.device_type] = {}
      end
      initial[adapter.device_type][adapter.backend] = adapter
   end

   local gpu_adapters = setmetatable(initial, self)

   return gpu_adapters
end

---选择最佳的 GPU 适配器
---
---选择策略:
---  1. 优先选择最佳的 GPU 类型: DiscreteGpu > IntegratedGpu > Other > Cpu
---  2. 在同类型 GPU 中选择最佳的 Backend:
---     - macOS: Metal (唯一选择)
---     - Linux: Vulkan > OpenGl
---     - Windows: Dx12 > Vulkan > OpenGl
---
---如果找不到合适的适配器, 返回 nil, 让 WezTerm 自动选择
---
---@return WeztermGPUAdapter|nil
function GpuAdapters:pick_best()
   local adapters_options = self.DiscreteGpu
   local preferred_backend = self.__preferred_backend

   -- 按优先级查找可用的 GPU 类型
   if not adapters_options then
      adapters_options = self.IntegratedGpu
   end

   if not adapters_options then
      -- Other 通常是 OpenGL 在独立 GPU 上的实现
      adapters_options = self.Other
      preferred_backend = 'Gl'
   end

   if not adapters_options then
      adapters_options = self.Cpu
   end

   if not adapters_options then
      wezterm.log_error('No GPU adapters found. Using Default Adapter.')
      return nil
   end

   -- 在选定的 GPU 类型中查找首选的 Backend
   local adapter_choice = adapters_options[preferred_backend]

   if not adapter_choice then
      wezterm.log_error('Preferred backend not available. Using Default Adapter.')
      return nil
   end

   return adapter_choice
end

---手动选择特定的 GPU 适配器
---
---@param backend WeztermGPUBackend Backend 类型 ('Metal', 'Vulkan', 'Dx12', 'Gl')
---@param device_type WeztermGPUDeviceType 设备类型 ('DiscreteGpu', 'IntegratedGpu', 'Cpu', 'Other')
---@return WeztermGPUAdapter|nil
function GpuAdapters:pick_manual(backend, device_type)
   local adapters_options = self[device_type]

   if not adapters_options then
      wezterm.log_error('No GPU adapters found for device type: ' .. device_type)
      return nil
   end

   local adapter_choice = adapters_options[backend]

   if not adapter_choice then
      wezterm.log_error('Backend not available: ' .. backend)
      return nil
   end

   return adapter_choice
end

---获取所有枚举的 GPU 信息(用于调试)
---@return WeztermGPUAdapter[]
function GpuAdapters:get_all()
   return self.ENUMERATED_GPUS
end

---打印 GPU 信息(用于调试)
function GpuAdapters:print_info()
   wezterm.log_info('=== Available GPU Adapters ===')
   for i, gpu in ipairs(self.ENUMERATED_GPUS) do
      wezterm.log_info(string.format('[%d] %s', i, gpu.name))
      wezterm.log_info(string.format('    backend: %s', gpu.backend))
      wezterm.log_info(string.format('    device_type: %s', gpu.device_type))
      wezterm.log_info(string.format('    device: %d', gpu.device))
      if gpu.driver then
         wezterm.log_info(string.format('    driver: %s', gpu.driver))
      end
      if gpu.driver_info then
         wezterm.log_info(string.format('    driver_info: %s', gpu.driver_info))
      end
   end
   
   local best = self:pick_best()
   if best then
      wezterm.log_info('=== Selected GPU (Best) ===')
      wezterm.log_info(string.format('Name: %s', best.name))
      wezterm.log_info(string.format('Backend: %s', best.backend))
      wezterm.log_info(string.format('Type: %s', best.device_type))
   else
      wezterm.log_info('=== Using Default Adapter ===')
   end
end

return GpuAdapters:init()
