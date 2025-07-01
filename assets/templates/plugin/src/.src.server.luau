--!strict
-- MainScript.server.luau
-- Main plugin entry point
-- This is a Fluxo plugin template file

-- selene: allow(undefined_variable, incorrect_standard_library_use)

local toolbar = plugin:CreateToolbar("$name")
local button = toolbar:CreateButton(
    "$name", 
    "Opens the plugin UI", 
    "rbxassetid://0"  -- Replace with actual icon ID
)

local UI = require(script.Parent.ToolbarUI)

button.Click:Connect(function()
    UI.toggle()
end)
