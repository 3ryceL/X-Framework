function GetSharedObject()
    return XCore
end

exports('GetSharedObject', GetSharedObject)

XCore = exports['x-core']:GetSharedObject()