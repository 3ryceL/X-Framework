-- Variables

local lastSpectateCoord = nil
local isSpectating = false

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

-- Events

RegisterNetEvent('x-admin:client:inventory')
AddEventHandler('x-admin:client:inventory', function(targetPed)
    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPed)
end)

RegisterNetEvent('x-admin:client:spectate')
AddEventHandler('x-admin:client:spectate', function(targetPed, coords)
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false) -- Set invisible
        SetEntityInvincible(myPed, true) -- set godmode
        lastSpectateCoord = GetEntityCoords(myPed) -- save my last coords
        SetEntityCoords(myPed, coords) -- Teleport To Player
        NetworkSetInSpectatorMode(true, target) -- Enter Spectate Mode
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target) -- Remove From Spectate Mode
        SetEntityCoords(myPed, lastSpectateCoord) -- Return Me To My Coords
        SetEntityVisible(myPed, true) -- Remove invisible
        SetEntityInvincible(myPed, false) -- Remove godmode
        lastSpectateCoord = nil -- Reset Last Saved Coords
    end
end)

RegisterNetEvent('x-admin:client:SendReport')
AddEventHandler('x-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('x-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('x-admin:client:SendStaffChat')
AddEventHandler('x-admin:client:SendStaffChat', function(name, msg)
    TriggerServerEvent('x-admin:server:StaffChatMessage', name, msg)
end)

RegisterNetEvent('x-admin:client:SaveCar')
AddEventHandler('x-admin:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        local props = XCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        if XCore.Shared.Vehicles[vehname] ~= nil and next(XCore.Shared.Vehicles[vehname]) ~= nil then
            TriggerServerEvent('x-admin:server:SaveCar', props, XCore.Shared.Vehicles[vehname], `veh`, plate)
        else
            XCore.Functions.Notify('You cant store this vehicle in your garage..', 'error')
        end
    else
        XCore.Functions.Notify('You are not in a vehicle..', 'error')
    end
end)

RegisterNetEvent('x-admin:client:SetModel')
AddEventHandler('x-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = `skin`
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom() then
            SetPedRandomComponentVariation(ped, true)
        end
        
		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

RegisterNetEvent('x-admin:client:SetSpeed')
AddEventHandler('x-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent('x-weapons:client:SetWeaponAmmoManual')
AddEventHandler('x-weapons:client:SetWeaponAmmoManual', function(weapon, ammo)
    local ped = PlayerPedId()
    if weapon ~= "current" then
        local weapon = weapon:upper()
        SetPedAmmo(ped, GetHashKey(weapon), ammo)
        XCore.Functions.Notify('+'..ammo..' Ammo for the '..XCore.Shared.Weapons[GetHashKey(weapon)]["label"], 'success')
    else
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= nil then
            SetPedAmmo(ped, weapon, ammo)
            XCore.Functions.Notify('+'..ammo..' Ammo for the '..XCore.Shared.Weapons[weapon]["label"], 'success')
        else
            XCore.Functions.Notify('You dont have a weapon in your hands..', 'error')
        end
    end
end)

RegisterNetEvent('x-admin:client:GiveNuiFocus')
AddEventHandler('x-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)