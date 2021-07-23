local keyPressed = false
local isLoggedIn = false

local inKeyBinding = false
local availableKeys = {
    {289, "F2"},
    {170, "F3"},
    {166, "F5"},
    {167, "F6"},
    {168, "F7"},
    {56, "F9"},
    {57, "F10"},
}

RegisterNetEvent("XCore:NotifyClient:OnPlayerUnload")
AddEventHandler("XCore:NotifyClient:OnPlayerUnload", function()
    isLoggedIn = false
end)

RegisterNetEvent("XCore:NotifyClient:OnPlayerLoaded")
AddEventHandler("XCore:NotifyClient:OnPlayerLoaded", function()
    isLoggedIn = true
end)

function openBindingMenu()
    local PlayerData = XCore.Functions.GetPlayerData()
    local keyMeta = PlayerData.metadata["commandbinds"]
    SendNUIMessage({
        action = "openBinding",
        keyData = keyMeta
    })
    inKeyBinding = true
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
end

function closeBindingMenu()
    inKeyBinding = false
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', closeBindingMenu)

RegisterNetEvent('x-commandbinding:client:openUI')
AddEventHandler('x-commandbinding:client:openUI', function()
    openBindingMenu()
end)

Citizen.CreateThread(function()
    while true do

        if isLoggedIn then
            for k, v in pairs(availableKeys) do
                if IsControlJustPressed(0, v[1]) or IsDisabledControlJustPressed(0, v[1]) then
                    local keyMeta = XCore.Functions.GetPlayerData().metadata["commandbinds"]
                    local args = {}
                    if next(keyMeta) ~= nil then
                        if keyMeta[v[2]]["command"] ~= "" then
                            if keyMeta[v[2]]["argument"] ~= "" then args = {[1] = keyMeta[v[2]]["argument"]} else args = {[1] = nil} end
                            TriggerServerEvent('XCore:NotifyCallCommand', keyMeta[v[2]]["command"], args)
                            keyPressed = true
                        else
                            XCore.Functions.Notify('There is still nothing ['..v[2]..'] bound, /binds to bind a command', 'primary', 4000)
                        end
                    else
                        XCore.Functions.Notify('You have not bound any commands, /binds to bind a command', 'primary', 4000)
                    end
                end
            end

            if keyPressed then
                Citizen.Wait(1000)
                keyPressed = false
            end
        else
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

RegisterNUICallback('save', function(data)
    local keyData = {
        ["F2"]  = {["command"] = data.keyData["F2"][1],  ["argument"] = data.keyData["F2"][2]},
        ["F3"]  = {["command"] = data.keyData["F3"][1],  ["argument"] = data.keyData["F3"][2]},
        ["F5"]  = {["command"] = data.keyData["F5"][1],  ["argument"] = data.keyData["F5"][2]},
        ["F6"]  = {["command"] = data.keyData["F6"][1],  ["argument"] = data.keyData["F6"][2]},
        ["F7"]  = {["command"] = data.keyData["F7"][1],  ["argument"] = data.keyData["F7"][2]},
        ["F9"]  = {["command"] = data.keyData["F9"][1],  ["argument"] = data.keyData["F9"][2]},
        ["F10"] = {["command"] = data.keyData["F10"][1], ["argument"] = data.keyData["F10"][2]},
    }

    XCore.Functions.Notify('Command bindings have been saved!', 'success')

    TriggerServerEvent('x-commandbinding:server:setKeyMeta', keyData)
end)
