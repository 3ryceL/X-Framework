inside = false
closesthouse = nil
hasKey = false
isOwned = false

isLoggedIn = true
local contractOpen = false

local cam = nil
local viewCam = false

local FrontCam = false

stashLocation = nil
outfitLocation = nil
logoutLocation = nil

local OwnedHouseBlips = {}
local CurrentDoorBell = 0
local rangDoorbell = nil
local houseObj = {}
local POIOffsets = nil
local entering = false
local data = nil
local CurrentHouse = nil
local inHoldersMenu = false

RegisterNetEvent('x-houses:client:sellHouse')
AddEventHandler('x-houses:client:sellHouse', function()
    if closesthouse ~= nil and hasKey then
        TriggerServerEvent('x-houses:server:viewHouse', closesthouse)
    end
end)

--------------------------------------------------------------


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        if isLoggedIn then
            if not inside then
                SetClosestHouse()
            end
        end
    end
end)

RegisterNetEvent('x-houses:client:EnterHouse')
AddEventHandler('x-houses:client:EnterHouse', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if closesthouse ~= nil then
        local dist = #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z))
        if dist < 1.5 then
            if hasKey then
                enterOwnedHouse(closesthouse)
            else
                if not Config.Houses[closesthouse].locked then
                    enterNonOwnedHouse(closesthouse)
                end
            end
        end
    end
end)

RegisterNetEvent('x-houses:client:RequestRing')
AddEventHandler('x-houses:client:RequestRing', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if closesthouse ~= nil then
        TriggerServerEvent('x-houses:server:RingDoor', closesthouse)
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    
    TriggerServerEvent('x-houses:client:setHouses')
    isLoggedIn = true
    SetClosestHouse()
    TriggerEvent('x-houses:client:setupHouseBlips')
    Citizen.Wait(100)
    TriggerEvent('x-garages:client:setHouseGarage', closesthouse, hasKey)
    TriggerServerEvent("x-houses:server:setHouses")
end)

function doorText(x, y, z, text)
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.011, -0.025+ factor, 0.03, 0, 0, 0, 68)
    ClearDrawOrigin()
end

RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
    TriggerServerEvent('x-houses:client:setHouses')
    isLoggedIn = true
    SetClosestHouse()
    TriggerEvent('x-houses:client:setupHouseBlips')
    Citizen.Wait(100)
    TriggerEvent('x-garages:client:setHouseGarage', closesthouse, hasKey)
    TriggerServerEvent("x-houses:server:setHouses")
end)

RegisterNetEvent('XCore:NotifyClient:OnPlayerUnload')
AddEventHandler('XCore:NotifyClient:OnPlayerUnload', function()
    isLoggedIn = false
    inside = false
    closesthouse = nil
    hasKey = false
    isOwned = false
    for k, v in pairs(OwnedHouseBlips) do
        RemoveBlip(v)
    end
end)

RegisterNetEvent('x-houses:client:setHouseConfig')
AddEventHandler('x-houses:client:setHouseConfig', function(houseConfig)
    Config.Houses = houseConfig
    --TriggerEvent("x-houses:client:refreshHouse")
end)

RegisterNetEvent('x-houses:client:lockHouse')
AddEventHandler('x-houses:client:lockHouse', function(bool, house)
    Config.Houses[house].locked = bool
end)

RegisterNetEvent('x-houses:client:createHouses')
AddEventHandler('x-houses:client:createHouses', function(price, tier)
    local pos = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street = GetStreetNameFromHashKey(s1)
    local coords = {
        enter 	= { x = pos.x, y = pos.y, z = pos.z, h = heading},
        cam 	= { x = pos.x, y = pos.y, z = pos.z, h = heading, yaw = -10.00},
    }
    street = street:gsub("%-", " ")
    TriggerServerEvent('x-houses:server:addNewHouse', street, coords, price, tier)
end)

RegisterNetEvent('x-houses:client:addGarage')
AddEventHandler('x-houses:client:addGarage', function()
    if closesthouse ~= nil then 
        local pos = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local coords = {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            h = heading,
        }
        TriggerServerEvent('x-houses:server:addGarage', closesthouse, coords)
    else
        XCore.Functions.Notify("No house around..", "error")
    end
end)

RegisterNetEvent('x-houses:client:toggleDoorlock')
AddEventHandler('x-houses:client:toggleDoorlock', function()
    local pos = GetEntityCoords(PlayerPedId())
    local dist = #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z))
    if dist < 1.5 then
        if hasKey then
            if Config.Houses[closesthouse].locked then
                TriggerServerEvent('x-houses:server:lockHouse', false, closesthouse)
                XCore.Functions.Notify("House is unlocked!", "success", 2500)
            else
                TriggerServerEvent('x-houses:server:lockHouse', true, closesthouse)
                XCore.Functions.Notify("House is locked!", "error", 2500)
            end
        else
            XCore.Functions.Notify("You dont have the keys of the house...", "error", 3500)
        end
    else
        XCore.Functions.Notify("There is no door to see??", "error", 3500)
    end
end)

DrawText3Ds = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do

        local pos = GetEntityCoords(PlayerPedId())
        local inRange = false

        if closesthouse ~= nil then
            local dist2 = vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)
            if #(pos.xy - dist2.xy) < 30 then
                inRange = true
                if hasKey then
                    -- ENTER HOUSE
                    if not inside then
                        if closesthouse ~= nil then
                            if #(pos - dist2) < 1.5 then
                                DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, '~b~/enter~w~ - Enter')
                            end
                        end
                    end

                    if CurrentDoorBell ~= 0 then
                        if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                            DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z + 0.35, '~g~G~w~ - Invite In')
                            if IsControlJustPressed(0, 47) then -- G
                                TriggerServerEvent("x-houses:server:OpenDoor", CurrentDoorBell, closesthouse)
                                CurrentDoorBell = 0
                            end
                        end
                    end
                    -- EXIT HOUSE
                    if inside then
                        if not entering then
                            if POIOffsets ~= nil then
                                if POIOffsets.exit ~= nil then
                                    if #(pos - vector3(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                                        DrawText3Ds(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - Leave')
                                        DrawText3Ds(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z - 0.1, '~g~H~w~ - Camera')
                                        if IsControlJustPressed(0, 38) then -- E
                                            leaveOwnedHouse(CurrentHouse)
                                        end
                                        if IsControlJustPressed(0, 74) then -- H
                                            FrontDoorCam(Config.Houses[CurrentHouse].coords.enter)
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if not isOwned then
                        if closesthouse ~= nil then
                            if #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)) < 1.5 then
                                if not viewCam and Config.Houses[closesthouse].locked then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, '~g~E~w~ - View House')
                                    if IsControlJustPressed(0, 38) then -- E
                                        TriggerServerEvent('x-houses:server:viewHouse', closesthouse)
                                    end
                                end
                            end
                        end
                    elseif isOwned then
                        if closesthouse ~= nil then
                            if not inOwned then
                                -- ??
                            elseif inOwned then
                                if POIOffsets ~= nil then
                                    if POIOffsets.exit ~= nil then
                                        if #(pos - vector3(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                                            DrawText3Ds(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - Leave')
                                            if IsControlJustPressed(0, 38) then -- E
                                                leaveNonOwnedHouse(CurrentHouse)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if inside and not isOwned then
                        if not entering then
                            if POIOffsets ~= nil then
                                if POIOffsets.exit ~= nil then
                                    if #(pos - vector3(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z)) < 1.5 then
                                        DrawText3Ds(Config.Houses[CurrentHouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[CurrentHouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[CurrentHouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - Leave')
                                        if IsControlJustPressed(0, 38) then -- E
                                            leaveNonOwnedHouse(CurrentHouse)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                local StashObject = nil
                -- STASH
                if inside then
                    if CurrentHouse ~= nil then
                        if stashLocation ~= nil then
                            if #(pos - vector3(stashLocation.x, stashLocation.y, stashLocation.z)) < 1.5 then
                                DrawText3Ds(stashLocation.x, stashLocation.y, stashLocation.z, '~g~E~w~ - Stash')
                                if IsControlJustPressed(0, 38) then -- E
                                    TriggerServerEvent("inventory:server:OpenInventory", "stash", CurrentHouse)
                                    TriggerEvent("inventory:client:SetCurrentStash", CurrentHouse)
                                end
                            elseif #(pos - vector3(stashLocation.x, stashLocation.y, stashLocation.z)) < 3 then
                                DrawText3Ds(stashLocation.x, stashLocation.y, stashLocation.z, 'Stash')
                            end
                        end
                    end
                end

                if inside then
                    if CurrentHouse ~= nil then
                        if outfitLocation ~= nil then
                            if #(pos - vector3(outfitLocation.x, outfitLocation.y, outfitLocation.z)) < 1.5 then
                                DrawText3Ds(outfitLocation.x, outfitLocation.y, outfitLocation.z, '~g~E~w~ - Outfits')
                                if IsControlJustPressed(0, 38) then -- E
                                    TriggerEvent('x-clothing:client:openOutfitMenu')
                                end
                            elseif #(pos - vector3(outfitLocation.x, outfitLocation.y, outfitLocation.z)) < 3 then
                                DrawText3Ds(outfitLocation.x, outfitLocation.y, outfitLocation.z, 'Outfits')
                            end
                        end
                    end
                end

                if inside then
                    if CurrentHouse ~= nil then
                        if logoutLocation ~= nil then
                            if #(pos - vector3(logoutLocation.x, logoutLocation.y, logoutLocation.z)) < 1.5 then
                                DrawText3Ds(logoutLocation.x, logoutLocation.y, logoutLocation.z, '~g~E~w~ - Change Characters')
                                if IsControlJustPressed(0, 38) then -- E
                                    DoScreenFadeOut(250)
                                    while not IsScreenFadedOut() do
                                        Citizen.Wait(10)
                                    end
                                    exports['x-interior']:DespawnInterior(houseObj, function()
                                        TriggerEvent('x-weathersync:client:EnableSync')
                                        SetEntityCoords(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.x, Config.Houses[CurrentHouse].coords.enter.y, Config.Houses[CurrentHouse].coords.enter.z + 0.5)
                                        SetEntityHeading(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.h)
                                        inOwned = false
                                        inside = false
                                        TriggerServerEvent('x-houses:server:LogoutLocation')
                                    end)
                                end
                            elseif #(pos - vector3(logoutLocation.x, logoutLocation.y, logoutLocation.z)) < 3 then
                                DrawText3Ds(logoutLocation.x, logoutLocation.y, logoutLocation.z, 'Change Characters')
                            end
                        end
                    end
                end
            end
        end
        if not inRange then
            Citizen.Wait(1500)
        end
    
        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if inHoldersMenu then
            Menu.renderGUI()
        end
    end
end)

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(PlayerPedId())
end

RegisterNetEvent('x-houses:client:RingDoor')
AddEventHandler('x-houses:client:RingDoor', function(player, house)
    if closesthouse == house and inside then
        CurrentDoorBell = player
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
        XCore.Functions.Notify("Some one is ringing the door!")
    end
end)

function GetClosestPlayer()
    local closestPlayers = XCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(vector3(pos - vector3(coords)))

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

RegisterNetEvent('x-houses:client:giveHouseKey')
AddEventHandler('x-houses:client:giveHouseKey', function(data)
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 and closesthouse ~= nil then
        local playerId = GetPlayerServerId(player)
        local pedpos = GetEntityCoords(PlayerPedId())
        local housedist = #(pedpos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z))
        
        if housedist < 10 then
            TriggerServerEvent('x-houses:server:giveHouseKey', playerId, closesthouse)
        else
            XCore.Functions.Notify("You'r not close enough to the door..", "error")
        end
    elseif closesthouse == nil then
        XCore.Functions.Notify("There is no house near you", "error")
    else
        XCore.Functions.Notify("No one around!", "error")
    end
end)

RegisterNetEvent('x-houses:client:removeHouseKey')
AddEventHandler('x-houses:client:removeHouseKey', function(data)
    if closesthouse ~= nil then
        local pedpos = GetEntityCoords(PlayerPedId())
        local housedist = #(pedpos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z))
        if housedist < 5 then
            XCore.Functions.TriggerCallback('x-houses:server:getHouseOwner', function(result)
                if XCore.Functions.GetPlayerData().citizenid == result then
                    inHoldersMenu = true
                    HouseKeysMenu()
                    Menu.hidden = not Menu.hidden
                else
                    XCore.Functions.Notify("You're not a house owner..", "error")
                end
            end, closesthouse)
        else
            XCore.Functions.Notify("You'r not close enough to the door..", "error")
        end
    else
        XCore.Functions.Notify("You'r not close enough to the door..", "error")
    end
end)

RegisterNetEvent('x-houses:client:refreshHouse')
AddEventHandler('x-houses:client:refreshHouse', function(data)
    Citizen.Wait(100)
    SetClosestHouse()
    --TriggerEvent('x-garages:client:setHouseGarage', closesthouse, hasKey)
end)

RegisterNetEvent('x-houses:client:SpawnInApartment')
AddEventHandler('x-houses:client:SpawnInApartment', function(house)
    local pos = GetEntityCoords(PlayerPedId())
    if rangDoorbell ~= nil then
        if #(pos - vector3(Config.Houses[house].coords.enter.x, Config.Houses[house].coords.enter.y, Config.Houses[house].coords.enter.z)) > 5 then
            return
        end
    end
    closesthouse = house
    enterNonOwnedHouse(house)
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 

function HouseKeysMenu()
    ped = PlayerPedId();
    MenuTitle = "Sleutels"
    ClearMenu()
    XCore.Functions.TriggerCallback('x-houses:server:getHouseKeyHolders', function(holders)
        ped = PlayerPedId();
        MenuTitle = "Sleutelhouders:"
        ClearMenu()
        if holders == nil or next(holders) == nil then
            XCore.Functions.Notify("No key holders found..", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(holders) do
                Menu.addButton(holders[k].firstname .. " " .. holders[k].lastname, "optionMenu", holders[k]) 
            end
        end
        Menu.addButton("Exit Menu", "closeMenuFull", nil) 
    end, closesthouse)
end

function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function optionMenu(citizenData)
    ped = PlayerPedId();
    MenuTitle = "What now?"
    ClearMenu()
    Menu.addButton("Verwijder sleutel", "removeHouseKey", citizenData) 
    Menu.addButton("Terug", "HouseKeysMenu",nil)
end

function removeHouseKey(citizenData)
    TriggerServerEvent('x-houses:server:removeHouseKey', closesthouse, citizenData)
    closeMenuFull()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    XCore.Functions.Notify(oData.outfitname.." Is removed", "success", 2500)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    inHoldersMenu = false
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function openContract(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "toggle",
        status = bool,
    })
    contractOpen = bool
end

function enterOwnedHouse(house)
    CurrentHouse = house
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    inside = true
    Citizen.Wait(250)
    local coords = { x = Config.Houses[house].coords.enter.x, y = Config.Houses[house].coords.enter.y, z= Config.Houses[house].coords.enter.z - Config.MinZOffset}
    LoadDecorations(house)
    
    if Config.Houses[house].tier == 1 then
        data = exports['x-interior']:CreateTier1House(coords)
    elseif Config.Houses[house].tier == 2 then
        data = exports['x-interior']:CreateTrevorsShell(coords)
    elseif Config.Houses[house].tier == 3 then
        data = exports['x-interior']:CreateMichaelShell(coords)
    elseif Config.Houses[house].tier == 4 then
        data = exports['x-interior']:CreateApartmentShell(coords)
    elseif Config.Houses[house].tier == 5 then
        data = exports['x-interior']:CreateCaravanShell(coords)
    elseif Config.Houses[house].tier == 6 then
        data = exports['x-interior']:CreateFranklinShell(coords)
    elseif Config.Houses[house].tier == 7 then
        data = exports['x-interior']:CreateFranklinAuntShell(coords)
    end

    Citizen.Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    entering = true
    TriggerServerEvent('x-houses:server:SetInsideMeta', house, true)
    Citizen.Wait(500)
    SetRainLevel(0.0)
    TriggerEvent('x-weathersync:client:DisableSync')
    TriggerEvent('x-weed:client:getHousePlants', house)
    Citizen.Wait(100)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    entering = false
    setHouseLocations()
end

RegisterNetEvent('x-houses:client:enterOwnedHouse')
AddEventHandler('x-houses:client:enterOwnedHouse', function(house)
    XCore.Functions.GetPlayerData(function(PlayerData)
		if PlayerData.metadata["injail"] == 0 then
			enterOwnedHouse(house)
		end
	end)
end)

RegisterNUICallback('HasEnoughMoney', function(data, cb)
    XCore.Functions.TriggerCallback('x-houses:server:HasEnoughMoney', function(hasEnough)
        
    end, data.objectData)
end)

RegisterNetEvent('x-houses:client:LastLocationHouse')
AddEventHandler('x-houses:client:LastLocationHouse', function(houseId)
    XCore.Functions.GetPlayerData(function(PlayerData)
		if PlayerData.metadata["injail"] == 0 then
			enterOwnedHouse(houseId)
		end
	end)
end)

function leaveOwnedHouse(house)
    if not FrontCam then
        inside = false
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
        openHouseAnim()
        Citizen.Wait(250)
        DoScreenFadeOut(250)
        Citizen.Wait(500)
        exports['x-interior']:DespawnInterior(houseObj, function()
            UnloadDecorations()
            TriggerEvent('x-weathersync:client:EnableSync')
            Citizen.Wait(250)
            DoScreenFadeIn(250)
            SetEntityCoords(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.x, Config.Houses[CurrentHouse].coords.enter.y, Config.Houses[CurrentHouse].coords.enter.z + 0.2)
            SetEntityHeading(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.h)
            TriggerEvent('x-weed:client:leaveHouse')
            TriggerServerEvent('x-houses:server:SetInsideMeta', house, false)
            CurrentHouse = nil
        end)
    end
end

function enterNonOwnedHouse(house)
    CurrentHouse = house
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    inside = true
    Citizen.Wait(250)
    local coords = { x = Config.Houses[closesthouse].coords.enter.x, y = Config.Houses[closesthouse].coords.enter.y, z= Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset}
    LoadDecorations(house)

    if Config.Houses[house].tier == 1 then
        data = exports['x-interior']:CreateTier1House(coords)
    elseif Config.Houses[house].tier == 2 then
        data = exports['x-interior']:CreateTrevorsShell(coords)
    elseif Config.Houses[house].tier == 3 then
        data = exports['x-interior']:CreateMichaelShell(coords)
    elseif Config.Houses[house].tier == 4 then
        data = exports['x-interior']:CreateApartmentShell(coords)
    elseif Config.Houses[house].tier == 5 then
        data = exports['x-interior']:CreateCaravanShell(coords)
    elseif Config.Houses[house].tier == 6 then
        data = exports['x-interior']:CreateFranklinShell(coords)
    elseif Config.Houses[house].tier == 7 then
        data = exports['x-interior']:CreateFranklinAuntShell(coords)
    end

    houseObj = data[1]
    POIOffsets = data[2]
    entering = true
    Citizen.Wait(500)
    SetRainLevel(0.0)
    TriggerServerEvent('x-houses:server:SetInsideMeta', house, true)
    TriggerEvent('x-weathersync:client:DisableSync')
    TriggerEvent('x-weed:client:getHousePlants', house)
    Citizen.Wait(100)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    entering = false
    inOwned = true
    setHouseLocations()
end

function leaveNonOwnedHouse(house)
    if not FrontCam then
        inside = false
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
        openHouseAnim()
        Citizen.Wait(250)
        DoScreenFadeOut(250)
        Citizen.Wait(500)
        exports['x-interior']:DespawnInterior(houseObj, function()
            UnloadDecorations()
            TriggerEvent('x-weathersync:client:EnableSync')
            Citizen.Wait(250)
            DoScreenFadeIn(250)
            SetEntityCoords(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.x, Config.Houses[CurrentHouse].coords.enter.y, Config.Houses[CurrentHouse].coords.enter.z + 0.2)
            SetEntityHeading(PlayerPedId(), Config.Houses[CurrentHouse].coords.enter.h)
            inOwned = false
            TriggerEvent('x-weed:client:leaveHouse')
            TriggerServerEvent('x-houses:server:SetInsideMeta', house, false)
            CurrentHouse = nil
        end)
    end
end

RegisterNetEvent('x-houses:client:setupHouseBlips')
AddEventHandler('x-houses:client:setupHouseBlips', function()
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        if isLoggedIn then
            XCore.Functions.TriggerCallback('x-houses:server:getOwnedHouses', function(ownedHouses)
                if ownedHouses ~= nil then
                    for k, v in pairs(ownedHouses) do
                        local house = Config.Houses[ownedHouses[k]]
                        HouseBlip = AddBlipForCoord(house.coords.enter.x, house.coords.enter.y, house.coords.enter.z)

                        SetBlipSprite (HouseBlip, 40)
                        SetBlipDisplay(HouseBlip, 4)
                        SetBlipScale  (HouseBlip, 0.65)
                        SetBlipAsShortRange(HouseBlip, true)
                        SetBlipColour(HouseBlip, 3)

                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentSubstringPlayerName(house.adress)
                        EndTextCommandSetBlipName(HouseBlip)

                        table.insert(OwnedHouseBlips, HouseBlip)
                    end
                end
            end)
        end
    end)
end)

RegisterNetEvent('x-houses:client:SetClosestHouse')
AddEventHandler('x-houses:client:SetClosestHouse', function()
    SetClosestHouse()
end)

function setViewCam(coords, h, yaw)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, yaw, 0.00, h, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    viewCam = true
end

function FrontDoorCam(coords)
    DoScreenFadeOut(150)
    Citizen.Wait(500)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z + 0.5, 0.0, 0.00, coords.h - 180, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    FrontCam = true
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(500)
    DoScreenFadeIn(150)
    SendNUIMessage({
        type = "frontcam",
        toggle = true,
        label = Config.Houses[closesthouse].adress
    })
    Citizen.CreateThread(function()
        while FrontCam do

            local instructions = CreateInstuctionScaleform("instructional_buttons")
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
            SetTimecycleModifier("scanline_cam_cheap")
            SetTimecycleModifierStrength(1.0)

            if IsControlJustPressed(1, 194) then -- Backspace
                DoScreenFadeOut(150)
                SendNUIMessage({
                    type = "frontcam",
                    toggle = false,
                })
                Citizen.Wait(500)
                RenderScriptCams(false, true, 500, true, true)
                FreezeEntityPosition(PlayerPedId(), false)
                SetCamActive(cam, false)
                DestroyCam(cam, true)
                ClearTimecycleModifier("scanline_cam_cheap")
                cam = nil
                FrontCam = false
                Citizen.Wait(500)
                DoScreenFadeIn(150)
            end

            local getCameraRot = GetCamRot(cam, 2)

            -- ROTATE UP
            if IsControlPressed(0, 32) then -- W
                if getCameraRot.x <= 0.0 then
                    SetCamRot(cam, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
                end
            end

            -- ROTATE DOWN
            if IsControlPressed(0, 33) then -- S
                if getCameraRot.x >= -50.0 then
                    SetCamRot(cam, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
                end
            end

            -- ROTATE LEFT
            if IsControlPressed(0, 34) then -- A
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
            end

            -- ROTATE RIGHT
            if IsControlPressed(0, 35) then -- D
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
            end

            Citizen.Wait(1)
        end
    end)
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 194, true))
    InstructionButtonMessage("Exit Camera")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function disableViewCam()
    if viewCam then
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        viewCam = false
    end
end

RegisterNUICallback('buy', function()
    openContract(false)
    disableViewCam()
    TriggerServerEvent('x-houses:server:buyHouse', closesthouse)
end)

RegisterNUICallback('exit', function()
    openContract(false)
    disableViewCam()
end)

RegisterNetEvent('x-houses:client:viewHouse')
AddEventHandler('x-houses:client:viewHouse', function(houseprice, brokerfee, bankfee, taxes, firstname, lastname)
    setViewCam(Config.Houses[closesthouse].coords.cam, Config.Houses[closesthouse].coords.cam.h, Config.Houses[closesthouse].coords.yaw)
    Citizen.Wait(500)
    openContract(true)
    SendNUIMessage({
        type = "setupContract",
        firstname = firstname,
        lastname = lastname,
        street = Config.Houses[closesthouse].adress,
        houseprice = houseprice,
        brokerfee = brokerfee,
        bankfee = bankfee,
        taxes = taxes,
        totalprice = (houseprice + brokerfee + bankfee + taxes)
    })
end)

function SetClosestHouse()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    if not inside then
        for id, house in pairs(Config.Houses) do
            local distcheck = #(pos - vector3(Config.Houses[id].coords.enter.x, Config.Houses[id].coords.enter.y, Config.Houses[id].coords.enter.z))
            if current ~= nil then
                if distcheck < dist then
                    current = id
                    dist = distcheck
                end
            else
                dist = distcheck
                current = id
            end
        end
        closesthouse = current
    
        if closesthouse ~= nil and tonumber(dist) < 30 then 
            XCore.Functions.TriggerCallback('x-houses:server:ProximityKO', function(key, owned)
                hasKey = key
                isOwned = owned
            end, closesthouse)
        end
    end
    TriggerEvent('x-garages:client:setHouseGarage', closesthouse, hasKey)
end

function setHouseLocations()
    if closesthouse ~= nil then
        XCore.Functions.TriggerCallback('x-houses:server:getHouseLocations', function(result)
            if result ~= nil then
                if result.stash ~= nil then
                    stashLocation = json.decode(result.stash)
                end

                if result.outfit ~= nil then
                    outfitLocation = json.decode(result.outfit)
                end

                if result.logout ~= nil then
                    logoutLocation = json.decode(result.logout)
                end
            end
        end, closesthouse)
    end
end

RegisterNetEvent('x-houses:client:setLocation')
AddEventHandler('x-houses:client:setLocation', function(data)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local coords = {x = pos.x, y = pos.y, z = pos.z}

    if inside then
        if hasKey then
            if data.id == 'setstash' then
                TriggerServerEvent('x-houses:server:setLocation', coords, closesthouse, 1)
            elseif data.id == 'setoutift' then
                TriggerServerEvent('x-houses:server:setLocation', coords, closesthouse, 2)
            elseif data.id == 'setlogout' then
                TriggerServerEvent('x-houses:server:setLocation', coords, closesthouse, 3)
            end
        else
            XCore.Functions.Notify('You Do Not Own This House', 'error')
        end
    else    
        XCore.Functions.Notify('You Are Not In A House', 'error')
    end
end)

RegisterNetEvent('x-houses:client:refreshLocations')
AddEventHandler('x-houses:client:refreshLocations', function(house, location, type)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if closesthouse == house then
        if inside then
            if type == 1 then
                stashLocation = json.decode(location)
            elseif type == 2 then
                outfitLocation = json.decode(location)
            elseif type == 3 then
                logoutLocation = json.decode(location)
            end
        end
    end
end)

local RamsDone = 0

function DoRamAnimation(bool)
    local ped = PlayerPedId()
    local dict = "missheistfbi3b_ig7"
    local anim = "lift_fibagent_loop"

    if bool then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(1)
        end
        TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 1, -1, false, false, false)
    else
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(1)
        end
        TaskPlayAnim(ped, dict, "exit", 8.0, 8.0, -1, 1, -1, false, false, false)
    end
end

RegisterNetEvent('x-houses:client:HomeInvasion')
AddEventHandler('x-houses:client:HomeInvasion', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local Skillbar = exports['x-skillbar']:GetSkillbarObject()

    if closesthouse ~= nil then
        XCore.Functions.TriggerCallback('police:server:IsPoliceForcePresent', function(IsPresent)
            if IsPresent then
                local dist = #(pos - vector3(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z))
                if Config.Houses[closesthouse].IsRaming == nil then
                    Config.Houses[closesthouse].IsRaming = false
                end
        
                if dist < 1 then
                    if Config.Houses[closesthouse].locked then
                        if not Config.Houses[closesthouse].IsRaming then
                            DoRamAnimation(true)
                            Skillbar.Start({
                                duration = math.random(5000, 10000),
                                pos = math.random(10, 30),
                                width = math.random(10, 20),
                            }, function()
                                if RamsDone + 1 >= Config.RamsNeeded then
                                    TriggerServerEvent('x-houses:server:lockHouse', false, closesthouse)
                                    XCore.Functions.Notify('It worked the door is now out.', 'success')
                                    TriggerServerEvent('x-houses:server:SetHouseRammed', true, closesthouse)
                                    DoRamAnimation(false)
                                else
                                    DoRamAnimation(true)
                                    Skillbar.Repeat({
                                        duration = math.random(500, 1000),
                                        pos = math.random(10, 30),
                                        width = math.random(5, 12),
                                    })
                                    RamsDone = RamsDone + 1
                                end
                            end, function()
                                RamsDone = 0
                                TriggerServerEvent('x-houses:server:SetRamState', false, closesthouse)
                                XCore.Functions.Notify('It faild try again.', 'error')
                                DoRamAnimation(false)
                            end)
                            TriggerServerEvent('x-houses:server:SetRamState', true, closesthouse)
                        else
                            XCore.Functions.Notify('Er is al iemand bezig met de deur..', 'error')
                        end
                    else
                        XCore.Functions.Notify('19/5000 This house is already open..', 'error')
                    end
                else
                    XCore.Functions.Notify('You\'re not near a house..', 'error')
                end
            else
                XCore.Functions.Notify('There is no police force present..', 'error')
            end
        end)
    else
        XCore.Functions.Notify('You\'re not near a house..', 'error')
    end
end)

RegisterNetEvent('x-houses:client:SetRamState')
AddEventHandler('x-houses:client:SetRamState', function(bool, house)
    Config.Houses[house].IsRaming = bool
end)

RegisterNetEvent('x-houses:client:SetHouseRammed')
AddEventHandler('x-houses:client:SetHouseRammed', function(bool, house)
    Config.Houses[house].IsRammed = bool
end)

RegisterNetEvent('x-houses:client:ResetHouse')
AddEventHandler('x-houses:client:ResetHouse', function()
    local ped = PlayerPedId()

    if closesthouse ~= nil then
        if Config.Houses[closesthouse].IsRammed == nil then
            Config.Houses[closesthouse].IsRammed = false
            TriggerServerEvent('x-houses:server:SetHouseRammed', false, closesthouse)
            TriggerServerEvent('x-houses:server:SetRamState', false, closesthouse)
        end
        if Config.Houses[closesthouse].IsRammed then
            openHouseAnim()
            TriggerServerEvent('x-houses:server:SetHouseRammed', false, closesthouse)
            TriggerServerEvent('x-houses:server:SetRamState', false, closesthouse)
            TriggerServerEvent('x-houses:server:lockHouse', true, closesthouse)
            RamsDone = 0
            XCore.Functions.Notify('You locked the house again..', 'success')
        else
            XCore.Functions.Notify('This door is not broken open  ..', 'error')
        end
    end
end)
