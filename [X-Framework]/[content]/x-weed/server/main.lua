XCore.Functions.CreateCallback('x-weed:server:getBuildingPlants', function(source, cb, building)
    local buildingPlants = {}

    exports['ghmattimysql']:execute('SELECT * FROM house_plants WHERE building = @building', {['@building'] = building}, function(plants)
        for i = 1, #plants, 1 do
            table.insert(buildingPlants, plants[i])
        end

        if buildingPlants ~= nil then
            cb(buildingPlants)
        else    
            cb(nil)
        end
    end)
end)

RegisterServerEvent('x-weed:server:placePlant')
AddEventHandler('x-weed:server:placePlant', function(coords, sort, currentHouse)
    local random = math.random(1, 2)
    local gender
    if random == 1 then gender = "man" else gender = "woman" end
    exports.ghmattimysql:execute('INSERT INTO house_plants (building, coords, gender, sort, plantid) VALUES (@building, @coords, @gender, @sort, @plantid)', {
        ['@building'] = currentHouse,
        ['@coords'] = coords,
        ['@gender'] = gender,
        ['@sort'] = sort,
        ['@plantid'] = math.random(111111,999999)
    })
    TriggerClientEvent('x-weed:client:refreshHousePlants', -1, currentHouse)
end)

RegisterServerEvent('x-weed:server:removeDeathPlant')
AddEventHandler('x-weed:server:removeDeathPlant', function(building, plantId)
    XCore.Functions.ExecuteSql(true, "DELETE FROM `house_plants` WHERE plantid = '"..plantId.."' AND building = '"..building.."'")
    TriggerClientEvent('x-weed:client:refreshHousePlants', -1, building)
end)

Citizen.CreateThread(function()
    while true do
        exports.ghmattimysql:execute('SELECT * FROM house_plants', function(housePlants)
            for k, v in pairs(housePlants) do
                if housePlants[k].food >= 50 then
                    exports.ghmattimysql:execute('UPDATE house_plants SET food=@food WHERE plantid=@plantid', {['@food'] = (housePlants[k].food - 1), ['@plantid'] = housePlants[k].plantid})
                    if housePlants[k].health + 1 < 100 then
                        exports.ghmattimysql:execute('UPDATE house_plants SET health=@health WHERE plantid=@plantid', {['@health'] = (housePlants[k].health + 1), ['@plantid'] = housePlants[k].plantid})
                    end
                end

                if housePlants[k].food < 50 then
                    if housePlants[k].food - 1 >= 0 then
                        exports.ghmattimysql:execute('UPDATE house_plants SET food=@food WHERE plantid=@plantid', {['@food'] = (housePlants[k].food - 1), ['@plantid'] = housePlants[k].plantid})
                    end
                    if housePlants[k].health - 1 >= 0 then
                        exports.ghmattimysql:execute('UPDATE house_plants SET health=@health WHERE plantid=@plantid', {['@health'] = (housePlants[k].health - 1), ['@plantid'] = housePlants[k].plantid})
                    end
                end
            end

            TriggerClientEvent('x-weed:client:refreshPlantStats', -1)
        end)

        Citizen.Wait((60 * 1000) * 19.2)
    end
end)

Citizen.CreateThread(function()
    while true do
        exports.ghmattimysql:execute('SELECT * FROM house_plants', function(housePlants)
            for k, v in pairs(housePlants) do
                if housePlants[k].health > 50 then
                    local Grow = math.random(1, 3)
                    if housePlants[k].progress + Grow < 100 then
                        exports.ghmattimysql:execute('UPDATE house_plants SET progress=@progress WHERE plantid=@plantid', {['@progress'] = (housePlants[k].progress + 1), ['@plantid'] = housePlants[k].plantid})
                    elseif housePlants[k].progress + Grow >= 100 then
                        if housePlants[k].stage ~= XWeed.Plants[housePlants[k].sort]["highestStage"] then
                            if housePlants[k].stage == "stage-a" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-b', ['@plantid'] = housePlants[k].plantid})
                            elseif housePlants[k].stage == "stage-b" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-c', ['@plantid'] = housePlants[k].plantid})
                            elseif housePlants[k].stage == "stage-c" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-d', ['@plantid'] = housePlants[k].plantid})
                            elseif housePlants[k].stage == "stage-d" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-e', ['@plantid'] = housePlants[k].plantid})
                            elseif housePlants[k].stage == "stage-e" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-f', ['@plantid'] = housePlants[k].plantid})
                            elseif housePlants[k].stage == "stage-f" then
                                exports.ghmattimysql:execute('UPDATE house_plants SET stage=@stage WHERE plantid=@plantid', {['@stage'] = 'stage-g', ['@plantid'] = housePlants[k].plantid})
                            end
                            exports.ghmattimysql:execute('UPDATE house_plants SET progress=@progress WHERE plantid=@plantid', {['@progress'] = 0, ['@plantid'] = housePlants[k].plantid})
                        end
                    end
                end
            end

            TriggerClientEvent('x-weed:client:refreshPlantStats', -1)
        end)

        Citizen.Wait((60 * 1000) * 9.6)
    end
end)

XCore.Functions.CreateUseableItem("weed_white-widow_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'white-widow', item)
end)

XCore.Functions.CreateUseableItem("weed_skunk_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'skunk', item)
end)

XCore.Functions.CreateUseableItem("weed_purple-haze_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'purple-haze', item)
end)

XCore.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'og-kush', item)
end)

XCore.Functions.CreateUseableItem("weed_amnesia_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'amnesia', item)
end)

XCore.Functions.CreateUseableItem("weed_ak47_seed", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:placePlant', source, 'ak47', item)
end)

XCore.Functions.CreateUseableItem("weed_nutrition", function(source, item)
    local Player = XCore.Functions.GetPlayer(source)
    TriggerClientEvent('x-weed:client:foodPlant', source, item)
end)

RegisterServerEvent('x-weed:server:removeSeed')
AddEventHandler('x-weed:server:removeSeed', function(itemslot, seed)
    local Player = XCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(seed, 1, itemslot)
end)

RegisterServerEvent('x-weed:server:harvestPlant')
AddEventHandler('x-weed:server:harvestPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local weedBag = Player.Functions.GetItemByName('empty_weed_bag')
    local sndAmount = math.random(12, 16)

    if weedBag ~= nil then
        if weedBag.amount >= sndAmount then
            if house ~= nil then 
                exports.ghmattimysql:execute('SELECT * FROM house_plants WHERE plantid=@plantid AND building=@building', {
                    ['@plantid'] = plantId, 
                    ['@building'] = house
                }, function(result)
                    if result[1] ~= nil then
                        Player.Functions.AddItem('weed_'..plantName..'_seed', amount)
                        Player.Functions.AddItem('weed_'..plantName, sndAmount)
                        Player.Functions.RemoveItem('empty_weed_bag', 1)
                        XCore.Functions.ExecuteSql(true, "DELETE FROM `house_plants` WHERE plantid = '"..plantId.."' AND building = '"..house.."'")
                        TriggerClientEvent('XCore:NotifyNotify', src, 'The plant has been harvested', 'success', 3500)
                        TriggerClientEvent('x-weed:client:refreshHousePlants', -1, house)
                    else
                        TriggerClientEvent('XCore:NotifyNotify', src, 'This plant no longer exists?', 'error', 3500)
                    end
                end)
            else
                TriggerClientEvent('XCore:NotifyNotify', src, 'House Not Found', 'error', 3500)
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "You Don't Have Enough Resealable Bags", 'error', 3500)
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Don't Have Enough Resealable Bags", 'error', 3500)
    end
end)

RegisterServerEvent('x-weed:server:foodPlant')
AddEventHandler('x-weed:server:foodPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute('SELECT * FROM house_plants WHERE building=@building AND sort=@sort AND plantid=@plantid', {
        ['@building'] = house, 
        ['@sort'] = plantName,
        ['@plantid'] = tostring(plantId)
    }, function(plantStats)
        TriggerClientEvent('XCore:NotifyNotify', src, XWeed.Plants[plantName]["label"]..' | Nutrition: '..plantStats[1].food..'% + '..amount..'% ('..(plantStats[1].food + amount)..'%)', 'success', 3500)
        if plantStats[1].food + amount > 100 then
            exports.ghmattimysql:execute('UPDATE house_plants SET food=@food WHERE building=@building AND plantid=@plantid', {
                ['@food'] = 100,
                ['@building'] = house,
                ['@plantid'] = plantId
            })
        else
            exports.ghmattimysql:execute('UPDATE house_plants SET food=@food WHERE building=@building AND plantid=@plantid', {
                ['@food'] = (plantStats[1].food + amount),
                ['@building'] = house,
                ['@plantid'] = plantId
            })
        end
        Player.Functions.RemoveItem('weed_nutrition', 1)
        TriggerClientEvent('x-weed:client:refreshHousePlants', -1, house)
    end)
end)