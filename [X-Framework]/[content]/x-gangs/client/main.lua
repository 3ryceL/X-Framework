XCore = nil
Config = {}

Citizen.CreateThread(function()
    while XCore == nil do
        TriggerEvent("XCore:NotifyGetObject", function(obj) XCore = obj end)
        Citizen.Wait(100) 
    end

    XCore.Functions.TriggerCallback("x-gangs:server:FetchConfig", function(gangs)
        Config.Gangs = gangs
    end)
end)

RegisterNetEvent("x-gangs:client:UpdateGangs")
AddEventHandler("x-gangs:client:UpdateGangs", function(gangs)
    Config.Gangs = gangs
end)

isLoggedIn = false
local PlayerGang = {}

RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerGang = XCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('XCore:NotifyClient:OnPlayerUnload')
AddEventHandler('XCore:NotifyClient:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('XCore:NotifyClient:OnGangUpdate')
AddEventHandler('XCore:NotifyClient:OnGangUpdate', function(GangInfo)
    PlayerGang = GangInfo
    isLoggedIn = true
end)

local currentAction = "none"

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isLoggedIn and PlayerGang.name ~= "none" then
        	if Config.Gangs[PlayerGang.name] ~= nil then
	            v = Config.Gangs[PlayerGang.name]["Stash"]

	            ped = PlayerPedId()
	            pos = GetEntityCoords(ped)

	            stashdist = #(pos - vector3(v["coords"].x, v["coords"].y, v["coords"].z))
	            if stashdist < 5.0 then
	                DrawMarker(2, v["coords"].x, v["coords"].y, v["coords"].z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
	                if stashdist < 1.5 then
	                    XCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "[~g~E~w~] - Stash")
	                    currentAction = "stash"
	                elseif stashdist < 2.0 then
	                    XCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "Stash")
	                    currentAction = "none"
	                end
	            else
	                Citizen.Wait(1000)
	            end
	        end
        else
            Citizen.Wait(2500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isLoggedIn and PlayerGang.name ~= "none" then
        	if Config.Gangs[PlayerGang.name] ~= nil then
	            v = Config.Gangs[PlayerGang.name]["VehicleSpawner"]
	            ped = PlayerPedId()
	            pos = GetEntityCoords(ped)

	            vehdist = #(pos - vector3(v["coords"].x, v["coords"].y, v["coords"].z))

	            if vehdist < 5.0 then
	                DrawMarker(2, v["coords"].x, v["coords"].y, v["coords"].z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
	                if vehdist < 1.5 then
	                    XCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "[~g~E~w~] - Garage")
	                    currentAction = "garage"
	                elseif vehdist < 2.0 then
	                    XCore.Functions.DrawText3D(v["coords"].x, v["coords"].y, v["coords"].z, "Garage")
	                    currentAction = "none"
	                end
	                
	                Menu.renderGUI()
	            else
	                Citizen.Wait(1000)
	            end
	        end
        else
            Citizen.Wait(2500)
        end
    end
end)

RegisterCommand("+GangInteract", function()
    if currentAction == "stash" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", PlayerGang.name.."stash", {
            maxweight = 4000000,
            slots = 500,
        })
        TriggerEvent("inventory:client:SetCurrentStash", PlayerGang.name.."stash")
    elseif currentAction == "garage" then
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            DeleteVehicle(GetVehiclePedIsIn(GetPlayerPed(-1)))
        else
            GangGarage()
            Menu.hidden = not Menu.hidden
        end
    end
end, false)
RegisterCommand("-GangInteract", function()
end, false)
TriggerEvent("chat:removeSuggestion", "/+GangInteract")
TriggerEvent("chat:removeSuggestion", "/-GangInteract")

RegisterKeyMapping("+GangInteract", "Interaction for gang script", "keyboard", "e")

function GangGarage()
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicle", "VehicleList", nil)
    Menu.addButton("Close menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    MenuTitle = "Vehicle:"
    ClearMenu()
    Vehicles = Config.Gangs[PlayerGang.name]["VehicleSpawner"]["vehicles"]
    for k, v in pairs(Vehicles) do
        Menu.addButton(Vehicles[k], "TakeOutVehicle", k, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
        
    Menu.addButton("Return", "GangGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    XCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        local v = Config.Gangs[PlayerGang.name]["VehicleSpawner"]
        local coords = v.coords
        local primary = v["colours"]["primary"]
        local secondary = v["colours"]["secondary"]
        SetVehicleCustomPrimaryColour(veh, primary.r, primary.g, primary.b)
        SetVehicleCustomSecondaryColour(veh, secondary.r, secondary.g, secondary.b)
        SetEntityHeading(veh, coords.h)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    Menu.hidden = true
    ClearMenu()
end
