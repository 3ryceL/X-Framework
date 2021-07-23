RegisterNetEvent('x-vineyard:server:getGrapes')
AddEventHandler('x-vineyard:server:getGrapes', function()
    local Player = XCore.Functions.GetPlayer(source)

    Player.Functions.AddItem("grape", Config.GrapeAmount)
    TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['grape'], "add")
end)

RegisterServerEvent('x-vineyard:server:loadIngredients') 
AddEventHandler('x-vineyard:server:loadIngredients', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    local grape = xPlayer.Functions.GetItemByName('grape')

	if xPlayer.PlayerData.items ~= nil then 
        if grape ~= nil then 
            if grape.amount >= 23 then 

                xPlayer.Functions.RemoveItem("grape", 23, false)
                TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['grape'], "remove")
                
                TriggerClientEvent("x-vineyard:client:loadIngredients", source)

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

RegisterServerEvent('x-vineyard:server:grapeJuice') 
AddEventHandler('x-vineyard:server:grapeJuice', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))
    local grape = xPlayer.Functions.GetItemByName('grape')

	if xPlayer.PlayerData.items ~= nil then 
        if grape ~= nil then 
            if grape.amount >= 16 then 

                xPlayer.Functions.RemoveItem("grape", 16, false)
                TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['grape'], "remove")
                
                TriggerClientEvent("x-vineyard:client:grapeJuice", source)

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

RegisterServerEvent('x-vineyard:server:receiveWine')
AddEventHandler('x-vineyard:server:receiveWine', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("wine", Config.WineAmount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['wine'], "add")
end)

RegisterServerEvent('x-vineyard:server:receiveGrapeJuice')
AddEventHandler('x-vineyard:server:receiveGrapeJuice', function()
	local xPlayer = XCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("grapejuice", Config.GrapeJuiceAmount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, XCore.Shared.Items['grapejuice'], "add")
end)


-- Hire/Fire

--[[ XCore.Commands.Add("hirevineyard", "Hire a player to the Vineyard!", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = XCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.gang.name == "la_familia") then
            Player.Functions.SetJob("vineyard")
        end
    end
end)

XCore.Commands.Add("firevineyard", "Fire a player to the Vineyard!", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = XCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = XCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.gang.name == "la_familia") then
            Player.Functions.SetJob("unemployed")
        end
    end
end) ]]