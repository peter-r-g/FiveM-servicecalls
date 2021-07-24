local GetBlipConfig, GetServiceColor, GetServiceName, IsEmergencyService=
Config.GetBlipConfig, Config.GetServiceColor, Config.GetServiceName, Config.IsEmergencyService

local function AddMessage(service, author, msg)
    TriggerEvent("chat:addMessage", {
        color = GetServiceColor(service),
        multiline = true,
        args = { author, msg }
    })
end

-- Service Call Errors --
RegisterNetEvent("serviceCalls:callFailed")
AddEventHandler("serviceCalls:callFailed", function(service)
    AddMessage(service, ("%s Dispatch"):format(GetServiceName(service)), "You have called too recently, please try again later.")
end)

RegisterNetEvent("serviceCalls:cantAnonymousCall")
AddEventHandler("serviceCalls:cantAnonymousCall", function(service)
    AddMessage(service, ("%s Dispatch"):format(GetServiceName(service)), "Anonymous calls are not accepted by this service.")
end)

RegisterNetEvent("serviceCalls:replyInvalid")
AddEventHandler("serviceCalls:replyInvalid", function(service, id)
    AddMessage(service, ("%s Dispatch"):format(GetServiceName(service)), ("Caller ID %s is invalid."):format(id))
end)

-- Service Calls --
local function FormatAuthor(service, name, id, phoneNumber)
    return ("%s | (%d) %s #%s"):format(GetServiceName(service), id or -1, name, phoneNumber or "Unknown")
end

local function FormatResponseAuthor(service, name, id)
    return ("%s > %d | %s"):format(GetServiceName(service), id, name)
end

local function AddBlip(service, callerName, callerPos)
    local blipConfig = GetBlipConfig(service)

    local blipId = AddBlipForCoord(callerPos.x, callerPos.y, callerPos.z)
    SetBlipHighDetail(blipId, blipConfig.highDetail)
    SetBlipSprite(blipId, blipConfig.sprite)
    SetBlipScale(blipId, blipConfig.scale)
    SetBlipColour(blipId, blipConfig.color)
    SetBlipAsShortRange(blipId, blipConfig.shortRange)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(("%s Caller (%s)"):format(GetServiceName(service), callerName))
	EndTextCommandSetBlipName(blipId)

    SetTimeout(blipConfig.lifetime * 1000, function()
        RemoveBlip(blipId)
    end)
end

RegisterNetEvent("serviceCalls:callReceived")
AddEventHandler("serviceCalls:callReceived", function(service, callerName, callerSource, callerPhoneNumber, msg, callerPos)
    AddMessage(service, FormatAuthor(service, callerName, callerSource, callerPhoneNumber), msg)
    AddBlip(service, callerName, callerPos)
end)

RegisterNetEvent("serviceCalls:anonymousCallReceived")
AddEventHandler("serviceCalls:anonymousCallReceived", function(service, msg, callerPos)
    AddMessage(service, FormatAuthor(service, "Anonymous"), msg)
    AddBlip(service, "Anonymous", callerPos)
end)

RegisterNetEvent("serviceCalls:callReplied")
AddEventHandler("serviceCalls:callReplied", function(service, callerName, callerSource, msg)
    AddMessage(service, FormatResponseAuthor(service, callerName, callerSource), msg)
end)

RegisterNetEvent("serviceCalls:callSent")
AddEventHandler("serviceCalls:callSent", function(service)
    AddMessage(service, ("%s Dispatch"):format(GetServiceName(service)), "Your call has been received.")
    AddBlip(service, "You", GetEntityCoords(GetPlayerPed(-1)))
end)

RegisterNetEvent("serviceCalls:callReplySent", function(service)
    AddMessage(service, ("%s Dispatch"):format(GetServiceName(service)), "Your reply has been sent.")
end)