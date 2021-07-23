local Races = {}
RegisterServerEvent('x-streetraces:NewRace')
AddEventHandler('x-streetraces:NewRace', function(RaceTable)
    local src = source
    local RaceId = math.random(1000, 9999)
    local xPlayer = XCore.Functions.GetPlayer(src)
    if xPlayer.Functions.RemoveMoney('cash', RaceTable.amount, "streetrace-created") then
        Races[RaceId] = RaceTable
        Races[RaceId].creator = XCore.Functions.GetIdentifier(src, 'license')
        table.insert(Races[RaceId].joined, XCore.Functions.GetIdentifier(src, 'license'))
        TriggerClientEvent('x-streetraces:SetRace', -1, Races)
        TriggerClientEvent('x-streetraces:SetRaceId', src, RaceId)
        TriggerClientEvent('XCore:NotifyNotify', src, "You joind the race for €"..Races[RaceId].amount..",-", 'success')
    end
end)

RegisterServerEvent('x-streetraces:RaceWon')
AddEventHandler('x-streetraces:RaceWon', function(RaceId)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddMoney('cash', Races[RaceId].pot, "race-won")
    TriggerClientEvent('XCore:NotifyNotify', src, "You won the race and €"..Races[RaceId].pot..",- recieved", 'success')
    TriggerClientEvent('x-streetraces:SetRace', -1, Races)
    TriggerClientEvent('x-streetraces:RaceDone', -1, RaceId, GetPlayerName(src))
end)

RegisterServerEvent('x-streetraces:JoinRace')
AddEventHandler('x-streetraces:JoinRace', function(RaceId)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local zPlayer = XCore.Functions.GetPlayer(Races[RaceId].creator)
    if zPlayer ~= nil then
        if xPlayer.PlayerData.money.cash >= Races[RaceId].amount then
            Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
            table.insert(Races[RaceId].joined, XCore.Functions.GetIdentifier(src, 'license'))
            if xPlayer.Functions.RemoveMoney('cash', Races[RaceId].amount, "streetrace-joined") then
                TriggerClientEvent('x-streetraces:SetRace', -1, Races)
                TriggerClientEvent('x-streetraces:SetRaceId', src, RaceId)
                TriggerClientEvent('XCore:NotifyNotify', zPlayer.PlayerData.source, GetPlayerName(src).." Joined the race", 'primary')
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "You dont have enough cash", 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "The person wo made the race is offline!", 'error')
        Races[RaceId] = {}
    end
end)

XCore.Commands.Add("createrace", "Start A Street Race", {{name="amount", help="The Stake Amount For The Race."}}, false, function(source, args)
    local src = source
    local amount = tonumber(args[1])
    local Player = XCore.Functions.GetPlayer(src)

    if GetJoinedRace(XCore.Functions.GetIdentifier(src, 'license')) == 0 then
        TriggerClientEvent('x-streetraces:CreateRace', src, amount)
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Are Already In A Race", 'error')    
    end
end)

XCore.Commands.Add("stoprace", "Stop The Race You Created", {}, false, function(source, args)
    local src = source
    CancelRace(src)
end)

XCore.Commands.Add("quitrace", "Get Out Of A Race. (You Will NOT Get Your Money Back!)", {}, false, function(source, args)
    local src = source
    local xPlayer = XCore.Functions.GetPlayer(src)
    local RaceId = GetJoinedRace(XCore.Functions.GetIdentifier(src, 'license'))
    local zPlayer = XCore.Functions.GetPlayer(Races[RaceId].creator)

    if RaceId ~= 0 then
        if GetCreatedRace(XCore.Functions.GetIdentifier(src, 'license')) ~= RaceId then
            RemoveFromRace(XCore.Functions.GetIdentifier(src, 'license'))
            TriggerClientEvent('XCore:NotifyNotify', src, "You Have Stepped Out Of The Race! And You Lost Your Money", 'error')
        else
            TriggerClientEvent('XCore:NotifyNotify', src, "/stoprace To Stop The Race", 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Are Not In A Race ", 'error')
    end
end)

XCore.Commands.Add("startrace", "Start The Race", {}, false, function(source, args)
    local src = source
    local RaceId = GetCreatedRace(XCore.Functions.GetIdentifier(src, 'license'))
    
    if RaceId ~= 0 then
      
        Races[RaceId].started = true
        TriggerClientEvent('x-streetraces:SetRace', -1, Races)
        TriggerClientEvent("x-streetraces:StartRace", -1, RaceId)
    else
        TriggerClientEvent('XCore:NotifyNotify', src, "You Have Not Started A Race", 'error')
        
    end
end)

function CancelRace(source)
    local RaceId = GetCreatedRace(XCore.Functions.GetIdentifier(source, 'license'))
    local Player = XCore.Functions.GetPlayer(source)

    if RaceId ~= 0 then
        for key, race in pairs(Races) do
            if Races[key] ~= nil and Races[key].creator == Player.PlayerData.license then
                if not Races[key].started then
                    for _, iden in pairs(Races[key].joined) do
                        local xdPlayer = XCore.Functions.GetPlayer(iden)
                            xdPlayer.Functions.AddMoney('cash', Races[key].amount, "race-cancelled")
                            TriggerClientEvent('XCore:NotifyNotify', xdPlayer.PlayerData.source, "Race Has Stopped, You Got Back $"..Races[key].amount.."", 'error')
                            TriggerClientEvent('x-streetraces:StopRace', xdPlayer.PlayerData.source)
                            RemoveFromRace(iden)
                    end
                else
                    TriggerClientEvent('XCore:NotifyNotify', Player.PlayerData.source, "The Race Has Already Started", 'error')
                end
                TriggerClientEvent('XCore:NotifyNotify', source, "Race Stopped!", 'error')
                Races[key] = nil
            end
        end
        TriggerClientEvent('x-streetraces:SetRace', -1, Races)
    else
        TriggerClientEvent('XCore:NotifyNotify', source, "You Have Not Started A Race!", 'error')
    end
end

function RemoveFromRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for i, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    table.remove(Races[key].joined, i)
                end
            end
        end
    end
end

function GetJoinedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for _, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    return key
                end
            end
        end
    end
    return 0
end

function GetCreatedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and Races[key].creator == identifier and not Races[key].started then
            return key
        end
    end
    return 0
end
