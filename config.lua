Config = {}

-- The settings for all blips. This can be overriden on a service-by-service basis.
Config.DefaultBlip = {
    -- The index of the hex color to use for the blip. See http://www.kronzky.info/fivemwiki/index.php/SetBlipColour
    color = 0,
    -- Whether or not a higher detail version of the sprite should be used.
    highDetail = true,
    -- The time in seconds for the blip to live on the map when the service is called.
    lifetime = 30,
    -- The scale at which to display the sprite.
    scale = 2.0,
    -- Whether or not the sprite should show up outside of the minimap view.
    shortRange = false,
    -- The sprite to use. See https://docs.fivem.net/docs/game-references/blips/
    sprite = 459
}

-- The time in seconds to prevent the same player from using the 911 commands.
Config.CooldownTimes = {
    -- The base cooldown for any call. This will be used if any other call type is nil.
    all = 5,
    -- The cooldown for anonymous calls. Set to nil if you want to use the base cooldown.
    anonymous = nil,
    -- The cooldown for regular calls. Set to nil if you want to use the base cooldown.
    regular = nil
}

-- The color that emergency calls will be.
Config.EmergencyColor = { 255, 0, 0 }
-- The color that non emergency calls  will be.
Config.NonEmergencyColor = { 255, 255, 0 }

-- The list of all services that can be called.
Config.Services = {
    --[[
    -- The key will be the name of the service command.
    ["example"] = {
        -- Whether or not someone can call this service anonymously.
        allowAnonymous = true,
        -- Any options defined in this blip table will override Config.DefaultBlip.
        blip = {},
        -- A check for whether the ESX player provided can see this services incoming calls.
        -- Returning true will mean the player CAN see incoming service calls. Otherwise they can't.
        canSee = function(xPlayer)
            return true
        end,
        -- A check for whether the ESX player provided can reply to incoming service calls.
        -- Returning true will mean the player CAN reply to incoming service calls. Otherwise they can't.
        canReply = function(xPlayer)
            return false
        end,
        -- Whether or not this service is an emergency service.
        emergency = true,
        -- This will be the nicely formatted version of the name used in messages.
        niceName = "Example"
    }
    ]]--
    ["911"] = {
        allowAnonymous = true,
        blip = {
            color = 1
        },
        canSee = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        canReply = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        emergency = true,
        niceName = "911"
    },
    ["311"] = {
        allowAnonymous = true,
        blip = {
            color = 5
        },
        canSee = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        canReply = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        emergency = false,
        niceName = "311"
    },
    ["tow"] = {
        allowAnonymous = false,
        blip = {
            color = 5
        },
        canSee = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        canReply = function(xPlayer)
            return xPlayer.job.name == "police"
        end,
        emergency = false,
        niceName = "Tow"
    }
}

-- Don't edit past this point. --
Config.GetCooldownTime = function(callType)
    return Config.CooldownTimes[string.lower(callType)] or Config.CooldownTimes["all"] or 1
end


Config.CanCallAnonymously = function(service)
    return Config.Services[string.lower(service)].allowAnonymous
end

Config.GetBlipConfig = function(service)
    local blipConfig = {}
    local defaultBlipConfig = Config.DefaultBlip
    local serviceBlipConfig = Config.Services[string.lower(service)].blip

    blipConfig.color = serviceBlipConfig.color or defaultBlipConfig.color
    blipConfig.highDetail = serviceBlipConfig.highDetail or defaultBlipConfig.highDetail
    blipConfig.lifetime = serviceBlipConfig.lifetime or defaultBlipConfig.lifetime
    blipConfig.scale = serviceBlipConfig.scale or defaultBlipConfig.scale
    blipConfig.shortRange = serviceBlipConfig.shortRange or defaultBlipConfig.shortRange
    blipConfig.sprite = serviceBlipConfig.sprite or defaultBlipConfig.sprite

    return blipConfig
end

Config.GetServiceColor = function(service)
    return Config.Services[string.lower(service)].emergency and Config.EmergencyColor or Config.NonEmergencyColor
end

Config.GetServiceName = function(service)
    return Config.Services[string.lower(service)].niceName
end

Config.GetServiceTable = function(service)
    return Config.Services[string.lower(service)]
end

Config.IsEmergencyService = function(service)
    return Config.Services[string.lower(service)].emergency
end