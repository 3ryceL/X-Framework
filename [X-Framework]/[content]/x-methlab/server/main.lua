Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    print('Lab entry has been set to location: '..Config.CurrentLab)
end)

XCore.Functions.CreateCallback('x-methlab:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

XCore.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('x-methlab:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end

RegisterServerEvent('x-methlab:server:loadIngredients')
AddEventHandler('x-methlab:server:loadIngredients', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = xPlayer.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = xPlayer.Functions.GetItemByName('ephedrine')
    local acetone = xPlayer.Functions.GetItemByName('acetone')

	if xPlayer.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then 
            if hydrochloricacid.amount >= 3 and ephedrine.amount >= 3 and acetone.amount >= 3 then 

                xPlayer.Functions.RemoveItem("hydrochloricacid", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['hydrochloricacid'], "remove")
                
                xPlayer.Functions.RemoveItem("ephedrine", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['ephedrine'], "remove")

                xPlayer.Functions.RemoveItem("acetone", 3, false)
                TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['acetone'], "remove")

                TriggerClientEvent("x-methlab:client:loadIngredients", source)

            else
                TriggerClientEvent('XCore:NotifyNotify', source, "You do not have the correct items", 'error')   
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', source, "You do not have the correct items", 'error')   
        end
	else
		TriggerClientEvent('XCore:NotifyNotify', source, "You Have Nothing...", "error")
	end 
	
end) 

RegisterServerEvent('x-methlab:server:breakMeth')
AddEventHandler('x-methlab:server:breakMeth', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    local meth = xPlayer.Functions.GetItemByName('methtray')
    local puremethtray = xPlayer.Functions.GetItemByName('puremethtray')

	if xPlayer.PlayerData.items ~= nil then 
        if (meth ~= nil or puremethtray ~= nil) then 
                TriggerClientEvent("x-methlab:client:breakMeth", source)
        else
            TriggerClientEvent('XCore:NotifyNotify', source, "You do not have the correct items", 'error')   
        end
	else
		TriggerClientEvent('XCore:NotifyNotify', source, "You Have Nothing...", "error")
	end
	
end)

-- meth Run
RegisterServerEvent('x-methlab:server:server')
AddEventHandler('x-methlab:server:server', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
	local cash = xPlayer.Functions.GetItemByName('cash')

	-- if xPlayer.PlayerData.items ~= nil then 
        -- if cash ~= nil and cash.amount >= Config.StartMethPayment then 
            -- xPlayer.Functions.RemoveItem("cash", Config.StartMethPayment, false)
            -- TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['cash'], "remove")
            TriggerClientEvent("x-methlab:client:startDealing", source)
        -- else
            -- TriggerClientEvent('XCore:NotifyNotify', source, "You do not have enough cash", 'error')   
            
        -- end
	-- else
		-- TriggerClientEvent('XCore:NotifyNotify', source, "You Have Nothing...", "error")
	-- end
	
end)

RegisterServerEvent('x-methlab:server:receiveBigRewarditem')
AddEventHandler('x-methlab:server:receiveBigRewarditem', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("security_card_02", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['security_card_02'], "add")
	-- xPlayer.addInventoryItem(Config.BigRewarditem, 1)
end)

RegisterServerEvent('x-methlab:server:receivemeth')
AddEventHandler('x-methlab:server:receivemeth', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    local chance = math.random(1, 900)
    if chance <= 300 then
        xPlayer.Functions.AddItem("ephedrine", Config.MethAmount, false)
        TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['ephedrine'], "add")
    elseif chance >= 301 and chance <= 600 then
        xPlayer.Functions.AddItem("hydrochloricacid", Config.MethAmount, false)
        TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['hydrochloricacid'], "add")
    elseif chance >= 601 and chance <= 900 then
        xPlayer.Functions.AddItem("acetone", Config.MethAmount, false)
        TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['acetone'], "add")
    end
end)

RegisterServerEvent('x-methlab:server:getmethtray')
AddEventHandler('x-methlab:server:getmethtray', function(amount)
    local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    
    local methtray = xPlayer.Functions.GetItemByName('methtray')
    local puremethtray = xPlayer.Functions.GetItemByName('puremethtray')

    if puremethtray ~= nil then 
        if puremethtray.amount >= 1 then 
            xPlayer.Functions.AddItem("puremeth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['puremeth'], "add")

            xPlayer.Functions.RemoveItem("puremethtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['puremethtray'], "remove")
        end
    elseif methtray ~= nil then 
        if methtray.amount >= 1 then 
            xPlayer.Functions.AddItem("meth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['meth'], "add")

            xPlayer.Functions.RemoveItem("methtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['methtray'], "remove")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You do not have the correct items", 'error')   
    end

end)

RegisterServerEvent('x-methlab:server:receivemethtray')
AddEventHandler('x-methlab:server:receivemethtray', function()
    local xPlayer = XCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("methtray", 3, false)
	TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['methtray'], "add")
    
end)

-- Meth Robbery

RegisterServerEvent('x-methlab:server:setSpotState')
AddEventHandler('x-methlab:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Pharmacy["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Pharmacy["takeables"][spot].isDone = state
    end
    TriggerClientEvent('x-methlab:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('x-methlab:server:itemReward')
AddEventHandler('x-methlab:server:itemReward', function(spot)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local item = Config.Pharmacy["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('XCore:NotifyNotify', src, 'You have to much in your pocket ..', 'error')
    end    
end)

RegisterServerEvent('x-methlab:server:LoadLocationList')
AddEventHandler('x-methlab:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("x-methlab:server:LoadLocationList", src, Config.Pharmacy)
end)

RegisterServerEvent('x-methlab:server:PoliceAlertMessage')
AddEventHandler('x-methlab:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(XCore.Functions.GetPlayers()) do
        local Player = XCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("x-methlab:client:PoliceAlertMessage", v, msg, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("x-methlab:client:PoliceAlertMessage", v, msg, coords, blip) 
                end
            end
        end
    end
end)