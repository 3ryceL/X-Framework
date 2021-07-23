isLoggedIn = false
PlayerJob = {}

RegisterNetEvent("XCore:NotifyClient:OnPlayerLoaded")
AddEventHandler("XCore:NotifyClient:OnPlayerLoaded", function()
    XCore.Functions.TriggerCallback('x-diving:server:GetBusyDocks', function(Docks)
        XBoatshop.Locations["berths"] = Docks
    end)

    XCore.Functions.TriggerCallback('x-diving:server:GetDivingConfig', function(Config, Area)
        XDiving.Locations = Config
        TriggerEvent('x-diving:client:SetDivingLocation', Area)
    end)

    PlayerJob = XCore.Functions.GetPlayerData().job

    isLoggedIn = true

    if PlayerJob.name == "police" then
        if PoliceBlip ~= nil then
            RemoveBlip(PoliceBlip)
        end
        PoliceBlip = AddBlipForCoord(XBoatshop.PoliceBoat.x, XBoatshop.PoliceBoat.y, XBoatshop.PoliceBoat.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
        PoliceBlip = AddBlipForCoord(XBoatshop.PoliceBoat2.x, XBoatshop.PoliceBoat2.y, XBoatshop.PoliceBoat2.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
    end
end)

-- Code

DrawText3D = function(x, y, z, text)
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

RegisterNetEvent('x-diving:client:UseJerrycan')
AddEventHandler('x-diving:client:UseJerrycan', function()
    local ped = PlayerPedId()
    local boat = IsPedInAnyBoat(ped)
    if boat then
        local curVeh = GetVehiclePedIsIn(ped, false)
        XCore.Functions.Progressbar("reful_boat", "Refueling boat ..", 20000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            exports['LegacyFuel']:SetFuel(curVeh, 100)
            XCore.Functions.Notify('The boat has been refueled', 'success')
            TriggerServerEvent('x-diving:server:RemoveItem', 'jerry_can', 1)
            TriggerEvent('inventory:client:ItemBox', XCore.Shared.Items['jerry_can'], "remove")
        end, function() -- Cancel
            XCore.Functions.Notify('Refueling has been canceled!', 'error')
        end)
    else
        XCore.Functions.Notify('You are not in a boat', 'error')
    end
end)
