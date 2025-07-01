--!strict
-- HttpClient.lua
-- HTTP utilities for communicating with the Fluxo CLI

local HttpService = game:GetService("HttpService")

local HttpClient = {}

HttpClient.BASE_URL = "http://localhost:8080" -- Default CLI server port
HttpClient.TIMEOUT = 10 -- Request timeout in seconds

function HttpClient.setBaseUrl(url)
    HttpClient.BASE_URL = url
end

function HttpClient.get(endpoint, onSuccess, onError)
    local url = HttpClient.BASE_URL .. endpoint
    
    local success, result = pcall(function()
        return HttpService:GetAsync(url, false)
    end)
    
    if success then
        local data = HttpService:JSONDecode(result)
        if onSuccess then
            onSuccess(data)
        end
        return data
    else
        if onError then
            onError("GET request failed: " .. tostring(result))
        end
        return nil
    end
end

function HttpClient.post(endpoint, data, onSuccess, onError)
    local url = HttpClient.BASE_URL .. endpoint
    local jsonData = HttpService:JSONEncode(data or {})
    
    local success, result = pcall(function()
        return HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson, false)
    end)
    
    if success then
        local responseData = HttpService:JSONDecode(result)
        if onSuccess then
            onSuccess(responseData)
        end
        return responseData
    else
        if onError then
            onError("POST request failed: " .. tostring(result))
        end
        return nil
    end
end

function HttpClient.put(endpoint, data, onSuccess, onError)
    local url = HttpClient.BASE_URL .. endpoint
    local jsonData = HttpService:JSONEncode(data or {})
    
    local success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "PUT",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
    
    if success and result.Success then
        local responseData = HttpService:JSONDecode(result.Body)
        if onSuccess then
            onSuccess(responseData)
        end
        return responseData
    else
        local errorMsg = success and result.StatusMessage or tostring(result)
        if onError then
            onError("PUT request failed: " .. errorMsg)
        end
        return nil
    end
end

function HttpClient.delete(endpoint, onSuccess, onError)
    local url = HttpClient.BASE_URL .. endpoint
    
    local success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "DELETE"
        })
    end)
    
    if success and result.Success then
        local responseData = HttpService:JSONDecode(result.Body)
        if onSuccess then
            onSuccess(responseData)
        end
        return responseData
    else
        local errorMsg = success and result.StatusMessage or tostring(result)
        if onError then
            onError("DELETE request failed: " .. errorMsg)
        end
        return nil
    end
end

function HttpClient.testConnection(onSuccess, onError)
    HttpClient.get("/health", 
        function(data)
            if onSuccess then
                onSuccess(data)
            end
        end,
        function(error)
            if onError then
                onError(error)
            end
        end
    )
end

return HttpClient
