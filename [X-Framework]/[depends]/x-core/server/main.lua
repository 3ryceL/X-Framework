XCore = {}
XCore.Config = XConfig
XCore.Shared = XShared
XCore.ServerCallbacks = {}
XCore.UseableItems = {}

function GetCoreObject()
	return XCore
end

RegisterServerEvent('XCore:NotifyGetObject')
AddEventHandler('XCore:NotifyGetObject', function(cb)
	cb(GetCoreObject())
end)