--!strict
-- ToolbarUI.lua  
-- Handles the plugin UI
-- This is a Fluxo plugin template file
-- Template file - Roblox globals will be available when generated

-- Disable selene warnings for template file
-- selene: allow(undefined_variable, incorrect_standard_library_use)

local ToolbarUI = {}

-- selene: allow(undefined_variable)
local widget = plugin:CreateDockWidgetPluginGui(
    "$name-widget",
    -- selene: allow(undefined_variable)
    DockWidgetPluginGuiInfo.new(
        -- selene: allow(undefined_variable)
        Enum.InitialDockState.Float,
        false,
        false,
        300,
        300,
        200,
        200
    )
)

widget.Title = "$name"

local function createUI()
    -- selene: allow(undefined_variable)
    local frame = Instance.new("Frame")
    -- selene: allow(undefined_variable)
    frame.Size = UDim2.new(1, 0, 1, 0)
    -- selene: allow(undefined_variable)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    -- selene: allow(undefined_variable)
    local label = Instance.new("TextLabel")
    label.Text = "Hello from $name plugin!"
    -- selene: allow(undefined_variable)
    label.Size = UDim2.new(1, 0, 0, 30)
    -- selene: allow(undefined_variable)
    label.Position = UDim2.new(0, 0, 0.5, -15)
    label.BackgroundTransparency = 1
    -- selene: allow(undefined_variable)
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = frame
    
    frame.Parent = widget
end

createUI()

function ToolbarUI.toggle()
    widget.Enabled = not widget.Enabled
end

return ToolbarUI
