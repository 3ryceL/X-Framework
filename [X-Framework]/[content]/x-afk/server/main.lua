RegisterServerEvent("KickForAFK")
AddEventHandler("KickForAFK", function()
	DropPlayer(source, "You Have Been Kicked For Being AFK")
end)

XCore.Functions.CreateCallback('x-afkkick:server:GetPermissions', function(source, cb)
    local group = XCore.Functions.GetPermission(source)
    cb(group)
end)