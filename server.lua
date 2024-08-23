-- Table to store player names
local playerNames = {}

-- Command to set player name
RegisterCommand("setname", function(source, args, rawCommand)
    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please provide at least a first and last name."}
        })
        return
    end

    local firstName = args[1]
    local lastName = args[#args]
    local fullName = table.concat(args, " ")

    playerNames[source] = {
        full = fullName,
        first = firstName,
        last = lastName,
        lower = fullName:lower() -- Add this line to store lowercase version
    }

    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {"Success", "Your name has been set to: " .. fullName}
    })
end, false)

-- Command for /me actions
RegisterCommand("me", function(source, args, rawCommand)
    if #args == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please provide an action."}
        })
        return
    end

    local playerName = playerNames[source]
    if not playerName then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please set your name first using /setname."}
        })
        return
    end

    local action = table.concat(args, " ")
    local message = string.format("%s %s %s", playerName.first, playerName.last, action)

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('showMeAction', -1, source, message, playerCoords)
end, false)

-- Command for /do actions
RegisterCommand("do", function(source, args, rawCommand)
    if #args == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please provide an action."}
        })
        return
    end

    local message = table.concat(args, " ")
    local taggedPlayer = nil
    local taggedName = nil

    -- Check for tagged player
    for id, name in pairs(playerNames) do
        local fullName = name.full
        if message:find("@" .. fullName) then
            taggedPlayer = id
            taggedName = fullName
            break
        end
    end

    -- Broadcast the /do message to all players
    TriggerClientEvent('showDoAction', -1, message, taggedPlayer, taggedName)
end, false)

-- Command for /gme actions (global /me with tagging)
RegisterCommand("gme", function(source, args, rawCommand)
    if #args == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please provide an action."}
        })
        return
    end

    local playerName = playerNames[source]
    if not playerName then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Error", "Please set your name first using /setname."}
        })
        return
    end

    local message = table.concat(args, " ")
    local taggedPlayer = nil
    local taggedName = nil

    -- Check for tagged player
    for id, name in pairs(playerNames) do
        local fullName = name.full
        if message:find("@" .. fullName) then
            taggedPlayer = id
            taggedName = fullName
            break
        end
    end

    local fullMessage = string.format("%s %s %s", playerName.first, playerName.last, message)
    
    -- Broadcast the /gme message to all players
    TriggerClientEvent('showGmeAction', -1, source, fullMessage, taggedPlayer, taggedName)
end, false)