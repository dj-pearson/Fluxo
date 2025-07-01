--!strict
-- Dashboard.lua
-- Main UI for the Fluxo Studio companion plugin

local Dashboard = {}
Dashboard.__index = Dashboard

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function Dashboard.new(plugin)
    local self = setmetatable({}, Dashboard)
    
    self.plugin = plugin
    self.isVisible = false
    
    -- Create the main widget
    self.widget = plugin:CreateDockWidgetPluginGui(
        "FluxoDashboard",
        DockWidgetPluginGuiInfo.new(
            Enum.InitialDockState.Float,
            false,  -- Initially enabled
            false,  -- Override previous enabled state
            400,    -- Floating window width
            600,    -- Floating window height
            300,    -- Minimum width
            400     -- Minimum height
        )
    )
    
    self.widget.Title = "Fluxo Plugin Manager"
    self.widget.Name = "FluxoDashboard"
    
    self:createUI()
    
    return self
end

function Dashboard:createUI()
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.widget
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Fluxo Plugin Manager"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Status indicator
    self.statusIndicator = Instance.new("Frame")
    self.statusIndicator.Size = UDim2.new(0, 12, 0, 12)
    self.statusIndicator.Position = UDim2.new(1, -30, 0.5, -6)
    self.statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Gray by default
    self.statusIndicator.BorderSizePixel = 0
    self.statusIndicator.Parent = header
    
    -- Make status indicator round
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.statusIndicator
    
    -- Content area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, -60)
    contentFrame.Position = UDim2.new(0, 0, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    contentFrame.Parent = mainFrame
    
    -- Current project section
    self:createProjectSection(contentFrame)
    
    -- Actions section
    self:createActionsSection(contentFrame)
    
    -- Log section
    self:createLogSection(contentFrame)
    
    self.mainFrame = mainFrame
    self.contentFrame = contentFrame
end

function Dashboard:createProjectSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 120)
    section.Position = UDim2.new(0, 10, 0, 10)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    -- Section title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Current Project"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    -- Project info
    self.projectNameLabel = Instance.new("TextLabel")
    self.projectNameLabel.Size = UDim2.new(1, -20, 0, 20)
    self.projectNameLabel.Position = UDim2.new(0, 10, 0, 40)
    self.projectNameLabel.BackgroundTransparency = 1
    self.projectNameLabel.Text = "No project loaded"
    self.projectNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.projectNameLabel.Font = Enum.Font.SourceSans
    self.projectNameLabel.TextSize = 14
    self.projectNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.projectNameLabel.Parent = section
    
    self.projectPathLabel = Instance.new("TextLabel")
    self.projectPathLabel.Size = UDim2.new(1, -20, 0, 20)
    self.projectPathLabel.Position = UDim2.new(0, 10, 0, 65)
    self.projectPathLabel.BackgroundTransparency = 1
    self.projectPathLabel.Text = ""
    self.projectPathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.projectPathLabel.Font = Enum.Font.SourceSans
    self.projectPathLabel.TextSize = 12
    self.projectPathLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.projectPathLabel.Parent = section
    
    self.syncStatusLabel = Instance.new("TextLabel")
    self.syncStatusLabel.Size = UDim2.new(1, -20, 0, 20)
    self.syncStatusLabel.Position = UDim2.new(0, 10, 0, 90)
    self.syncStatusLabel.BackgroundTransparency = 1
    self.syncStatusLabel.Text = "Not synced"
    self.syncStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.syncStatusLabel.Font = Enum.Font.SourceSans
    self.syncStatusLabel.TextSize = 12
    self.syncStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.syncStatusLabel.Parent = section
end

function Dashboard:createActionsSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 160)
    section.Position = UDim2.new(0, 10, 0, 140)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    -- Section title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Actions"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    -- Validate button
    self.validateButton = self:createActionButton("Validate Plugin", UDim2.new(0, 10, 0, 50), section)
    self.validateButton.MouseButton1Click:Connect(function()
        self:onValidateClicked()
    end)
    
    -- Sync button
    self.syncButton = self:createActionButton("Sync Files", UDim2.new(0.5, 5, 0, 50), section)
    self.syncButton.MouseButton1Click:Connect(function()
        self:onSyncClicked()
    end)
    
    -- Publish button
    self.publishButton = self:createActionButton("Publish Plugin", UDim2.new(0, 10, 0, 90), section)
    self.publishButton.MouseButton1Click:Connect(function()
        self:onPublishClicked()
    end)
    
    -- Edit Metadata button
    self.metadataButton = self:createActionButton("Edit Metadata", UDim2.new(0.5, 5, 0, 90), section)
    self.metadataButton.MouseButton1Click:Connect(function()
        self:onEditMetadataClicked()
    end)
end

function Dashboard:createActionButton(text, position, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, -15, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 140, 220)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play()
    end)
    
    return button
end

function Dashboard:createLogSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 200)
    section.Position = UDim2.new(0, 10, 0, 310)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Update parent's canvas size
    parent.CanvasSize = UDim2.new(0, 0, 0, 530)
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    -- Section title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Activity Log"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    -- Log text area
    self.logTextLabel = Instance.new("TextLabel")
    self.logTextLabel.Size = UDim2.new(1, -20, 1, -50)
    self.logTextLabel.Position = UDim2.new(0, 10, 0, 40)
    self.logTextLabel.BackgroundTransparency = 1
    self.logTextLabel.Text = "Fluxo Studio companion plugin ready.\nWaiting for CLI connection..."
    self.logTextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.logTextLabel.Font = Enum.Font.Code
    self.logTextLabel.TextSize = 12
    self.logTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.logTextLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.logTextLabel.TextWrapped = true
    self.logTextLabel.Parent = section
end

-- Event handlers
function Dashboard:onValidateClicked()
    self:addLog("🔍 Validation requested...")
    -- This will be handled by the CLI communication
end

function Dashboard:onSyncClicked()
    self:addLog("🔄 Sync requested...")
    -- This will be handled by the CLI communication
end

function Dashboard:onPublishClicked()
    self:addLog("🚀 Publish requested...")
    -- This will show the publish modal
end

function Dashboard:onEditMetadataClicked()
    self:addLog("📝 Opening metadata editor...")
    -- This will show the metadata editor modal
end

-- Additional module support
function Dashboard:setSync(syncModule)
    self.sync = syncModule
end

function Dashboard:setValidation(validationModule)
    self.validation = validationModule
end

function Dashboard:setMetadataEditor(metadataEditorModule)
    self.metadataEditor = metadataEditorModule
end

function Dashboard:setHttpClient(httpClientModule)
    self.httpClient = httpClientModule
end

function Dashboard:setLogger(loggerModule)
    self.logger = loggerModule
end

function Dashboard:setConnectionStatus(isConnected)
    self.isConnected = isConnected
    if self.connectionStatus then
        self.connectionStatus.Text = isConnected and "🟢 Connected" or "🔴 Disconnected"
        self.connectionStatus.TextColor3 = isConnected and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
end

function Dashboard:updateProject(projectInfo)
    self.currentProject = projectInfo
    if self.projectInfo then
        self.projectInfo.Text = "📁 " .. (projectInfo.name or "No Project")
        if projectInfo.lastSync then
            self.lastSyncLabel.Text = "Last sync: " .. projectInfo.lastSync
        end
    end
end

function Dashboard:openValidation()
    if self.validation and self.currentProject then
        self.validation.validateProject(self.currentProject.path or "", self)
    end
end

function Dashboard:openMetadataEditor()
    if self.metadataEditor then
        local currentMeta = self.currentProject and self.currentProject.metadata or {}
        self.metadataEditor.showEditor(currentMeta, function(newMeta)
            if self.currentProject then
                self.currentProject.metadata = newMeta
                self:updateProject(self.currentProject)
            end
        end, self)
    end
end

-- Utility methods
function Dashboard:show()
    self.widget.Enabled = true
    self.isVisible = true
end

function Dashboard:hide()
    self.widget.Enabled = false
    self.isVisible = false
end

function Dashboard:destroy()
    if self.widget then
        self.widget:Destroy()
    end
end

function Dashboard:setConnectionStatus(connected)
    if connected then
        self.statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 100) -- Green
        self:addLog("✅ Connected to Fluxo CLI")
    else
        self.statusIndicator.BackgroundColor3 = Color3.fromRGB(200, 100, 100) -- Red
        self:addLog("❌ Disconnected from Fluxo CLI")
    end
end

function Dashboard:updateProject(projectData)
    if projectData then
        self.projectNameLabel.Text = projectData.name or "Unknown Project"
        self.projectPathLabel.Text = projectData.path or ""
        self.syncStatusLabel.Text = "Last synced: " .. (projectData.lastSync or "Never")
        self:addLog("📁 Project loaded: " .. (projectData.name or "Unknown"))
    else
        self.projectNameLabel.Text = "No project loaded"
        self.projectPathLabel.Text = ""
        self.syncStatusLabel.Text = "Not synced"
    end
end

function Dashboard:addLog(message)
    local timestamp = os.date("[%H:%M:%S]")
    local currentText = self.logTextLabel.Text
    local newText = currentText .. "\n" .. timestamp .. " " .. message
    
    -- Keep only last 20 lines
    local lines = {}
    for line in newText:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    if #lines > 20 then
        local startIndex = #lines - 19
        lines = {table.unpack(lines, startIndex)}
    end
    
    self.logTextLabel.Text = table.concat(lines, "\n")
end

return Dashboard
