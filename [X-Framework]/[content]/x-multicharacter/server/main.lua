RegisterServerEvent('x-multicharacter:server:disconnect')
AddEventHandler('x-multicharacter:server:disconnect', function()
    local src = source

    DropPlayer(src, "You have disconnected from x Roleplay")
end)

RegisterServerEvent('x-multicharacter:server:loadUserData')
AddEventHandler('x-multicharacter:server:loadUserData', function(cData)
    local src = source
    if XCore.Player.Login(src, cData.citizenid) then
        print('^2[x-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        XCore.Commands.Refresh(src)
        loadHouseData()
		--TriggerEvent('XCore:NotifyServer:OnPlayerLoaded')-
        --TriggerClientEvent('XCore:NotifyClient:OnPlayerLoaded', src)
        
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("x-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterServerEvent('x-multicharacter:server:createCharacter')
AddEventHandler('x-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    --XCore.Player.CreateCharacter(src, data)
    if XCore.Player.Login(src, false, newData) then
        print('^2[x-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        XCore.Commands.Refresh(src)
        loadHouseData()

        TriggerClientEvent("x-multicharacter:client:closeNUI", src)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        GiveStarterItems(src)
	end
end)

function GiveStarterItems(source)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)

    for k, v in pairs(XCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

RegisterServerEvent('x-multicharacter:server:deleteCharacter')
AddEventHandler('x-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    XCore.Player.DeleteCharacter(src, citizenid)
end)

XCore.Functions.CreateCallback("x-multicharacter:server:GetUserCharacters", function(source, cb)
    local license = XCore.Functions.GetIdentifier(source, 'license')

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE license=@license', {['@license'] = license}, function(result)
        cb(result)
    end)
end)

XCore.Functions.CreateCallback("x-multicharacter:server:GetServerLogs", function(source, cb)
    exports['ghmattimysql']:execute('SELECT * FROM server_logs', function(result)
        cb(result)
    end)
end)

XCore.Functions.CreateCallback("test:yeet", function(source, cb)
    local license = XCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    
    exports['ghmattimysql']:execute('SELECT * FROM players WHERE license = @license', {['@license'] = license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)
end)

XCore.Commands.Add("logout", "Logout of Character (Admin Only)", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
    XCore.Player.Logout(source)
    TriggerClientEvent('x-multicharacter:client:chooseChar', source)
end, "admin")

XCore.Commands.Add("closeNUI", "Close Multi NUI", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
    TriggerClientEvent('x-multicharacter:client:closeNUI', source)
end)

XCore.Functions.CreateCallback("x-multicharacter:server:getSkin", function(source, cb, cid)
    local src = source

    exports.ghmattimysql:execute('SELECT * FROM playerskins WHERE citizenid=@citizenid AND active=@active', {['@citizenid'] = cid, ['@active'] = 1}, function(result)
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    end)
end)

function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
	exports.ghmattimysql:execute('SELECT * FROM houselocations', function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				local garage = v.garage ~= nil and json.decode(v.garage) or {}
				Houses[v.name] = {
					coords = json.decode(v.coords),
					owned = v.owned,
					price = v.price,
					locked = true,
					adress = v.label, 
					tier = v.tier,
					garage = garage,
					decorations = {},
				}
				HouseGarages[v.name] = {
					label = v.label,
					takeVehicle = garage,
				}
			end
		end
		TriggerClientEvent("x-garages:client:houseGarageConfig", -1, HouseGarages)
		TriggerClientEvent("x-houses:client:setHouseConfig", -1, Houses)
	end)
end