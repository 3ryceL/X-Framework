XCore.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-fitbit:use', source)
end)

RegisterServerEvent('x-fitbit:server:setValue')
AddEventHandler('x-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = XCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

XCore.Functions.CreateCallback('x-fitbit:server:HasFitbit', function(source, cb)
    local Ply = XCore.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)