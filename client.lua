local meDistance = 20.0 -- Distance in meters for /me visibility
local displayTime = 5000 -- Time to display the 3D text (in ms)
local activeMessages = {}

RegisterNetEvent('showMeAction')
AddEventHandler('showMeAction', function(playerId, message, sourceCoords)
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    
    if #(playerCoords - sourceCoords) <= meDistance then
        -- Chat message
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"", "* " .. message .. " *"}
        })
        
        -- 3D text
        local formattedMessage = "* " .. message .. " *"
        table.insert(activeMessages, {
            playerId = playerId,
            message = formattedMessage,
            expireTime = GetGameTimer() + displayTime
        })
    end
end)

RegisterNetEvent('showDoAction')
AddEventHandler('showDoAction', function(message, taggedPlayer, taggedName)
    local source = GetPlayerServerId(PlayerId())
    local isTagged = (source == taggedPlayer)
    
    local displayMessage = message
    if taggedName then
        if isTagged then
            -- Highlight the tagged name for the tagged player
            displayMessage = displayMessage:gsub("@" .. taggedName, "^3@" .. taggedName .. "^7")
        else
            -- Remove the @ symbol for other players
            displayMessage = displayMessage:gsub("@" .. taggedName, taggedName)
        end
    end

    TriggerEvent('chat:addMessage', {
        color = isTagged and {255, 255, 0} or {230, 230, 250}, -- Yellow if tagged, light purple otherwise
        multiline = true,
        args = {"", "* " .. displayMessage .. " *"}
    })
end)

RegisterNetEvent('showGmeAction')
AddEventHandler('showGmeAction', function(playerId, message, taggedPlayer, taggedName)
    local source = GetPlayerServerId(PlayerId())
    local isTagged = (source == taggedPlayer)
    
    local displayMessage = message
    if taggedName then
        if isTagged then
            -- Highlight the tagged name for the tagged player
            displayMessage = displayMessage:gsub("@" .. taggedName, "^3@" .. taggedName .. "^7")
        else
            -- Remove the @ symbol for other players
            displayMessage = displayMessage:gsub("@" .. taggedName, taggedName)
        end
    end

    TriggerEvent('chat:addMessage', {
        color = isTagged and {255, 255, 0} or {255, 255, 255}, -- Yellow if tagged, white otherwise
        multiline = true,
        args = {"", "* " .. displayMessage .. " *"}
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local currentTime = GetGameTimer()
        
        for i, messageData in ipairs(activeMessages) do
            if currentTime < messageData.expireTime then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(messageData.playerId))
                local targetCoords = GetEntityCoords(targetPed)
                DrawText3D(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, messageData.message)
            else
                table.remove(activeMessages, i)
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end