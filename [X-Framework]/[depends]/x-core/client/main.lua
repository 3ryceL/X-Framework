XCore = {}
XCore.PlayerData = {}
XCore.Config = XConfig
XCore.Shared = XShared
XCore.ServerCallbacks = {}

isLoggedIn = false

function GetCoreObject()
	return XCore
end

RegisterNetEvent('XCore:NotifyGetObject')
AddEventHandler('XCore:NotifyGetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
    	SetCanAttackFriendly(PlayerPedId(), true, false)
    	NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('XCore:NotifyClient:OnPlayerUnload')
AddEventHandler('XCore:NotifyClient:OnPlayerUnload', function()
    isLoggedIn = false
end)
