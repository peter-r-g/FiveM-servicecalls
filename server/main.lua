local callers = {}
local seeingPlayers = {}
local CanCallAnonymously, GetCooldownTime = Config.CanCallAnonymously, Config.GetCooldownTime

RegisterNetEvent("esx:playerLogout")
AddEventHandler("esx:playerLogout", function(xPlayer, isNew)
	callers[xPlayer.source] = nil
end)

AddEventHandler("playerDropped", function(source)
    callers[source] = nil
end)

for service, serviceTbl in pairs(Config.Services) do
    seeingPlayers[service] = {}
    local canSee, canReply = serviceTbl.canSee, serviceTbl.canReply

    local function UpdateCooldown(xPlayer, callType)
        local source = xPlayer.source
        if not callers[source] then callers[source] = {} end
    
        if not callers[source][service] or callers[source][service] < os.time() then
            if not callers[source] then callers[source] = {} end

            callers[source][service] = os.time() + GetCooldownTime(callType)
            return false
        else
            return true
        end
    end

    local function GetSeeingPlayers()
        local xPlayers = {}
        local playerSources = ESX.GetPlayers()

        for i=1, #playerSources do
            local xPlayer = ESX.GetPlayerFromId(playerSources[i])
            if canSee(xPlayer) then
                table.insert(xPlayers, xPlayer)
            end
        end

        return xPlayers
    end

    ESX.RegisterCommand(service, "user", function(xPlayer, args, showError)
        if UpdateCooldown(xPlayer, "regular") then
            xPlayer.triggerEvent("serviceCalls:callFailed", service)
            return
        end

        local callerName, callerSource, callerPhoneNumber, callerPos, msg=
        xPlayer.getName(), xPlayer.source, xPlayer.get("phoneNumber"), xPlayer.getCoords(true), table.concat(args, " ")

        local ignoreCallSent = false
        for playerSource, _ in pairs(seeingPlayers[service]) do
            TriggerClientEvent("serviceCalls:callReceived", playerSource, service, callerName, callerSource, callerPhoneNumber, msg, callerPos)
            if playerSource == xPlayer.source then ignoreCallSent = true end
        end

        if not ignoreCallSent then
            xPlayer.triggerEvent("serviceCalls:callSent", service)
        end
    end)
    
    ESX.RegisterCommand(service .. "a", "user", function(xPlayer, args, showError)
        if not CanCallAnonymously(service) then
            xPlayer.triggerEvent("serviceCalls:cantAnonymousCall", service)
            return
        end

        if UpdateCooldown(xPlayer, "anonymous") then
            xPlayer.triggerEvent("serviceCalls:callFailed", service)
            return
        end
    
        local msg, callerPos = table.concat(args, " "), xPlayer.getCoords(true)
        local ignoreCallSent = false
        for playerSource, _ in pairs(seeingPlayers[service]) do
            TriggerClientEvent("serviceCalls:anonymousCallReceived", playerSource, service, msg, callerPos)
            if playerSource == xPlayer.source then ignoreCallSent = true end
        end

        if not ignoreCallSent then
            xPlayer.triggerEvent("serviceCalls:callSent", service)
        end
    end)
    
    ESX.RegisterCommand(service .. "r", "user", function(xPlayer, args, showError)
        if not canReply(xPlayer) then
            return
        end
    
        local id = tonumber(args[1])
        local targetCaller = ESX.GetPlayerFromId(id)
        if not targetCaller then
            xPlayer.triggerEvent("serviceCalls:replyInvalid", service, args[1])
            return
        end
    
        targetCaller.triggerEvent("serviceCalls:callReplied", service, xPlayer.getName(), xPlayer.source, table.concat(args, " ", 2))
        xPlayer.triggerEvent("serviceCalls:callReplySent", service)
    end)
end

Citizen.CreateThread(function()
    while true do
        local playerSources = ESX.GetPlayers()

        while #playerSources > 0 do
            for i=1, math.min(10, #playerSources) do
                local xPlayer = ESX.GetPlayerFromId(table.remove(playerSources, 1))
                for service, serviceTbl in pairs(Config.Services) do
                    if serviceTbl.canSee(xPlayer) then
                        seeingPlayers[service][xPlayer.source] = true
                    else
                        seeingPlayers[service][xPlayer.source] = nil
                    end
                end
            end

            Citizen.Wait(200)
        end

        Citizen.Wait(1000)
    end
end)