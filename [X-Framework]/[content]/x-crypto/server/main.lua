XCore.Commands.Add("setcryptoworth", "Set crypto value", {{name="crypto", help="Name of the crypto currency"}, {name="Value", help="New value of the crypto currency"}}, false, function(source, args)
    local src = source
    local crypto = tostring(args[1])

    if crypto ~= nil then
        if Crypto.Worth[crypto] ~= nil then
            local NewWorth = math.ceil(tonumber(args[2]))
            
            if NewWorth ~= nil then
                local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
                local ChangeLabel = "+"
                if PercentageChange < 0 then
                    ChangeLabel = "-"
                    PercentageChange = (PercentageChange * -1)
                end
                if Crypto.Worth[crypto] == 0 then
                    PercentageChange = 0
                    ChangeLabel = ""
                end

                table.insert(Crypto.History[crypto], {
                    PreviousWorth = Crypto.Worth[crypto],
                    NewWorth = NewWorth
                })

                TriggerClientEvent('XCore:NotifyNotify', src, "You have the value of "..Crypto.Labels[crypto].."adapted from: ($"..Crypto.Worth[crypto].." to: $"..NewWorth..") ("..ChangeLabel.." "..PercentageChange.."%)")
                Crypto.Worth[crypto] = NewWorth
                TriggerClientEvent('x-crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
                exports.ghmattimysql:execute('UPDATE crypto SET worth=@worth, history=@history WHERE crypto=@crypto', {['@worth'] = NewWorth, ['@history'] = json.encode(Crypto.History[crypto]), ['@crypto'] = crypto})
            else
                TriggerClientEvent('XCore:NotifyNotify', src, "You have not given a new value .. Current values: "..Crypto.Worth[crypto])
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "This Crypto does not exist :(, available: Qbit")
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You have not provided Crypto, available: Qbit")
    end
end, "admin")

XCore.Commands.Add("checkcryptoworth", "", {}, false, function(source, args)
    local src = source
    TriggerClientEvent('XCore:NotifyNotify', src, "The Qbit has a value of: $"..Crypto.Worth["qbit"])
end, "admin")

XCore.Commands.Add("crypto", "", {}, false, function(source, args)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local MyPocket = math.ceil(Player.PlayerData.money.crypto * Crypto.Worth["qbit"])

    TriggerClientEvent('XCore:NotifyNotify', src, "You have: "..Player.PlayerData.money.crypto.." Xit, with a value of: $"..MyPocket..",-")
end, "admin")

RegisterServerEvent('x-crypto:server:FetchWorth')
AddEventHandler('x-crypto:server:FetchWorth', function()
    for name,_ in pairs(Crypto.Worth) do
        exports.ghmattimysql:execute('SELECT * FROM crypto WHERE crypto=@crypto', {['@crypto'] = name}, function(result)
            if result[1] ~= nil then
                Crypto.Worth[name] = result[1].worth
                if result[1].history ~= nil then
                    Crypto.History[name] = json.decode(result[1].history)
                    TriggerClientEvent('x-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, json.decode(result[1].history))
                else
                    TriggerClientEvent('x-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, nil)
                end
            end
        end)
    end
end)

RegisterServerEvent('x-crypto:server:ExchangeFail')
AddEventHandler('x-crypto:server:ExchangeFail', function()
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        Player.Functions.RemoveItem("cryptostick", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('XCore:NotifyNotify', src, "Attempt failed, the stick crashed ..", 'error', 5000)
    end
end)

RegisterServerEvent('x-crypto:server:Rebooting')
AddEventHandler('x-crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('x-crypto:server:GetRebootState')
AddEventHandler('x-crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('x-crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('x-crypto:server:SyncReboot')
AddEventHandler('x-crypto:server:SyncReboot', function()
    TriggerClientEvent('x-crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('x-crypto:server:ExchangeSuccess')
AddEventHandler('x-crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 1000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        Player.Functions.RemoveItem("cryptostick", 1)
        Player.Functions.AddMoney('crypto', Amount)
        TriggerClientEvent('XCore:NotifyNotify', src, "You have exchanged your Cryptostick for: "..Amount.." Xit(\'s)", "success", 3500)
        TriggerClientEvent('inventory:client:ItemBox', src, XCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('x-phone:client:AddTransaction', src, Player, {}, "There are "..Amount.." Qbit('s) credited!", "Credit")
    end
end)

XCore.Functions.CreateCallback('x-crypto:server:HasSticky', function(source, cb)
    local Player = XCore.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("cryptostick")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

XCore.Functions.CreateCallback('x-crypto:server:GetCryptoData', function(source, cb, name)
    local Player = XCore.Functions.GetPlayer(source)
    local CryptoData = {
        History = Crypto.History[name],
        Worth = Crypto.Worth[name],
        Portfolio = Player.PlayerData.money.crypto,
        WalletId = Player.PlayerData.metadata["walletid"],
    }

    cb(CryptoData)
end)

XCore.Functions.CreateCallback('x-crypto:server:BuyCrypto', function(source, cb, data)
    local Player = XCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.bank >= tonumber(data.Price) then
        local CryptoData = {
            History = Crypto.History["qbit"],
            Worth = Crypto.Worth["qbit"],
            Portfolio = Player.PlayerData.money.crypto + tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('bank', tonumber(data.Price))
        TriggerClientEvent('x-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) purchased!", "Credit")
        Player.Functions.AddMoney('crypto', tonumber(data.Coins))
        cb(CryptoData)
    else
        cb(false)
    end
end)

XCore.Functions.CreateCallback('x-crypto:server:SellCrypto', function(source, cb, data)
    local Player = XCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["qbit"],
            Worth = Crypto.Worth["qbit"],
            Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('x-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) sold!", "Depreciation")
        Player.Functions.AddMoney('bank', tonumber(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end
end)

XCore.Functions.CreateCallback('x-crypto:server:TransferCrypto', function(source, cb, data)
    local Player = XCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        exports.ghmattimysql:execute("SELECT * FROM `players` WHERE `metadata` LIKE '%"..data.WalletId.."%'", function(result)
            if result[1] ~= nil then
                local CryptoData = {
                    History = Crypto.History["qbit"],
                    Worth = Crypto.Worth["qbit"],
                    Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
                    WalletId = Player.PlayerData.metadata["walletid"],
                }
                Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('x-phone:client:AddTransaction', source, Player, data, "You have "..tonumber(data.Coins).." Qbit('s) transferred!", "Depreciation")
                local Target = XCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

                if Target ~= nil then
                    Target.Functions.AddMoney('crypto', tonumber(data.Coins))
                    TriggerClientEvent('x-phone:client:AddTransaction', Target.PlayerData.source, Player, data, "There are "..tonumber(data.Coins).." Qbit('s) credited!", "Credit")
                else
                    MoneyData = json.decode(result[1].money)
                    MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                    exports.ghmattimysql:execute('UPDATE players SET money=@money WHERE citizenid=@citizenid', {['@money'] = json.encode(MoneyData), ['@citizenid'] = result[1].citizenid})
                end
                cb(CryptoData)
            else
                cb("notvalid")
            end
        end)
    else
        cb("notenough")
    end
end)