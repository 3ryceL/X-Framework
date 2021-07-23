XCore.Functions.StartPayCheck = function()
    GivePayCheck = function()
        local Players = XCore.Functions.GetPlayers()

        for i=1, #Players, 1 do
            local Player = XCore.Functions.GetPlayer(Players[i])

            if Player.PlayerData.job ~= nil and Player.PlayerData.job.payment > 0 then
                Player.Functions.AddMoney('bank', Player.PlayerData.job.payment)
                TriggerClientEvent('XCore:NotifyNotify', Players[i], "You received your paycheck of $"..Player.PlayerData.job.payment)
            end
        end
        SetTimeout(XCore.Config.Money.PayCheckTimeOut * (60 * 1000), GivePayCheck)
    end
    SetTimeout(XCore.Config.Money.PayCheckTimeOut * (60 * 1000), GivePayCheck)
end
