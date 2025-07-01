--!strict
-- Publish.lua
-- Handles plugin publishing functionality

local Publish = {}

-- Services
local StudioService = game:GetService("StudioService")

function Publish.handlePublishRequest(data, dashboard)
    dashboard:addLog("🚀 Received publish request from CLI")
    
    -- Validate the request data
    if not data or not data.metadata then
        dashboard:addLog("❌ Invalid publish request: missing metadata")
        return {success = false, error = "Missing metadata"}
    end
    
    local metadata = data.metadata
    dashboard:addLog("📋 Plugin: " .. (metadata.name or "Unknown"))
    dashboard:addLog("🔢 Version: " .. (metadata.version or "Unknown"))
    
    -- Show publish confirmation dialog
    Publish.showPublishDialog(metadata, data.notes, dashboard)
    
    return {success = true, message = "Publish dialog shown"}
end

function Publish.showPublishDialog(metadata, notes, dashboard)
    -- Create publish confirmation modal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluxoPublishDialog"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Background overlay
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    -- Dialog frame
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 500, 0, 400)
    dialog.Position = UDim2.new(0.5, -250, 0.5, -200)
    dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dialog.BorderSizePixel = 0
    dialog.Parent = overlay
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialog
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 50)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Publish Plugin Confirmation"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dialog
    
    -- Plugin info section
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -40, 0, 150)
    infoFrame.Position = UDim2.new(0, 20, 0, 80)
    infoFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = dialog
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame
    
    -- Plugin details
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Plugin: " .. (metadata.name or "Unknown")
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = infoFrame
    
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, -20, 0, 25)
    versionLabel.Position = UDim2.new(0, 10, 0, 35)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "Version: " .. (metadata.version or "Unknown")
    versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    versionLabel.Font = Enum.Font.SourceSans
    versionLabel.TextSize = 14
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = infoFrame
    
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, -20, 0, 50)
    descriptionLabel.Position = UDim2.new(0, 10, 0, 60)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "Description: " .. (metadata.description or "No description")
    descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 12
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    descriptionLabel.TextWrapped = true
    descriptionLabel.Parent = infoFrame
    
    local notesLabel = Instance.new("TextLabel")
    notesLabel.Size = UDim2.new(1, -20, 0, 25)
    notesLabel.Position = UDim2.new(0, 10, 0, 115)
    notesLabel.BackgroundTransparency = 1
    notesLabel.Text = "Notes: " .. (notes or "No release notes")
    notesLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    notesLabel.Font = Enum.Font.SourceSans
    notesLabel.TextSize = 12
    notesLabel.TextXAlignment = Enum.TextXAlignment.Left
    notesLabel.Parent = infoFrame
    
    -- Warning text
    local warning = Instance.new("TextLabel")
    warning.Size = UDim2.new(1, -40, 0, 40)
    warning.Position = UDim2.new(0, 20, 0, 250)
    warning.BackgroundTransparency = 1
    warning.Text = "⚠️ This will publish your plugin to the Roblox Creator Marketplace.\nMake sure you have tested it thoroughly."
    warning.TextColor3 = Color3.fromRGB(255, 200, 100)
    warning.Font = Enum.Font.SourceSans
    warning.TextSize = 12
    warning.TextXAlignment = Enum.TextXAlignment.Center
    warning.TextWrapped = true
    warning.Parent = dialog
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -40, 0, 50)
    buttonFrame.Position = UDim2.new(0, 20, 1, -70)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = dialog
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 100, 0, 35)
    cancelButton.Position = UDim2.new(1, -220, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Font = Enum.Font.SourceSans
    cancelButton.TextSize = 14
    cancelButton.Parent = buttonFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelButton
    
    -- Publish button
    local publishButton = Instance.new("TextButton")
    publishButton.Size = UDim2.new(0, 100, 0, 35)
    publishButton.Position = UDim2.new(1, -110, 0, 0)
    publishButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    publishButton.BorderSizePixel = 0
    publishButton.Text = "Publish"
    publishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    publishButton.Font = Enum.Font.SourceSansBold
    publishButton.TextSize = 14
    publishButton.Parent = buttonFrame
    
    local publishCorner = Instance.new("UICorner")
    publishCorner.CornerRadius = UDim.new(0, 6)
    publishCorner.Parent = publishButton
    
    -- Event handlers
    cancelButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        dashboard:addLog("❌ Publish cancelled by user")
    end)
    
    publishButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        Publish.executePublish(metadata, notes, dashboard)
    end)
    
    -- Close on overlay click
    overlay.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        dashboard:addLog("❌ Publish cancelled by user")
    end)
end

function Publish.executePublish(metadata, notes, dashboard)
    dashboard:addLog("🚀 Starting plugin publish process...")
    
    -- Get plugin context
    local pluginObject = script:FindFirstAncestorOfClass("Plugin")
    
    if not pluginObject then
        dashboard:addLog("❌ No plugin context found - cannot publish")
        return
    end
    
    dashboard:addLog("📤 Preparing plugin for publication...")
    
    -- Validate metadata
    if not metadata.name or metadata.name == "" then
        dashboard:addLog("❌ Plugin name is required")
        return
    end
    
    if not metadata.description or metadata.description == "" then
        dashboard:addLog("❌ Plugin description is required")
        return
    end
    
    -- Prepare publish configuration
    local description = metadata.description .. "\n\nVersion: " .. (metadata.version or "1.0.0")
    
    if notes and notes ~= "" then
        description = description .. "\n\nRelease Notes: " .. notes
    end
    
    local publishConfig = {
        Name = metadata.name,
        Description = description,
        Tags = metadata.tags or {}
    }
    
    dashboard:addLog("� Publishing: " .. publishConfig.Name)
    dashboard:addLog("📝 Version: " .. (metadata.version or "1.0.0"))
    
    -- Attempt to publish using Plugin:PublishAsPluginAsync()
    local success, result = pcall(function()
        -- This is the official Roblox method for plugin publishing
        return pluginObject:PublishAsPluginAsync(publishConfig)
    end)
    
    if success then
        dashboard:addLog("✅ Plugin published successfully!")
        dashboard:addLog("🔗 Asset ID: " .. tostring(result))
        dashboard:addLog("🎉 '" .. metadata.name .. "' is now live on the Creator Marketplace!")
        
        -- Update project status
        dashboard:updateProject({
            name = metadata.name,
            lastPublish = os.date("%Y-%m-%d %H:%M:%S"),
            lastVersion = metadata.version or "1.0.0",
            assetId = tostring(result)
        })
        
        -- Log publish summary
        dashboard:addLog("📊 Publish Summary:")
        dashboard:addLog("  • Name: " .. metadata.name)
        dashboard:addLog("  • Version: " .. (metadata.version or "1.0.0"))
        dashboard:addLog("  • Author: " .. (metadata.author or "Unknown"))
        dashboard:addLog("  • Asset ID: " .. tostring(result))
        
    else
        dashboard:addLog("❌ Publish failed: " .. tostring(result))
        
        -- Provide helpful error messages
        local errorStr = tostring(result):lower()
        
        if errorStr:find("permission") or errorStr:find("unauthorized") then
            dashboard:addLog("💡 Tip: Make sure you have plugin publishing permissions")
            dashboard:addLog("   You may need to verify your account or enable 2-step verification")
            
        elseif errorStr:find("moderation") or errorStr:find("content") then
            dashboard:addLog("⚠️ Content may have triggered moderation filters")
            dashboard:addLog("💡 Tip: Review your plugin name, description, and code for policy violations")
            
        elseif errorStr:find("rate") or errorStr:find("limit") then
            dashboard:addLog("⏰ Rate limit reached - please wait before publishing again")
            
        elseif errorStr:find("duplicate") or errorStr:find("exists") then
            dashboard:addLog("📋 Plugin with this name may already exist")
            dashboard:addLog("💡 Tip: Try updating the existing plugin or use a different name")
            
        else
            dashboard:addLog("💡 Tip: Check your internet connection and try again")
            dashboard:addLog("   If the problem persists, contact Roblox support")
        end
    end
end

return Publish
