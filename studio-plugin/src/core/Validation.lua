--!strict
-- Validation.lua
-- Handles project validation functionality

local Validation = {}

function Validation.validateProject(projectPath, dashboard)
    dashboard:addLog("🔍 Starting project validation...")
    
    local issues = {}
    local warnings = {}
    local suggestions = {}
    
    -- Basic structure validation
    if not Validation.checkProjectStructure(projectPath) then
        table.insert(issues, "Invalid project structure")
    end
    
    -- Configuration validation
    local configIssues = Validation.validateConfiguration(projectPath)
    for _, issue in ipairs(configIssues) do
        table.insert(issues, issue)
    end
    
    -- File validation
    local fileIssues, fileWarnings = Validation.validateFiles(projectPath)
    for _, issue in ipairs(fileIssues) do
        table.insert(issues, issue)
    end
    for _, warning in ipairs(fileWarnings) do
        table.insert(warnings, warning)
    end
    
    -- Best practices check
    local bestPractices = Validation.checkBestPractices(projectPath)
    for _, suggestion in ipairs(bestPractices) do
        table.insert(suggestions, suggestion)
    end
    
    -- Generate report
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        projectPath = projectPath,
        issues = issues,
        warnings = warnings,
        suggestions = suggestions,
        isValid = #issues == 0
    }
    
    -- Display results
    Validation.showValidationReport(report, dashboard)
    
    return report
end

function Validation.checkProjectStructure(projectPath)
    -- Basic project structure checks
    -- This would typically check for required files like:
    -- - project.json or default.project.json
    -- - src folder
    -- - fluxo.config.json
    return true -- Placeholder
end

function Validation.validateConfiguration(projectPath)
    local issues = {}
    
    -- Check fluxo.config.json
    -- This would validate:
    -- - Required fields
    -- - Valid values
    -- - Compatibility settings
    
    return issues
end

function Validation.validateFiles(projectPath)
    local issues = {}
    local warnings = {}
    
    -- File-specific validations:
    -- - Lua syntax checking
    -- - Asset validation
    -- - Naming conventions
    -- - File size limits
    
    return issues, warnings
end

function Validation.checkBestPractices(projectPath)
    local suggestions = {}
    
    -- Best practice suggestions:
    -- - Code organization
    -- - Performance optimizations
    -- - Security considerations
    -- - Documentation completeness
    
    table.insert(suggestions, "Consider adding README.md documentation")
    table.insert(suggestions, "Add version control ignore files")
    table.insert(suggestions, "Use consistent naming conventions")
    
    return suggestions
end

function Validation.showValidationReport(report, dashboard)
    -- Create validation report modal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FluxoValidationReport"
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
    dialog.Size = UDim2.new(0, 700, 0, 500)
    dialog.Position = UDim2.new(0.5, -350, 0.5, -250)
    dialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dialog.BorderSizePixel = 0
    dialog.Parent = overlay
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialog
    
    -- Title with status
    local statusColor = report.isValid and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    local statusText = report.isValid and "✅ Validation Passed" or "❌ Validation Failed"
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = statusText
    title.TextColor3 = statusColor
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dialog
    
    -- Scrolling content
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
    
    -- Content layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.Parent = scrollFrame
    
    local yPosition = 0
    
    -- Issues section
    if #report.issues > 0 then
        Validation.addReportSection(scrollFrame, "❌ Issues (" .. #report.issues .. ")", 
            report.issues, Color3.fromRGB(255, 100, 100), yPosition)
        yPosition = yPosition + 40 + (#report.issues * 25)
    end
    
    -- Warnings section
    if #report.warnings > 0 then
        Validation.addReportSection(scrollFrame, "⚠️ Warnings (" .. #report.warnings .. ")", 
            report.warnings, Color3.fromRGB(255, 200, 100), yPosition)
        yPosition = yPosition + 40 + (#report.warnings * 25)
    end
    
    -- Suggestions section
    if #report.suggestions > 0 then
        Validation.addReportSection(scrollFrame, "💡 Suggestions (" .. #report.suggestions .. ")", 
            report.suggestions, Color3.fromRGB(100, 200, 255), yPosition)
        yPosition = yPosition + 40 + (#report.suggestions * 25)
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 50)
    
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
    
    -- Log summary
    dashboard:addLog("📊 Validation complete: " .. #report.issues .. " issues, " .. 
        #report.warnings .. " warnings, " .. #report.suggestions .. " suggestions")
end

function Validation.addReportSection(parent, title, items, color, yPos)
    -- Section header
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = color
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.LayoutOrder = yPos
    header.Parent = parent
    
    -- Items
    for i, item in ipairs(items) do
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Size = UDim2.new(1, -20, 0, 20)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Text = "• " .. item
        itemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        itemLabel.Font = Enum.Font.SourceSans
        itemLabel.TextSize = 12
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.TextWrapped = true
        itemLabel.LayoutOrder = yPos + i
        itemLabel.Parent = parent
    end
end

return Validation
