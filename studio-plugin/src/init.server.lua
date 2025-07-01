--!strict
-- Fluxo Studio Plugin Entry Point
-- This plugin provides a bridge between Roblox Studio and the Fluxo CLI tool

-- Services
local ToolbarService = game:GetService("ToolbarService")

-- Create toolbar
local toolbar = ToolbarService:CreateToolbar("Fluxo")

-- Create main button
local mainButton = toolbar:CreateButton(
    "Fluxo Dashboard",
    "Open Fluxo Dashboard",
    "rbxasset://textures/StudioToolbox/AssetManager/light_theme/default_icon.png"
)

-- Load modules
local Dashboard = require(script.ui.Dashboard)
local Server = require(script.core.Server)
local Publish = require(script.core.Publish)
local Sync = require(script.core.Sync)
local Validation = require(script.core.Validation)
local MetadataEditor = require(script.core.MetadataEditor)
local HttpClient = require(script.util.HttpClient)
local Logger = require(script.util.Logger)

-- Initialize logger
Logger.setLogLevel(Logger.LogLevel.INFO)
Logger.info("Starting Fluxo Studio Plugin...", "Plugin")

-- Initialize dashboard
local dashboard = Dashboard.new()

-- Initialize server communication
local server = Server.new(dashboard)

-- Add additional functionality to dashboard
dashboard:setSync(Sync)
dashboard:setValidation(Validation)
dashboard:setMetadataEditor(MetadataEditor)
dashboard:setHttpClient(HttpClient)
dashboard:setLogger(Logger)

-- Button click handler
mainButton.Click:Connect(function()
    dashboard:toggle()
    Logger.info("Dashboard toggled", "UI")
end)

-- Start server listener
server:start()

-- Test CLI connection
HttpClient.testConnection(
    function(data)
        Logger.info("CLI connection established", "Network")
        dashboard:setConnectionStatus(true)
    end,
    function(error)
        Logger.warn("CLI not connected: " .. error, "Network")
        dashboard:setConnectionStatus(false)
    end
)

Logger.info("Fluxo Studio Plugin loaded successfully!", "Plugin")
print("🚀 Fluxo Studio Plugin loaded successfully!")
