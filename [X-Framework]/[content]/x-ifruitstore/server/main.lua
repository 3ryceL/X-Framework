local alarmTriggered = false
local certificateAmount = 43

RegisterServerEvent('x-ifruitstore:server:LoadLocationList')
AddEventHandler('x-ifruitstore:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("x-ifruitstore:server:LoadLocationList", src, Config.Locations)
end)

RegisterServerEvent('x-ifruitstore:server:setSpotState')
AddEventHandler('x-ifruitstore:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
    TriggerClientEvent('x-ifruitstore:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('x-ifruitstore:server:SetThermiteStatus')
AddEventHandler('x-ifruitstore:server:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
    TriggerClientEvent('x-ifruitstore:client:SetThermiteStatus', -1, stateType, state)
end)

RegisterServerEvent('x-ifruitstore:server:SafeReward')
AddEventHandler('x-ifruitstore:server:SafeReward', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(1500, 2000), "robbery-ifruit")
    Player.Functions.AddItem("certificate", certificateAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["certificate"], "add")
    Citizen.Wait(500)
    local luck = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("goldbar", math.random(1, 2))
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["goldbar"], "add")
    end
end)

RegisterServerEvent('x-ifruitstore:server:SetSafeStatus')
AddEventHandler('x-ifruitstore:server:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
    TriggerClientEvent('x-ifruitstore:client:SetSafeStatus', -1, stateType, state)
end)

RegisterServerEvent('x-ifruitstore:server:itemReward')
AddEventHandler('x-ifruitstore:server:itemReward', function(spot)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local item = Config.Locations["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('XCore:NotifyNotify', src, 'You have to much in your pocket ..', 'error')
    end    
end)

RegisterServerEvent('x-ifruitstore:server:PoliceAlertMessage')
AddEventHandler('x-ifruitstore:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(XCore.Functions.GetPlayers()) do
        local Player = XCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police") then  
                TriggerClientEvent("x-ifruitstore:client:PoliceAlertMessage", v, msg, coords, blip) 
            end
        end
    end
end)

RegisterServerEvent('x-ifruitstore:server:callCops')
AddEventHandler('x-ifruitstore:server:callCops', function(streetLabel, coords)
    local place = "iFruitStore"
    local msg = "The Alram has been activated at the "..place.. " at " ..streetLabel

    TriggerClientEvent("x-ifruitstore:client:robberyCall", -1, streetLabel, coords)

end)