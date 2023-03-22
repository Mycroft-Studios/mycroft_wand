RegisterNetEvent("wand:HitPlayer", function(player, spell, coords)
    local source = source
    if not Player(source).state.wanding then
        return
    end
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
end)

AddEventHandler("playerLeftScope", function(data)
    local playerLeaving, player = tonumber(data["player"]), tonumber(data["for"])
    if Player(playerLeaving).state.wanding then
        TriggerClientEvent("wand:disableParticles", player, playerLeaving)
    end
end)

RegisterNetEvent("wand:PlayerLevitate", function(ply, coords)
    local source = source
    if not Player(source).state.wanding then
        return
    end
    SetEntityCoords(GetPlayerPed(ply), coords)
end)

