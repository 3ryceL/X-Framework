XCore.Functions.CreateUseableItem("joint", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseJoint", source)
    end
end)

XCore.Functions.CreateUseableItem("armor", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseArmor", source)
end)

XCore.Functions.CreateUseableItem("heavyarmor", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseHeavyArmor", source)
end)

-- XCore.Functions.CreateUseableItem("smoketrailred", function(source, item)
--     local Player = XCore.Functions.GetPlayer(source)
-- 	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
--         TriggerClientEvent("consumables:client:UseRedSmoke", source)
--     end
-- end)

XCore.Functions.CreateUseableItem("parachute", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseParachute", source)
    end
end)

XCore.Commands.Add("resetparachute", "Resets Parachute", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
        TriggerClientEvent("consumables:client:ResetParachute", source)
end)

RegisterServerEvent("x-smallpenis:server:AddParachute")
AddEventHandler("x-smallpenis:server:AddParachute", function()
    local src = source
    local Ply = XCore.Functions.GetPlayer(src)

    Ply.Functions.AddItem("parachute", 1)
end)

XCore.Functions.CreateUseableItem("water_bottle", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("vodka", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

XCore.Functions.CreateUseableItem("beer", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

XCore.Functions.CreateUseableItem("whiskey", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

XCore.Functions.CreateUseableItem("coffee", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("kurkakola", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("sandwich", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("twerks_candy", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("snikkel_candy", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("tosti", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

XCore.Functions.CreateUseableItem("binoculars", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("binoculars:Toggle", source)
end)

XCore.Functions.CreateUseableItem("cokebaggy", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Cokebaggy", source)
end)

XCore.Functions.CreateUseableItem("crack_baggy", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Crackbaggy", source)
end)

XCore.Functions.CreateUseableItem("xtcbaggy", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:EcstasyBaggy", source)
end)

XCore.Functions.CreateUseableItem("firework1", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework")
end)

XCore.Functions.CreateUseableItem("firework2", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework_v2")
end)

XCore.Functions.CreateUseableItem("firework3", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_xmas_firework")
end)

XCore.Functions.CreateUseableItem("firework4", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "scr_indep_fireworks")
end)

XCore.Commands.Add("resetarmor", "Resets Vest (Police Only)", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("consumables:client:ResetArmor", source)
    else
        TriggerClientEvent('XCore:NotifyNotify', source,  "For Emergency Service Only", "error")
    end
end)