--!strict
-- Logger.lua
-- Logging utilities for the Fluxo Studio plugin

local Logger = {}

Logger.LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

Logger.currentLevel = Logger.LogLevel.INFO
Logger.maxLogs = 100
Logger.logs = {}

function Logger.setLogLevel(level)
    Logger.currentLevel = level
end

function Logger.log(level, message, category)
    if level < Logger.currentLevel then
        return
    end
    
    local timestamp = os.date("%H:%M:%S")
    local levelName = ""
    local icon = ""
    
    if level == Logger.LogLevel.DEBUG then
        levelName = "DEBUG"
        icon = "🔧"
    elseif level == Logger.LogLevel.INFO then
        levelName = "INFO"
        icon = "ℹ️"
    elseif level == Logger.LogLevel.WARN then
        levelName = "WARN"
        icon = "⚠️"
    elseif level == Logger.LogLevel.ERROR then
        levelName = "ERROR"
        icon = "❌"
    end
    
    local logEntry = {
        timestamp = timestamp,
        level = level,
        levelName = levelName,
        icon = icon,
        message = message,
        category = category or "General"
    }
    
    -- Add to logs
    table.insert(Logger.logs, logEntry)
    
    -- Maintain max logs limit
    if #Logger.logs > Logger.maxLogs then
        table.remove(Logger.logs, 1)
    end
    
    -- Print to output (for debugging)
    local formattedMessage = string.format("[%s] %s %s: %s", 
        timestamp, icon, levelName, message)
    
    if level >= Logger.LogLevel.ERROR then
        warn(formattedMessage)
    else
        print(formattedMessage)
    end
    
    return logEntry
end

function Logger.debug(message, category)
    return Logger.log(Logger.LogLevel.DEBUG, message, category)
end

function Logger.info(message, category)
    return Logger.log(Logger.LogLevel.INFO, message, category)
end

function Logger.warn(message, category)
    return Logger.log(Logger.LogLevel.WARN, message, category)
end

function Logger.error(message, category)
    return Logger.log(Logger.LogLevel.ERROR, message, category)
end

function Logger.getLogs(count, level)
    local filteredLogs = {}
    
    for i = #Logger.logs, 1, -1 do
        local log = Logger.logs[i]
        if not level or log.level >= level then
            table.insert(filteredLogs, log)
            if count and #filteredLogs >= count then
                break
            end
        end
    end
    
    return filteredLogs
end

function Logger.clearLogs()
    Logger.logs = {}
end

function Logger.exportLogs()
    local logText = ""
    for _, log in ipairs(Logger.logs) do
        logText = logText .. string.format("[%s] %s: %s\n", 
            log.timestamp, log.levelName, log.message)
    end
    return logText
end

-- Performance logging
function Logger.startTimer(name)
    if not Logger.timers then
        Logger.timers = {}
    end
    Logger.timers[name] = tick()
end

function Logger.endTimer(name, message)
    if not Logger.timers or not Logger.timers[name] then
        Logger.warn("Timer '" .. name .. "' was not started")
        return
    end
    
    local elapsed = tick() - Logger.timers[name]
    Logger.timers[name] = nil
    
    local timerMessage = message or ("Timer '" .. name .. "' completed")
    Logger.info(timerMessage .. " (" .. string.format("%.3f", elapsed) .. "s)")
    
    return elapsed
end

return Logger
