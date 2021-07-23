RegisterServerEvent("x-clothing:saveSkin")
AddEventHandler('x-clothing:saveSkin', function(model, skin)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    if model ~= nil and skin ~= nil then 
        exports.ghmattimysql:execute('DELETE FROM playerskins WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid}, function()
            exports.ghmattimysql:execute('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (@citizenid, @model, @skin, @active)', {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@model'] = model,
                ['@skin'] = skin,
                ['@active'] = 1
            })
        end)
    end
end)

RegisterServerEvent("x-clothes:loadPlayerSkin")
AddEventHandler('x-clothes:loadPlayerSkin', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM playerskins WHERE citizenid=@citizenid AND active=@active', {['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1}, function(result)
        if result[1] ~= nil then
            TriggerClientEvent("x-clothes:loadSkin", src, false, result[1].model, result[1].skin)
        else
            TriggerClientEvent("x-clothes:loadSkin", src, true)
        end
    end)
end)

RegisterServerEvent("x-clothes:saveOutfit")
AddEventHandler("x-clothes:saveOutfit", function(outfitName, model, skinData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = "outfit-"..math.random(1, 10).."-"..math.random(1111, 9999)
        exports.ghmattimysql:execute('INSERT INTO player_outfits (citizenid, outfitname, model, skin, outfitId) VALUES (@citizenid, @outfitname, @model, @skin, @outfitId)', {
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@outfitname'] = outfitName,
            ['@model'] = model,
            ['@skin'] = json.encode(skinData),
            ['@outfitId'] = outfitId
        }, function()
            exports.ghmattimysql:execute('SELECT * FROM player_outfits WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid}, function(result)
                if result[1] ~= nil then
                    TriggerClientEvent('x-clothing:client:reloadOutfits', src, result)
                else
                    TriggerClientEvent('x-clothing:client:reloadOutfits', src, nil)
                end
            end)
        end)
    end
end)

RegisterServerEvent("x-clothing:server:removeOutfit")
AddEventHandler("x-clothing:server:removeOutfit", function(outfitName, outfitId)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('DELETE FROM player_outfits WHERE citizenid=@citizenid AND outfitname=@outfitname AND outfitId=@outfitId', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@outfitname'] = outfitName,
        ['@outfitId'] = outfitId
    }, function()
        exports.ghmattimysql:execute('SELECT * FROM player_outfits WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid}, function(result)
            if result[1] ~= nil then
                TriggerClientEvent('x-clothing:client:reloadOutfits', src, result)
            else
                TriggerClientEvent('x-clothing:client:reloadOutfits', src, nil)
            end
        end)
    end)
end)

XCore.Functions.CreateCallback('x-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local anusVal = {}

    exports.ghmattimysql:execute('SELECT * FROM player_outfits WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                result[k].skin = json.decode(result[k].skin)
                anusVal[k] = v
            end
            cb(anusVal)
        end
        cb(anusVal)
    end)
end)