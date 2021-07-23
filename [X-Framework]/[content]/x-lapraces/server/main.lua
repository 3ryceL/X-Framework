Races = {}
AvailableRaces = {}
LastRaces = {}
NotFinished = {}

Citizen.CreateThread(function()
    exports.ghmattimysql:execute('SELECT * FROM lapraces', function(races)
        if races[1] ~= nil then
            for k, v in pairs(races) do
                local Records = {}
                if v.records ~= nil then
                    Records = json.decode(v.records)
                end
                Races[v.raceid] = {
                    RaceName = v.name,
                    Checkpoints = json.decode(v.checkpoints),
                    Records = Records,
                    Creator = v.creator,
                    RaceId = v.raceid,
                    Started = false,
                    Waiting = false,
                    Distance = v.distance,
                    LastLeaderboard = {},
                    Racers = {},
                }
            end
        end
    end)
end)

XCore.Functions.CreateCallback('x-lapraces:server:GetRacingLeaderboards', function(source, cb)
    cb(Races)
end)

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
    local retval = 0
    if seconds <= 0 then
        retval = "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        retval = hours..":"..mins..":"..secs
    end
    return retval
end

RegisterServerEvent('x-lapraces:server:FinishPlayer')
AddEventHandler('x-lapraces:server:FinishPlayer', function(RaceData, TotalTime, TotalLaps, BestLap)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local PlayersFinished = 0
    local AmountOfRacers = 0
    for k, v in pairs(Races[RaceData.RaceId].Racers) do
        if v.Finished then
            PlayersFinished = PlayersFinished + 1
        end
        AmountOfRacers = AmountOfRacers + 1
    end
    local BLap = 0
    if TotalLaps < 2 then
        BLap = TotalTime
    else
        BLap = BestLap
    end
    if LastRaces[RaceData.RaceId] ~= nil then
        table.insert(LastRaces[RaceData.RaceId], {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = {
                [1] = Player.PlayerData.charinfo.firstname,
                [2] = Player.PlayerData.charinfo.lastname
            }
        })
    else
        LastRaces[RaceData.RaceId] = {}
        table.insert(LastRaces[RaceData.RaceId], {
            TotalTime = TotalTime,
            BestLap = BLap,
            Holder = {
                [1] = Player.PlayerData.charinfo.firstname,
                [2] = Player.PlayerData.charinfo.lastname
            }
        })
    end
    if Races[RaceData.RaceId].Records ~= nil and next(Races[RaceData.RaceId].Records) ~= nil then
        if BLap < Races[RaceData.RaceId].Records.Time then
            Races[RaceData.RaceId].Records = {
                Time = BLap,
                Holder = {
                    [1] = Player.PlayerData.charinfo.firstname, 
                    [2] = Player.PlayerData.charinfo.lastname,
                }
            }
            exports.ghmattimysql:execute('UPDATE lapraces SET records=@records WHERE raceid=@raceid', {['@records'] = json.encode(Races[RaceData.RaceId].Records), ['@raceid'] = RaceData.RaceId})
            TriggerClientEvent('x-phone:client:RaceNotify', src, 'You have won the WR from '..RaceData.RaceName..' disconnected with a time of: '..SecondsToClock(BLap)..'!')
        end
    else
        Races[RaceData.RaceId].Records = {
            Time = BLap,
            Holder = {
                [1] = Player.PlayerData.charinfo.firstname,
                [2] = Player.PlayerData.charinfo.lastname,
            }
        }
        exports.ghmattimysql:execute('UPDATE lapraces SET records=@records WHERE raceid=@raceid', {['@records'] = json.encode(Races[RaceData.RaceId].Records), ['@raceid'] = RaceData.RaceId})
        TriggerClientEvent('x-phone:client:RaceNotify', src, 'You have won the WR from '..RaceData.RaceName..' put down with a time of: '..SecondsToClock(BLap)..'!')
    end
    AvailableRaces[AvailableKey].RaceData = Races[RaceData.RaceId]
    TriggerClientEvent('x-lapraces:client:PlayerFinishs', -1, RaceData.RaceId, PlayersFinished, Player)
    if PlayersFinished == AmountOfRacers then
        if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceData.RaceId] ~= nil and next(NotFinished[RaceData.RaceId]) ~= nil then
            for k, v in pairs(NotFinished[RaceData.RaceId]) do
                table.insert(LastRaces[RaceData.RaceId], {
                    TotalTime = v.TotalTime,
                    BestLap = v.BestLap,
                    Holder = {
                        [1] = v.Holder[1],
                        [2] = v.Holder[2]
                    }
                })
            end
        end
        Races[RaceData.RaceId].LastLeaderboard = LastRaces[RaceData.RaceId]
        Races[RaceData.RaceId].Racers = {}
        Races[RaceData.RaceId].Started = false
        Races[RaceData.RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        LastRaces[RaceData.RaceId] = nil
        NotFinished[RaceData.RaceId] = nil
    end
    TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
end)

function IsWhitelisted(CitizenId)
    local retval = false
    for _, cid in pairs(Config.WhitelistedCreators) do
        if cid == CitizenId then
            retval = true
            break
        end
    end
    local Player = XCore.Functions.GetPlayerByCitizenId(CitizenId)
    local Perms = XCore.Functions.GetPermission(Player.PlayerData.source)
    if Perms == "admin" or Perms == "god" then
        retval = true
    end
    return retval
end

function IsNameAvailable(RaceName)
    local retval = true
    for RaceId,_ in pairs(Races) do
        if Races[RaceId].RaceName == RaceName then
            retval = false
            break
        end
    end
    return retval
end

RegisterServerEvent('x-lapraces:server:CreateLapRace')
AddEventHandler('x-lapraces:server:CreateLapRace', function(RaceName)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    
    if IsWhitelisted(Player.PlayerData.citizenid) then
        if IsNameAvailable(RaceName) then
            TriggerClientEvent('x-lapraces:client:StartRaceEditor', source, RaceName)
        else
            TriggerClientEvent('XCore:NotifyNotify', source, 'There is already a race with this name.', 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'You have not been authorized to race\'s to create.', 'error')
    end
end)

XCore.Functions.CreateCallback('x-lapraces:server:GetRaces', function(source, cb)
    cb(AvailableRaces)
end)

XCore.Functions.CreateCallback('x-lapraces:server:GetListedRaces', function(source, cb)
    cb(Races)
end)

XCore.Functions.CreateCallback('x-lapraces:server:GetRacingData', function(source, cb, RaceId)
    cb(Races[RaceId])
end)

XCore.Functions.CreateCallback('x-lapraces:server:HasCreatedRace', function(source, cb)
    cb(HasOpenedRace(XCore.Functions.GetPlayer(source).PlayerData.citizenid))
end)

XCore.Functions.CreateCallback('x-lapraces:server:IsAuthorizedToCreateRaces', function(source, cb, TrackName)
    cb(IsWhitelisted(XCore.Functions.GetPlayer(source).PlayerData.citizenid), IsNameAvailable(TrackName))
end)

function HasOpenedRace(CitizenId)
    local retval = false
    for k, v in pairs(AvailableRaces) do
        if v.SetupCitizenId == CitizenId then
            retval = true
        end
    end
    return retval
end

XCore.Functions.CreateCallback('x-lapraces:server:GetTrackData', function(source, cb, RaceId)
    exports.ghmattimysql:execute('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = Races[RaceId].Creator}, function(result)
        if result[1] ~= nil then
            result[1].charinfo = json.decode(result[1].charinfo)
            cb(Races[RaceId], result[1])
        else
            cb(Races[RaceId], {
                charinfo = {
                    firstname = "Unknown",
                    lastname = "Unknown",
                }
            })
        end
    end)
end)

function GetOpenedRaceKey(RaceId)
    local retval = nil
    for k, v in pairs(AvailableRaces) do
        if v.RaceId == RaceId then
            retval = k
            break
        end
    end
    return retval
end

function GetCurrentRace(MyCitizenId)
    local retval = nil
    for RaceId,_ in pairs(Races) do
        for cid,_ in pairs(Races[RaceId].Racers) do
            if cid == MyCitizenId then
                retval = RaceId
                break
            end
        end
    end
    return retval
end

RegisterServerEvent('x-lapraces:server:JoinRace')
AddEventHandler('x-lapraces:server:JoinRace', function(RaceData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local RaceName = RaceData.RaceData.RaceName
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local CurrentRace = GetCurrentRace(Player.PlayerData.citizenid)
    if CurrentRace ~= nil then
        local AmountOfRacers = 0
        PreviousRaceKey = GetOpenedRaceKey(CurrentRace)
        for k, v in pairs(Races[CurrentRace].Racers) do
            AmountOfRacers = AmountOfRacers + 1
        end
        Races[CurrentRace].Racers[Player.PlayerData.citizenid] = nil
        if (AmountOfRacers - 1) == 0 then
            Races[CurrentRace].Racers = {}
            Races[CurrentRace].Started = false
            Races[CurrentRace].Waiting = false
            table.remove(AvailableRaces, PreviousRaceKey)
            TriggerClientEvent('XCore:NotifyNotify', src, 'You were the only one in the race, the race had ended', 'error')
            TriggerClientEvent('x-lapraces:client:LeaveRace', src, Races[CurrentRace])
        else
            AvailableRaces[PreviousRaceKey].RaceData = Races[CurrentRace]
            TriggerClientEvent('x-lapraces:client:LeaveRace', src, Races[CurrentRace])
        end
        TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
    end
    Races[RaceId].Waiting = true
    Races[RaceId].Racers[Player.PlayerData.citizenid] = {
        Checkpoint = 0,
        Lap = 1,
        Finished = false,
    }
    AvailableRaces[AvailableKey].RaceData = Races[RaceId]
    TriggerClientEvent('x-lapraces:client:JoinRace', src, Races[RaceId], RaceData.Laps)
    TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
    local creatorsource = XCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source
    if creatorsource ~= Player.PlayerData.source then
        TriggerClientEvent('x-phone:client:RaceNotify', creatorsource, string.sub(Player.PlayerData.charinfo.firstname, 1, 1)..'. '..Player.PlayerData.charinfo.lastname..' the race has been joined!')
    end
end)

RegisterServerEvent('x-lapraces:server:LeaveRace')
AddEventHandler('x-lapraces:server:LeaveRace', function(RaceData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local RaceName
    if RaceData.RaceData ~= nil then
        RaceName = RaceData.RaceData.RaceName
    else
        RaceName = RaceData.RaceName
    end
    local RaceId = GetRaceId(RaceName)
    local AvailableKey = GetOpenedRaceKey(RaceData.RaceId)
    local creatorsource = XCore.Functions.GetPlayerByCitizenId(AvailableRaces[AvailableKey].SetupCitizenId).PlayerData.source
    if creatorsource ~= Player.PlayerData.source then
        TriggerClientEvent('x-phone:client:RaceNotify', creatorsource, string.sub(Player.PlayerData.charinfo.firstname, 1, 1)..'. '..Player.PlayerData.charinfo.lastname..' the race has been delivered!')
    end
    local AmountOfRacers = 0
    for k, v in pairs(Races[RaceData.RaceId].Racers) do
        AmountOfRacers = AmountOfRacers + 1
    end
    if NotFinished[RaceData.RaceId] ~= nil then
        table.insert(NotFinished[RaceData.RaceId], {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = {
                [1] = Player.PlayerData.charinfo.firstname,
                [2] = Player.PlayerData.charinfo.lastname
            }
        })
    else
        NotFinished[RaceData.RaceId] = {}
        table.insert(NotFinished[RaceData.RaceId], {
            TotalTime = "DNF",
            BestLap = "DNF",
            Holder = {
                [1] = Player.PlayerData.charinfo.firstname,
                [2] = Player.PlayerData.charinfo.lastname
            }
        })
    end
    Races[RaceId].Racers[Player.PlayerData.citizenid] = nil
    if (AmountOfRacers - 1) == 0 then
        if NotFinished ~= nil and next(NotFinished) ~= nil and NotFinished[RaceId] ~= nil and next(NotFinished[RaceId]) ~= nil then
            for k, v in pairs(NotFinished[RaceId]) do
                if LastRaces[RaceId] ~= nil then
                    table.insert(LastRaces[RaceId], {
                        TotalTime = v.TotalTime,
                        BestLap = v.BestLap,
                        Holder = {
                            [1] = v.Holder[1],
                            [2] = v.Holder[2]
                        }
                    })
                else
                    LastRaces[RaceId] = {}
                    table.insert(LastRaces[RaceId], {
                        TotalTime = v.TotalTime,
                        BestLap = v.BestLap,
                        Holder = {
                            [1] = v.Holder[1],
                            [2] = v.Holder[2]
                        }
                    })
                end
            end
        end
        Races[RaceId].LastLeaderboard = LastRaces[RaceId]
        Races[RaceId].Racers = {}
        Races[RaceId].Started = false
        Races[RaceId].Waiting = false
        table.remove(AvailableRaces, AvailableKey)
        TriggerClientEvent('XCore:NotifyNotify', src, 'You were the only one in the race.The race had ended.', 'error')
        TriggerClientEvent('x-lapraces:client:LeaveRace', src, Races[RaceId])
        LastRaces[RaceId] = nil
        NotFinished[RaceId] = nil
    else
        AvailableRaces[AvailableKey].RaceData = Races[RaceId]
        TriggerClientEvent('x-lapraces:client:LeaveRace', src, Races[RaceId])
    end
    TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
end)

RegisterServerEvent('x-lapraces:server:SetupRace')
AddEventHandler('x-lapraces:server:SetupRace', function(RaceId, Laps)
    local Player = XCore.Functions.GetPlayer(source)
    if Races[RaceId] ~= nil then
        if not Races[RaceId].Waiting then
            if not Races[RaceId].Started then
                Races[RaceId].Waiting = true
                table.insert(AvailableRaces, {
                    RaceData = Races[RaceId],
                    Laps = Laps,
                    RaceId = RaceId,
                    SetupCitizenId = Player.PlayerData.citizenid,
                })
                TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
                SetTimeout(5 * 60 * 1000, function()
                    if Races[RaceId].Waiting then
                        local AvailableKey = GetOpenedRaceKey(RaceId)
                        for cid,_ in pairs(Races[RaceId].Racers) do
                            local RacerData = XCore.Functions.GetPlayerByCitizenId(cid)
                            if RacerData ~= nil then
                                TriggerClientEvent('x-lapraces:client:LeaveRace', RacerData.PlayerData.source, Races[RaceId])
                            end
                        end
                        table.remove(AvailableRaces, AvailableKey)
                        Races[RaceId].LastLeaderboard = {}
                        Races[RaceId].Racers = {}
                        Races[RaceId].Started = false
                        Races[RaceId].Waiting = false
                        LastRaces[RaceId] = nil
                        TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
                    end
                end)
            else
                TriggerClientEvent('XCore:NotifyNotify', source, 'The race is already running', 'error')
            end
        else
            TriggerClientEvent('XCore:NotifyNotify', source, 'The race is already running', 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'This race does not exist :(', 'error')
    end
end)

RegisterServerEvent('x-lapraces:server:UpdateRaceState')
AddEventHandler('x-lapraces:server:UpdateRaceState', function(RaceId, Started, Waiting)
    Races[RaceId].Waiting = Waiting
    Races[RaceId].Started = Started
end)

RegisterServerEvent('x-lapraces:server:UpdateRacerData')
AddEventHandler('x-lapraces:server:UpdateRacerData', function(RaceId, Checkpoint, Lap, Finished)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local CitizenId = Player.PlayerData.citizenid

    Races[RaceId].Racers[CitizenId].Checkpoint = Checkpoint
    Races[RaceId].Racers[CitizenId].Lap = Lap
    Races[RaceId].Racers[CitizenId].Finished = Finished

    TriggerClientEvent('x-lapraces:client:UpdateRaceRacerData', -1, RaceId, Races[RaceId])
end)

RegisterServerEvent('x-lapraces:server:StartRace')
AddEventHandler('x-lapraces:server:StartRace', function(RaceId)
    local src = source
    local MyPlayer = XCore.Functions.GetPlayer(src)
    local AvailableKey = GetOpenedRaceKey(RaceId)
    
    if RaceId ~= nil then
        if AvailableRaces[AvailableKey].SetupCitizenId == MyPlayer.PlayerData.citizenid then
            AvailableRaces[AvailableKey].RaceData.Started = true
            AvailableRaces[AvailableKey].RaceData.Waiting = false
            for CitizenId,_ in pairs(Races[RaceId].Racers) do
                local Player = XCore.Functions.GetPlayerByCitizenId(CitizenId)
                if Player ~= nil then
                    TriggerClientEvent('x-lapraces:client:RaceCountdown', Player.PlayerData.source)
                end
            end
            TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
        else
            TriggerClientEvent('XCore:NotifyNotify', src, 'You are not the creator of the race..', 'error')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', src, 'You are not in a race..', 'error')
    end
end)

RegisterServerEvent('x-lapraces:server:SaveRace')
AddEventHandler('x-lapraces:server:SaveRace', function(RaceData)
    local src = source
    local Player = XCore.Functions.GetPlayer(src)
    local RaceId = GenerateRaceId()
    local Checkpoints = {}
    for k, v in pairs(RaceData.Checkpoints) do
        Checkpoints[k] = {
            offset = v.offset,
            coords = v.coords,
        }
    end
    Races[RaceId] = {
        RaceName = RaceData.RaceName,
        Checkpoints = Checkpoints,
        Records = {},
        Creator = Player.PlayerData.citizenid,
        RaceId = RaceId,
        Started = false,
        Waiting = false,
        Distance = math.ceil(RaceData.RaceDistance),
        Racers = {},
        LastLeaderboard = {},
    }
    exports.ghmattimysql:execute('INSERT INTO lapraces (name, checkpoints, creator, distance, raceid) VALUES (@name, @checkpoints, @creator, @distance, @raceid)', {
        ['@name'] = RaceData.RaceName,
        ['@checkpoints'] = json.encode(Checkpoints),
        ['@creator'] = Player.PlayerData.citizenid,
        ['@distance'] = RaceData.RaceDistance,
        ['@raceid'] = GenerateRaceId()
    })
end)

function GetRaceId(name)
    local retval = nil
    for k, v in pairs(Races) do
        if v.RaceName == name then
            retval = k
            break
        end
    end
    return retval
end

function GenerateRaceId()
    local RaceId = "LR-"..math.random(1111, 9999)
    while Races[RaceId] ~= nil do
        RaceId = "LR-"..math.random(1111, 9999)
    end
    return RaceId
end

XCore.Commands.Add("togglesetup", "Turn on / off racing setup", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)

    if IsWhitelisted(Player.PlayerData.citizenid) then
        Config.RaceSetupAllowed = not Config.RaceSetupAllowed
        if not Config.RaceSetupAllowed then
            TriggerClientEvent('XCore:NotifyNotify', source, 'No more races can be created!', 'error')
        else
            TriggerClientEvent('XCore:NotifyNotify', source, 'Races can be created again!', 'success')
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'You have not been authorized to do this.', 'error')
    end
end)

XCore.Commands.Add("cancelrace", "Cancel going race..", {}, false, function(source, args)
    local Player = XCore.Functions.GetPlayer(source)

    if IsWhitelisted(Player.PlayerData.citizenid) then
        local RaceName = table.concat(args, " ")
        if RaceName ~= nil then
            local RaceId = GetRaceId(RaceName)
            if Races[RaceId].Started then
                local AvailableKey = GetOpenedRaceKey(RaceId)
                for cid,_ in pairs(Races[RaceId].Racers) do
                    local RacerData = XCore.Functions.GetPlayerByCitizenId(cid)
                    if RacerData ~= nil then
                        TriggerClientEvent('x-lapraces:client:LeaveRace', RacerData.PlayerData.source, Races[RaceId])
                    end
                end
                table.remove(AvailableRaces, AvailableKey)
                Races[RaceId].LastLeaderboard = {}
                Races[RaceId].Racers = {}
                Races[RaceId].Started = false
                Races[RaceId].Waiting = false
                LastRaces[RaceId] = nil
                TriggerClientEvent('x-phone:client:UpdateLapraces', -1)
            else
                TriggerClientEvent('XCore:NotifyNotify', source, 'This race has not started yet.', 'error')
            end
        end
    else
        TriggerClientEvent('XCore:NotifyNotify', source, 'You have not been authorized to do this.', 'error')
    end
end)

XCore.Functions.CreateCallback('x-lapraces:server:CanRaceSetup', function(source, cb)
    cb(Config.RaceSetupAllowed)
end)