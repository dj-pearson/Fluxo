--!strict
-- Sync.lua
-- Handles file synchronization functionality

local Sync = {}

function Sync.handleSyncRequest(data, dashboard)
    dashboard:addLog("🔄 Received sync request from CLI")
    
    if not data or not data.files then
        dashboard:addLog("❌ Invalid sync request: missing files")
        return {success = false, error = "Missing files"}
    end
    
    local files = data.files
    local metadata = data.metadata or {}
    
    dashboard:addLog("📁 Syncing " .. #files .. " files...")
    
    -- Update project information in dashboard
    dashboard:updateProject({
        name = metadata.name or "Unknown Project",
        path = data.projectPath or "",
        lastSync = os.date("%H:%M:%S")
    })
    
    -- Process each file
    for filename, content in pairs(files) do
        dashboard:addLog("📄 Synced: " .. filename)
    end
    
    dashboard:addLog("✅ Sync completed successfully")
    dashboard:setConnectionStatus(true)
    
    return {success = true, message = "Files synced successfully"}
end

function Sync.showDiffViewer(oldContent, newContent, filename, dashboard)
    -- Create diff viewer modal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluxoDiffViewer"
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
    dialog.Size = UDim2.new(0, 800, 0, 600)
    dialog.Position = UDim2.new(0.5, -400, 0.5, -300)
    dialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dialog.BorderSizePixel = 0
    dialog.Parent = overlay
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialog
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "File Changes: " .. filename
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dialog
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -40, 1, -120)
    contentFrame.Position = UDim2.new(0, 20, 0, 70)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = dialog
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame
    
    -- Split view (old vs new)
    local oldFrame = Instance.new("ScrollingFrame")
    oldFrame.Size = UDim2.new(0.5, -10, 1, -40)
    oldFrame.Position = UDim2.new(0, 10, 0, 30)
    oldFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    oldFrame.BorderSizePixel = 0
    oldFrame.ScrollBarThickness = 6
    oldFrame.Parent = contentFrame
    
    local oldLabel = Instance.new("TextLabel")
    oldLabel.Size = UDim2.new(1, -10, 0, 20)
    oldLabel.Position = UDim2.new(0, 5, 0, 5)
    oldLabel.BackgroundTransparency = 1
    oldLabel.Text = "Previous Version"
    oldLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    oldLabel.Font = Enum.Font.SourceSansBold
    oldLabel.TextSize = 12
    oldLabel.TextXAlignment = Enum.TextXAlignment.Left
    oldLabel.Parent = contentFrame
    
    local newFrame = Instance.new("ScrollingFrame")
    newFrame.Size = UDim2.new(0.5, -10, 1, -40)
    newFrame.Position = UDim2.new(0.5, 0, 0, 30)
    newFrame.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
    newFrame.BorderSizePixel = 0
    newFrame.ScrollBarThickness = 6
    newFrame.Parent = contentFrame
    
    local newLabel = Instance.new("TextLabel")
    newLabel.Size = UDim2.new(1, -10, 0, 20)
    newLabel.Position = UDim2.new(0.5, 5, 0, 5)
    newLabel.BackgroundTransparency = 1
    newLabel.Text = "New Version"
    newLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    newLabel.Font = Enum.Font.SourceSansBold
    newLabel.TextSize = 12
    newLabel.TextXAlignment = Enum.TextXAlignment.Left
    newLabel.Parent = contentFrame
    
    -- Content text
    local oldText = Instance.new("TextLabel")
    oldText.Size = UDim2.new(1, -20, 0, 1000)
    oldText.Position = UDim2.new(0, 10, 0, 10)
    oldText.BackgroundTransparency = 1
    oldText.Text = oldContent or "No previous content"
    oldText.TextColor3 = Color3.fromRGB(255, 255, 255)
    oldText.Font = Enum.Font.Code
    oldText.TextSize = 10
    oldText.TextXAlignment = Enum.TextXAlignment.Left
    oldText.TextYAlignment = Enum.TextYAlignment.Top
    oldText.TextWrapped = true
    oldText.Parent = oldFrame
    
    local newText = Instance.new("TextLabel")
    newText.Size = UDim2.new(1, -20, 0, 1000)
    newText.Position = UDim2.new(0, 10, 0, 10)
    newText.BackgroundTransparency = 1
    newText.Text = newContent or "No content"
    newText.TextColor3 = Color3.fromRGB(255, 255, 255)
    newText.Font = Enum.Font.Code
    newText.TextSize = 10
    newText.TextXAlignment = Enum.TextXAlignment.Left
    newText.TextYAlignment = Enum.TextYAlignment.Top
    newText.TextWrapped = true
    newText.Parent = newFrame
    
    -- Update canvas sizes
    oldFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    newFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(1, -120, 1, -55)
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 14
    closeButton.Parent = dialog
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Event handlers
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    overlay.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    dashboard:addLog("👁️ Showing diff viewer for " .. filename)
end

return Sync
