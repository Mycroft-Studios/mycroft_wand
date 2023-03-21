RegisterNetEvent("wand:HitPlayer", function(player, spell, coords)
    TriggerClientEvent("Wand:ActivateSpell", player, {id = spell, coords = coords})
end)

RegisterNetEvent("wand:enableParticles", function()
    local source = source
    Player(source).state:set("wanding", true, true)
    TriggerClientEvent("wand:startParticles", -1, source,NetworkGetNetworkIdFromEntity(GetPlayerPed(source)))
end)

RegisterNetEvent("wand:disableParticles", function()
    local source = source
    Player(source).state:set("wanding", false, true)
    TriggerClientEvent("wand:removeParticles", -1, source)
end)

AddEventHandler("playerEnteredScope", function(data)
    local playerEntering, player = tonumber(data["player"]), tonumber(data["for"])
    if Player(playerEntering).state.wanding then
        TriggerClientEvent("wand:startParticles", player, playerEntering, NetworkGetNetworkIdFromEntity(GetPlayerPed(playerEntering)))
    end
    print(("%s is entering %s's scope"):format(playerEntering, player))
end)

AddEventHandler("playerLeftScope", function(data)
    local playerLeaving, player = tonumber(data["player"]), tonumber(data["for"])
    if Player(playerLeaving).state.wanding then
        TriggerClientEvent("wand:disableParticles", player, playerLeaving)
    end
    print(("%s is leaving %s's scope"):format(playerLeaving, player))
end)