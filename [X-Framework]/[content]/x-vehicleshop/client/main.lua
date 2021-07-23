PlayerJob = {}
isLoggedIn = true
local inVehicleShop = false

vehicleCategorys = {
    ["coupes"] = {
        label = "Coupes",
        vehicles = {}
    },
    ["sedans"] = {
        label = "Sedans",
        vehicles = {}
    },
    ["muscle"] = {
        label = "Muscle",
        vehicles = {}
    },
    ["suvs"] = {
        label = "SUVs",
        vehicles = {}
    },
    ["compacts"] = {
        label = "Compacts",
        vehicles = {}
    },
    ["vans"] = {
        label = "Vans",
        vehicles = {}
    },
    ["super"] = {
        label = "Super",
        vehicles = {}
    },
    ["sports"] = {
        label = "Sports",
        vehicles = {}
    },
    ["sportsclassics"] = {
        label = "Sports Classics",
        vehicles = {}
    },
    ["motorcycles"] = {
        label = "Motorcycles",
        vehicles = {}
    },
    ["offroad"] = {
        label = "Offroad",
        vehicles = {}
    },
}

RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
    XCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
    isLoggedIn = true
end)

RegisterNetEvent('XCore:NotifyClient:OnJobUpdate')
AddEventHandler('XCore:NotifyClient:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k, v in pairs(XCore.Shared.Vehicles) do
        if v["shop"] == "pdm" then
            for cat,_ in pairs(vehicleCategorys) do
                if XCore.Shared.Vehicles[k]["category"] == cat then
                    table.insert(vehicleCategorys[cat].vehicles, XCore.Shared.Vehicles[k])
                end
            end
        end
    end
end)

function openVehicleShop(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        ui = bool
    })
end

function setupVehicles(vehs)
    SendNUIMessage({
        action = "setupVehicles",
        vehicles = vehs
    })
end

RegisterNUICallback('GetCategoryVehicles', function(data)
    setupVehicles(shopVehicles[data.selectedCategory])
end)

RegisterNUICallback('exit', function()
    openVehicleShop(false)
end)

RegisterNUICallback('buyVehicle', function(data)
    local vehicleData = data.vehicleData
    local garage = data.garage

    TriggerServerEvent('x-vehicleshop:server:buyVehicle', vehicleData, garage)
    openVehicleShop(false)
end)

RegisterNetEvent('x-vehicleshop:client:spawnBoughtVehicle')
AddEventHandler('x-vehicleshop:client:spawnBoughtVehicle', function(vehicle)
    XCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetEntityHeading(veh, X.SpawnPoint.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end, X.SpawnPoint, true)
end)

Citizen.CreateThread(function()
    Dealer = AddBlipForCoord(X.VehicleShop)
    SetBlipSprite (Dealer, 326)
    SetBlipDisplay(Dealer, 4)
    SetBlipScale  (Dealer, 0.75)
    SetBlipAsShortRange(Dealer, true)
    SetBlipColour(Dealer, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Premium Deluxe Motorsport")
    EndTextCommandSetBlipName(Dealer)
end)
