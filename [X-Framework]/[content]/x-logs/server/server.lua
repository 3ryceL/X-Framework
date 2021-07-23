RegisterServerEvent('x-log:server:CreateLog')
AddEventHandler('x-log:server:CreateLog', function(name, title, color, message, tagEveryone)
    local tag = tagEveryone ~= nil and tagEveryone or false
    local webHook = Config.Webhooks[name] ~= nil and Config.Webhooks[name] or Config.Webhooks["default"]
    local embedData = {
        {
            ["title"] = title,
            ["color"] = Config.Colors[color] ~= nil and Config.Colors[color] or Config.Colors["default"],
            ["footer"] = {
                ["text"] = os.date("%c"),
            },
            ["description"] = message,
        }
    }
    PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = "X Logs",embeds = embedData}), { ['Content-Type'] = 'application/json' })
    Citizen.Wait(100)
    if tag then
        PerformHttpRequest(webHook, function(err, text, headers) end, 'POST', json.encode({ username = "X Logs", content = "@everyone"}), { ['Content-Type'] = 'application/json' })
    end
end)

XCore.Commands.Add("testwebhook", "Test Your Discord Webhook For Logs (God Only)", {}, false, function(source, args)
    TriggerEvent("x-log:server:CreateLog", "default", "TestWebhook", "default", "Triggered **a** test webhook :)")
end, "god")