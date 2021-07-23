-- AFK Kick Time Limit (in seconds)
secondsUntilKick = 1800

local group = "user"
local isLoggedIn = false

RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
    XCore.Functions.TriggerCallback('x-afkkick:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
    isLoggedIn = true
end)

RegisterNetEvent('XCore:NotifyClient:OnPermissionUpdate')
AddEventHandler('XCore:NotifyClient:OnPermissionUpdate', function(UserGroup)
    group = UserGroup
end)

-- Code
Citizen.CreateThread(function()
	while true do
		Wait(1000)
        playerPed = PlayerPedId()
        if isLoggedIn then
            if group == "user" then
                currentPos = GetEntityCoords(playerPed, true)
                if prevPos ~= nil then
                    if currentPos == prevPos then
                        if time ~= nil then
                            if time > 0 then
                                if time == (900) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (600) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (300) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (150) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)   
                                elseif time == (60) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minute!', 'error', 10000) 
                                elseif time == (30) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)  
                                elseif time == (20) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)    
                                elseif time == (10) then
                                    XCore.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)                                                                                                            
                                end
                                time = time - 1
                            else
                                TriggerServerEvent("KickForAFK")
                            end
                        else
                            time = secondsUntilKick
                        end
                    else
                        time = secondsUntilKick
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)