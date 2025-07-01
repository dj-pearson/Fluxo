--!strict
-- MetadataEditor.lua
-- Handles metadata editing functionality for plugins

local MetadataEditor = {}

function MetadataEditor.showEditor(currentMeta, onSave, dashboard)
    -- Create metadata editor modal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluxoMetadataEditor"
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
    dialog.Size = UDim2.new(0, 600, 0, 700)
    dialog.Position = UDim2.new(0.5, -300, 0.5, -350)
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
    title.Text = "📝 Edit Plugin Metadata"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dialog
    
    -- Scrolling form
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -40, 1, -120)
    scrollFrame.Position = UDim2.new(0, 20, 0, 70)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = dialog
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    -- Form layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 15)
    listLayout.Parent = scrollFrame
    
    local formPadding = Instance.new("UIPadding")
    formPadding.PaddingTop = UDim.new(0, 20)
    formPadding.PaddingLeft = UDim.new(0, 20)
    formPadding.PaddingRight = UDim.new(0, 20)
    formPadding.PaddingBottom = UDim.new(0, 20)
    formPadding.Parent = scrollFrame
    
    -- Form fields
    local fields = {}
    
    -- Plugin Name
    local nameField = MetadataEditor.createTextField("Plugin Name", 
        currentMeta.name or "", "The display name of your plugin", 1)
    nameField.Parent = scrollFrame
    fields.name = nameField:FindFirstChild("Input")
    
    -- Description
    local descField = MetadataEditor.createTextArea("Description", 
        currentMeta.description or "", "Brief description of what your plugin does", 2)
    descField.Parent = scrollFrame
    fields.description = descField:FindFirstChild("Input")
    
    -- Version
    local versionField = MetadataEditor.createTextField("Version", 
        currentMeta.version or "1.0.0", "Semantic version (e.g., 1.0.0)", 3)
    versionField.Parent = scrollFrame
    fields.version = versionField:FindFirstChild("Input")
    
    -- Author
    local authorField = MetadataEditor.createTextField("Author", 
        currentMeta.author or "", "Plugin author name", 4)
    authorField.Parent = scrollFrame
    fields.author = authorField:FindFirstChild("Input")
    
    -- Tags
    local tagsField = MetadataEditor.createTextField("Tags", 
        table.concat(currentMeta.tags or {}, ", "), "Comma-separated tags", 5)
    tagsField.Parent = scrollFrame
    fields.tags = tagsField:FindFirstChild("Input")
    
    -- Category
    local categoryField = MetadataEditor.createDropdown("Category", 
        currentMeta.category or "Productivity", {"Productivity", "Building", "Scripting", "UI", "Utility"}, 6)
    categoryField.Parent = scrollFrame
    fields.category = categoryField:FindFirstChild("Selected")
    
    -- Minimum Studio Version
    local minVersionField = MetadataEditor.createTextField("Min Studio Version", 
        currentMeta.minStudioVersion or "", "Minimum required Studio version", 7)
    minVersionField.Parent = scrollFrame
    fields.minStudioVersion = minVersionField:FindFirstChild("Input")
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -40, 0, 40)
    buttonFrame.Position = UDim2.new(0, 20, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = dialog
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 100, 1, 0)
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
    
    -- Save button
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0, 100, 1, 0)
    saveButton.Position = UDim2.new(1, -110, 0, 0)
    saveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.TextSize = 14
    saveButton.Parent = buttonFrame
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveButton
    
    -- Event handlers
    cancelButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    saveButton.MouseButton1Click:Connect(function()
        -- Collect form data
        local metadata = {
            name = fields.name.Text,
            description = fields.description.Text,
            version = fields.version.Text,
            author = fields.author.Text,
            tags = {},
            category = fields.category.Text,
            minStudioVersion = fields.minStudioVersion.Text
        }
        
        -- Parse tags
        local tagsText = fields.tags.Text
        if tagsText and tagsText ~= "" then
            for tag in tagsText:gmatch("[^,]+") do
                local trimmed = tag:match("^%s*(.-)%s*$") -- Trim whitespace
                if trimmed ~= "" then
                    table.insert(metadata.tags, trimmed)
                end
            end
        end
        
        -- Validate required fields
        if metadata.name == "" then
            dashboard:addLog("❌ Plugin name is required")
            return
        end
        
        if metadata.version == "" then
            dashboard:addLog("❌ Version is required")
            return
        end
        
        -- Call save callback
        if onSave then
            onSave(metadata)
        end
        
        dashboard:addLog("✅ Metadata saved successfully")
        screenGui:Destroy()
    end)
    
    overlay.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    dashboard:addLog("📝 Opened metadata editor")
end

function MetadataEditor.createTextField(labelText, value, placeholder, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Input field
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, 0, 0, 35)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.BorderSizePixel = 0
    input.Text = value
    input.PlaceholderText = placeholder
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Font = Enum.Font.SourceSans
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.PaddingRight = UDim.new(0, 10)
    inputPadding.Parent = input
    
    return container
end

function MetadataEditor.createTextArea(labelText, value, placeholder, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 120)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Text area
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, 0, 0, 85)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.BorderSizePixel = 0
    input.Text = value
    input.PlaceholderText = placeholder
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Font = Enum.Font.SourceSans
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextYAlignment = Enum.TextYAlignment.Top
    input.TextWrapped = true
    input.MultiLine = true
    input.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.PaddingRight = UDim.new(0, 10)
    inputPadding.PaddingTop = UDim.new(0, 10)
    inputPadding.PaddingBottom = UDim.new(0, 10)
    inputPadding.Parent = input
    
    return container
end

function MetadataEditor.createDropdown(labelText, selected, options, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 70)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Dropdown button
    local dropdown = Instance.new("TextButton")
    dropdown.Name = "Selected"
    dropdown.Size = UDim2.new(1, 0, 0, 35)
    dropdown.Position = UDim2.new(0, 0, 0, 25)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.BorderSizePixel = 0
    dropdown.Text = selected .. " ▼"
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 14
    dropdown.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Parent = container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdown
    
    local dropdownPadding = Instance.new("UIPadding")
    dropdownPadding.PaddingLeft = UDim.new(0, 10)
    dropdownPadding.PaddingRight = UDim.new(0, 10)
    dropdownPadding.Parent = dropdown
    
    -- Simple dropdown functionality (just cycles through options)
    local currentIndex = 1
    for i, option in ipairs(options) do
        if option == selected then
            currentIndex = i
            break
        end
    end
    
    dropdown.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then
            currentIndex = 1
        end
        dropdown.Text = options[currentIndex] .. " ▼"
    end)
    
    return container
end

return MetadataEditor
