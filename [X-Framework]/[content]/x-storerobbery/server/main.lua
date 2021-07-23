local SafeCodes = {}
local cashA = 250 				--<<how much minimum you can get from a robbery
local cashB = 450				--<< how much maximum you can get from a robbery


Citizen.CreateThread(function()
    while true do 
        SafeCodes = {
            [1] = math.random(1000, 9999),
            [2] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [3] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [4] = math.random(1000, 9999),
            [5] = math.random(1000, 9999),
            [6] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [7] = math.random(1000, 9999),
            [8] = math.random(1000, 9999),
            [9] = math.random(1000, 9999),
            [10] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [11] = math.random(1000, 9999),
            [12] = math.random(1000, 9999),
            [13] = math.random(1000, 9999),
            [14] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [15] = math.random(1000, 9999),
            [16] = math.random(1000, 9999),
            [17] = math.random(1000, 9999),
            [18] = {math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149), math.random(150.0, 359.0), math.random(1, 149)},
            [19] = math.random(1000, 9999),
        }
        Citizen.Wait((1000 * 60) * 40)
    end
end)

RegisterServerEvent('x-storerobbery:server:takeMoney')
AddEventHandler('x-storerobbery:server:takeMoney', function(register, isDone)
    local src = source
	local Player = XCore.Functions.GetPlayer(src)
	local bags = math.random(1,3)
	local info = {
		worth = math.random(cashA, cashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items['markedbills'], "add")
    if isDone then
        if math.random(1, 100) <= 10 then
            local code = SafeCodes[Config.Registers[register].safeKey]
            local info = {}
            if Config.Safes[Config.Registers[register].safeKey].type == "keypad" then
                info = {
                    label = "Safe Code: "..tostring(code)
                }
            else
                info = {
                    label = "Safe Code: "..tostring(math.floor((code[1] % 360) / 3.60)).."-"..tostring(math.floor((code[2] % 360) / 3.60)).."-"..tostring(math.floor((code[3] % 360) / 3.60)).."-"..tostring(math.floor((code[4] % 360) / 3.60)).."-"..tostring(math.floor((code[5] % 360) / 3.60))
                }
            end
            Player.Functions.AddItem("stickynote", 1, false, info)
            TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["stickynote"], "add")
        end
    end
end)

RegisterServerEvent('x-storerobbery:server:setRegisterStatus')
AddEventHandler('x-storerobbery:server:setRegisterStatus', function(register)
    TriggerClientEvent('x-storerobbery:client:setRegisterStatus', -1, register, true)
    Config.Registers[register].robbed   = true
    Config.Registers[register].time     = Config.resetTime
end)

RegisterServerEvent('x-storerobbery:server:setSafeStatus')
AddEventHandler('x-storerobbery:server:setSafeStatus', function(safe)
    TriggerClientEvent('x-storerobbery:client:setSafeStatus', -1, safe, true)
    Config.Safes[safe].robbed = true

    SetTimeout(math.random(40, 80) * (60 * 1000), function()
        TriggerClientEvent('x-storerobbery:client:setSafeStatus', -1, safe, false)
        Config.Safes[safe].robbed = false
    end)
end)

RegisterServerEvent('x-storerobbery:server:SafeReward')
AddEventHandler('x-storerobbery:server:SafeReward', function(safe)
    local src = source
	local Player = XCore.Functions.GetPlayer(src)
	local bags = math.random(1,3)
	local info = {
		worth = math.random(cashA, cashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items['markedbills'], "add")
    local luck = math.random(1, 100)
    local odd = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("rolex", math.random(3, 7))
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["rolex"], "add")
        if luck == odd then
            Citizen.Wait(500)
            Player.Functions.AddItem("goldbar", 1)
            TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["goldbar"], "add")
        end
    end
end)

RegisterServerEvent('x-storerobbery:server:callCops')
AddEventHandler('x-storerobbery:server:callCops', function(type, safe, streetLabel, coords)
    local cameraId = 4
    if type == "safe" then
        cameraId = Config.Safes[safe].camId
    else
        cameraId = Config.Registers[safe].camId
    end
    local alertData = {
        title = "10-33 | Shop Robbery",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Someone Is Trying To Rob A Store At "..streetLabel.." (CAMERA ID: "..cameraId..")"
    }
    TriggerClientEvent("x-storerobbery:client:robberyCall", -1, type, safe, streetLabel, coords)
    TriggerClientEvent("x-phone:client:addPoliceAlert", -1, alertData)
end)

Citizen.CreateThread(function()
    while true do
        local toSend = {}
        for k, v in pairs(Config.Registers) do
            if Config.Registers[k].time > 0 and (Config.Registers[k].time - Config.tickInterval) >= 0 then
                Config.Registers[k].time = Config.Registers[k].time - Config.tickInterval
            else
                Config.Registers[k].time = 0
                Config.Registers[k].robbed = false
                table.insert(toSend, k)
            end
        end
        TriggerClientEvent('x-storerobbery:client:setRegisterStatus', -1, toSend, false)        
        Citizen.Wait(Config.tickInterval)
    end
end)

XCore.Functions.CreateCallback('x-storerobbery:server:isCombinationRight', function(source, cb, safe)
    cb(SafeCodes[safe])
end)

XCore.Functions.CreateCallback('x-storerobbery:server:getPadlockCombination', function(source, cb, safe)
    cb(SafeCodes[safe])
end)

XCore.Functions.CreateCallback('x-storerobbery:server:getRegisterStatus', function(source, cb)
    cb(Config.Registers)
end)

XCore.Functions.CreateCallback('x-storerobbery:server:getSafeStatus', function(source, cb)
    cb(Config.Safes)
end)
