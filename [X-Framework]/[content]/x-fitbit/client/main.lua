local inWatch = false
local isLoggedIn = false

RegisterNetEvent("XCore:NotifyClient:OnPlayerUnload")
AddEventHandler("XCore:NotifyClient:OnPlayerUnload", function()
    isLoggedIn = false
end)

RegisterNetEvent("XCore:NotifyClient:OnPlayerLoaded")
AddEventHandler("XCore:NotifyClient:OnPlayerLoaded", function()
    isLoggedIn = true
end)

function openWatch()
    SendNUIMessage({
        action = "openWatch",
        watchData = {}
    })
    SetNuiFocus(true, true)
    inWatch = true
end

function closeWatch()
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function()
    closeWatch()
end)

RegisterNetEvent('x-fitbit:use')
AddEventHandler('x-fitbit:use', function()
  openWatch(true)
end)

RegisterNUICallback('setFoodWarning', function(data)
    local foodValue = tonumber(data.value)

    TriggerServerEvent('x-fitbit:server:setValue', 'food', foodValue)

    XCore.Functions.Notify('Fitbit: Hunger warning set to '..foodValue..'%')
end)

RegisterNUICallback('setThirstWarning', function(data)
    local thirstValue = tonumber(data.value)

    TriggerServerEvent('x-fitbit:server:setValue', 'thirst', thirstValue)

    XCore.Functions.Notify('Fitbit: Thirst warning set to '..thirstValue..'%')
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5 * 60 * 1000)
        
        if isLoggedIn then
            XCore.Functions.TriggerCallback('x-fitbit:server:HasFitbit', function(hasItem)
                if hasItem then
                    local PlayerData = XCore.Functions.GetPlayerData()
                    if PlayerData.metadata["fitbit"].food ~= nil then
                        if PlayerData.metadata["hunger"] < PlayerData.metadata["fitbit"].food then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Your hunger is "..round(PlayerData.metadata["hunger"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
        
                    if PlayerData.metadata["fitbit"].thirst ~= nil then
                        if PlayerData.metadata["thirst"] < PlayerData.metadata["fitbit"].thirst  then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Your thirst is "..round(PlayerData.metadata["thirst"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
                end
            end, "fitbit")
        end
    end
end)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
