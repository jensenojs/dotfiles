-- Background image management utility
-- Simplified version: supports cycling through images and focus mode
-- Default: disabled (use solid color background)

local wezterm = require("wezterm")

local M = {}
M.__index = M

-- Default configuration
local DEFAULT_CONFIG = {
    enabled = false, -- 默认关闭
    images_dir = wezterm.config_dir .. "/backdrops/",
    focus_color = "#282828", -- Gruvbox dark background
    opacity = 0.96,
}

--- Initialize backdrop manager
function M:new(opts)
    opts = opts or {}

    local instance = {
        enabled = opts.enabled or DEFAULT_CONFIG.enabled,
        images_dir = opts.images_dir or DEFAULT_CONFIG.images_dir,
        focus_color = opts.focus_color or DEFAULT_CONFIG.focus_color,
        opacity = opts.opacity or DEFAULT_CONFIG.opacity,
        blur = opts.blur or 0, -- 模糊程度 (0-100), 0 为不模糊
        current_idx = 1,
        images = {},
        focus_on = false,
    }

    setmetatable(instance, M)

    -- Load images if enabled
    if instance.enabled then
        instance:load_images()
    end

    return instance
end

--- Load images from directory
function M:load_images()
    if not self.enabled then
        return
    end

    local pattern = self.images_dir .. "*.{jpg,jpeg,png,gif,bmp,ico,tiff}"
    self.images = wezterm.glob(pattern)

    if #self.images == 0 then
        self.enabled = false
        wezterm.log_info("Backdrops disabled: no images found in " .. self.images_dir)
        return
    end

    wezterm.log_info("Loaded " .. #self.images .. " background images")

    -- Random initial image
    if #self.images > 0 then
        math.randomseed(os.time())
        self.current_idx = math.random(#self.images)
    end
end

--- Get background configuration options
function M:get_background_opts()
    if not self.enabled or #self.images == 0 then
        -- Return empty table, use default background
        return nil
    end

    if self.focus_on then
        -- Focus mode: solid color
        return {
            {
                source = { Color = self.focus_color },
                height = "120%",
                width = "120%",
                vertical_offset = "-10%",
                horizontal_offset = "-10%",
                opacity = 1.0,
            },
        }
    else
        -- Image mode
        local layers = {
            {
                source = { File = self.images[self.current_idx] },
                horizontal_align = "Center",
            },
        }

        -- 如果设置了模糊, 添加模糊层
        if self.blur > 0 then
            table.insert(layers, {
                source = { File = self.images[self.current_idx] },
                horizontal_align = "Center",
                hsb = {
                    brightness = 0.8,
                },
                -- WezTerm 的模糊通过多层叠加和透明度实现
            })
        end

        -- 添加半透明覆盖层
        table.insert(layers, {
            source = { Color = self.focus_color },
            height = "120%",
            width = "120%",
            vertical_offset = "-10%",
            horizontal_offset = "-10%",
            opacity = self.opacity,
        })

        return layers
    end
end

--- Apply background to window
function M:apply_to_window(window)
    if not self.enabled then
        return
    end

    local opts = self:get_background_opts()
    if opts then
        window:set_config_overrides({
            background = opts,
        })
    end
end

--- Cycle to next image
function M:cycle_forward(window)
    if not self.enabled or #self.images == 0 then
        return
    end

    if self.current_idx >= #self.images then
        self.current_idx = 1
    else
        self.current_idx = self.current_idx + 1
    end

    self:apply_to_window(window)
end

--- Cycle to previous image
function M:cycle_back(window)
    if not self.enabled or #self.images == 0 then
        return
    end

    if self.current_idx <= 1 then
        self.current_idx = #self.images
    else
        self.current_idx = self.current_idx - 1
    end

    self:apply_to_window(window)
end

--- Random image
function M:random(window)
    if not self.enabled or #self.images == 0 then
        return
    end

    self.current_idx = math.random(#self.images)
    self:apply_to_window(window)
end

--- Toggle focus mode (solid color vs image)
function M:toggle_focus(window)
    if not self.enabled then
        return
    end

    self.focus_on = not self.focus_on
    self:apply_to_window(window)
end

return M
