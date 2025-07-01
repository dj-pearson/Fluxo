--!strict
-- Server.lua
-- Handles HTTP communication with the Fluxo CLI

local Server = {}
Server.__index = Server

-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

function Server.new(port)
    local self = setmetatable({}, Server)
    
    self.port = port or 8080
    self.isRunning = false
    self.connections = {}
    
    -- Create bindable events for communication
    self.onSyncRequest = Instance.new("BindableEvent")
    self.onPublishRequest = Instance.new("BindableEvent")
    self.onValidateRequest = Instance.new("BindableEvent")
    
    return self
end

function Server:start()
    if self.isRunning then
        return
    end
    
    self.isRunning = true
    print("[Fluxo Server] Starting HTTP server on port " .. self.port)
    
    -- Start polling for requests
    self.connections.heartbeat = RunService.Heartbeat:Connect(function()
        self:poll()
    end)
    
    -- Create a simple HTTP server simulation
    -- In a real implementation, this would use HttpService to listen for requests
    -- For now, we'll simulate with periodic checks
end

function Server:stop()
    if not self.isRunning then
        return
    end
    
    self.isRunning = false
    print("[Fluxo Server] Stopping HTTP server")
    
    -- Disconnect all connections
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

function Server:poll()
    -- This would normally check for incoming HTTP requests
    -- For development, we'll simulate with a simple health check mechanism
    
    -- Try to respond to health check requests
    local success, result = pcall(function()
        -- In a real implementation, this would handle actual HTTP requests
        return HttpService:GetAsync("http://localhost:" .. self.port .. "/health", false)
    end)
    
    if success then
        -- Process any pending requests
        self:processRequests()
    end
end

function Server:processRequests()
    -- This method would process incoming requests from the CLI
    -- For now, we'll implement a basic request handler
end

function Server:handleSyncRequest(data)
    print("[Fluxo Server] Received sync request")
    self.onSyncRequest:Fire(data)
    
    -- Send response back to CLI
    return {
        success = true,
        message = "Sync request received"
    }
end

function Server:handlePublishRequest(data)
    print("[Fluxo Server] Received publish request")
    self.onPublishRequest:Fire(data)
    
    -- Send response back to CLI
    return {
        success = true,
        message = "Publish request received"
    }
end

function Server:handleValidateRequest(data)
    print("[Fluxo Server] Received validate request")
    self.onValidateRequest:Fire(data)
    
    -- Send response back to CLI
    return {
        success = true,
        message = "Validate request received"
    }
end

function Server:sendResponse(endpoint, data)
    local success, result = pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        return HttpService:PostAsync(
            "http://localhost:" .. self.port .. endpoint,
            jsonData,
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    return success, result
end

function Server:isCliConnected()
    local success, _ = pcall(function()
        HttpService:GetAsync("http://localhost:" .. self.port .. "/health", false)
    end)
    
    return success
end

return Server
