XCore.Functions.CreateCallback('x-builderjob:server:GetCurrentProject', function(source, cb)
    local CurProject = nil
    for k, v in pairs(Config.Projects) do
        if v.IsActive then
            CurProject = k
            break
        end
    end

    if CurProject == nil then
        CurProject = math.random(1, #Config.Projects)
        Config.Projects[CurProject].IsActive = true
        Config.CurrentProject = CurProject
    end
    cb(Config)
end)

RegisterServerEvent('x-builderjob:server:SetTaskState')
AddEventHandler('x-builderjob:server:SetTaskState', function(Task, IsBusy, IsCompleted)
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].IsBusy = IsBusy
    Config.Projects[Config.CurrentProject].ProjectLocations["tasks"][Task].completed = IsCompleted
    TriggerClientEvent('x-builderjob:client:SetTaskState', -1, Task, IsBusy, IsCompleted)
end)

RegisterServerEvent('x-builderjob:server:FinishProject')
AddEventHandler('x-builderjob:server:FinishProject', function()
    Config.Projects[Config.CurrentProject].IsActive = false
    for k, v in pairs(Config.Projects[Config.CurrentProject].ProjectLocations["tasks"]) do
        v.completed = false
        v.IsBusy = false
    end
    local NewProject = math.random(1, #Config.Projects)
    Config.CurrentProject = NewProject
    Config.Projects[NewProject].IsActive = true
    TriggerClientEvent('x-builderjob:client:FinishProject', -1, Config)
end)