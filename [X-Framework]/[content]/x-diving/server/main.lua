local CoralTypes = {
    ["dendrogyra_coral"] = math.random(70, 100),
    ["antipatharia_coral"] = math.random(50, 70),
}

-- Code

RegisterServerEvent('x-diving:server:SetBerthVehicle')
AddEventHandler('x-diving:server:SetBerthVehicle', function(BerthId, vehicleModel)
    TriggerClientEvent('x-diving:client:SetBerthVehicle', -1, BerthId, vehicleModel)
    
    XBoatshop.Locations["berths"][BerthId]["boatModel"] = boatModel
end)

RegisterServerEvent('x-diving:server:SetDockInUse')
AddEventHandler('x-diving:server:SetDockInUse', function(BerthId, InUse)
    XBoatshop.Locations["berths"][BerthId]["inUse"] = InUse
    TriggerClientEvent('x-diving:client:SetDockInUse', -1, BerthId, InUse)
end)

XCore.Functions.CreateCallback('x-diving:server:GetBusyDocks', function(source, cb)
    cb(XBoatshop.Locations["berths"])
end)

RegisterServerEvent('x-diving:server:BuyBoat')
AddEventHandler('x-diving:server:BuyBoat', function(boatModel, BerthId)
    local BoatPrice = XBoatshop.ShopBoats[boatModel]["price"]
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local PlayerMoney = {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank,
    }
    local missingMoney = 0
    local plate = "X-"..math.random(1000, 9999)

    if PlayerMoney.cash >= BoatPrice then
        Player.Functions.RemoveMoney('cash', BoatPrice, "bought-boat")
        TriggerClientEvent('x-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    elseif PlayerMoney.bank >= BoatPrice then
        Player.Functions.RemoveMoney('bank', BoatPrice, "bought-boat")
        TriggerClientEvent('x-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    else
        if PlayerMoney.bank > PlayerMoney.cash then
            missingMoney = (BoatPrice - PlayerMoney.bank)
        else
            missingMoney = (BoatPrice - PlayerMoney.cash)
        end
        TriggerClientEvent('XCore:NotifyNotify', src, 'Not Enough Money, You Are Missing $'..missingMoney..'', 'error')
    end
end)

function InsertBoat(boatModel, Player, plate)
    exports.ghmattimysql:execute('INSERT INTO player_boats (citizenid, model, plate) VALUES (@citizenid, @model, @plate)', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@model'] = boatModel,
        ['@plate'] = plate
    })
end

XCore.Functions.CreateUseableItem("jerry_can", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)

    TriggerClientEvent("x-diving:client:UseJerrycan", source)
end)

XCore.Functions.CreateUseableItem("diving_gear", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)

    TriggerClientEvent("x-diving:client:UseGear", source, true)
end)

RegisterServerEvent('x-diving:server:RemoveItem')
AddEventHandler('x-diving:server:RemoveItem', function(item, amount)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)
end)

XCore.Functions.CreateCallback('x-diving:server:GetMyBoats', function(source, cb, dock)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM player_boats WHERE citizenid=@citizenid AND boathouse=@boathouse', {['@citizenid'] = Player.PlayerData.citizenid, ['@boathouse'] = dock}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

XCore.Functions.CreateCallback('x-diving:server:GetDepotBoats', function(source, cb, dock)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM player_boats WHERE citizenid=@citizenid AND state=@state', {['@citizenid'] = Player.PlayerData.citizenid, ['@state'] = 0}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('x-diving:server:SetBoatState')
AddEventHandler('x-diving:server:SetBoatState', function(plate, state, boathouse)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT plate FROM player_boats WHERE plate=@plate', {['@plate'] = plate}, function(result)
        if result[1] ~= nil then
            exports.ghmattimysql:execute('UPDATE player_boats SET state=@state WHERE plate=@plate AND citizenid=@citizenid', {['@state'] = state, ['@plate'] = plate, ['@citizenid'] = Player.PlayerData.citizenid})
            if state == 1 then
                exports.ghmattimysql:execute('UPDATE player_boats SET boathouse=@boathouse WHERE plate=@plate AND citizenid=@citizenid', {['@boathouse'] = boathouse, ['@plate'] = plate, ['@citizenid'] = Player.PlayerData.citizenid})
            end
        end
    end)
end)

RegisterServerEvent('x-diving:server:CallCops')
AddEventHandler('x-diving:server:CallCops', function(Coords)
    local src = source
    for k, v in pairs(XCore.Functions.GetPlayers()) do
        local Player = XCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                local msg = "This coral may be stolen"
                TriggerClientEvent('x-diving:client:CallCops', Player.PlayerData.source, Coords, msg)
                local alertData = {
                    title = "Illegaalduiken",
                    coords = {x = Coords.x, y = Coords.y, z = Coords.z},
                    description = msg,
                }
                TriggerClientEvent("x-phone:client:addPoliceAlert", -1, alertData)
            end
        end
	end
end)

local AvailableCoral = {}

XCore.Commands.Add("divingsuit", "Take off your diving suit", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("x-diving:client:UseGear", source, false)
end)

RegisterServerEvent('x-diving:server:SellCoral')
AddEventHandler('x-diving:server:SellCoral', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    if HasCoral(src) then
        for k, v in pairs(AvailableCoral) do
            local Item = Player.Functions.GetItemByName(v.item)
            local price = (Item.amount * v.price)
            local Reward = math.ceil(GetItemPrice(Item, price))

            if Item.amount > 1 then
                for i = 1, Item.amount, 1 do
                    Player.Functions.RemoveItem(Item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[Item.name], "remove")
                    Player.Functions.AddMoney('cash', math.ceil((Reward / Item.amount)), "sold-coral")
                    Citizen.Wait(250)
                end
            else
                Player.Functions.RemoveItem(Item.name, 1)
                Player.Functions.AddMoney('cash', Reward, "sold-coral")
                TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[Item.name], "remove")
            end
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, 'You don\'t have any coral to sell..', 'error')
    end
end)


function GetItemPrice(Item, price)
    if Item.amount > 5 then
        price = price / 100 * 80
    elseif Item.amount > 10 then
        price = price / 100 * 70
    elseif Item.amount > 15 then
        price = price / 100 * 50
    end
    return price
end

function HasCoral(src)
    local Player = XCore.Functions.GetPlayer(src)
    local retval = false
    AvailableCoral = {}

    for k, v in pairs(XDiving.CoralTypes) do
        local Item = Player.Functions.GetItemByName(v.item)
        if Item ~= nil then
            table.insert(AvailableCoral, v)
            retval = true
        end
    end
    return retval
end
