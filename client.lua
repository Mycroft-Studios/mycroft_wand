--[[    
	mycroft_wand
    Copyright (C) Mycroft (Kasey Fitton)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
local wanding = false
local isUsingSpell = false
local currentSpell = 1
local Handle = nil
local obj = nil
local EnabledParticles = {}
RegisterNetEvent("wand:startParticles", function(player, netid)
	local currId = GetPlayerServerId(PlayerId())
	local Ped = player == currId and PlayerPedId() or NetToPed(netid)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(10)
		end
	end
	if not Ped or Ped == 0 or not DoesEntityExist(Ped) then return end
	local weapon = GetCurrentPedWeaponEntityIndex(Ped)
	if not weapon or not DoesEntityExist(weapon) then return end
	UseParticleFxAsset("core")
	local handle = StartNetworkedParticleFxLoopedOnEntity("veh_light_red_trail", weapon, 0.35, 0.0, 0.1, 0.0, 0.0, 0.0, 0.3, true, true, true)
	SetParticleFxLoopedEvolution(handle, "speed", 1.0, false)
	SetParticleFxLoopedColour(handle, 0.0, 1.0, 0.0, false)
	SetParticleFxLoopedAlpha(handle, 100.0)
	EnabledParticles[player] = handle
end)

RegisterNetEvent("wand:removeParticles", function(player)
	if not EnabledParticles[player] then return end
	RemoveParticleFx(EnabledParticles[player], false)
	EnabledParticles[player] = nil
end)

RegisterCommand('wand', function()
	local ped = PlayerPedId()
	local getsuc, wephash = GetCurrentPedWeapon(ped, true)
	if not getsuc then return end
	if wephash ~= Config.ModelName then return end

	wanding = not wanding
	if not wanding then return TriggerServerEvent("wand:disableParticles") end
	local player = PlayerId()

	local weapon = GetCurrentPedWeaponEntityIndex(ped)
	TriggerServerEvent("wand:enableParticles")
	while wanding do
		SetPedAmmo(ped, Config.ModelName, 0)
		DisableControlAction(0, 24, true)
		DisablePlayerFiring(player, true)
		ped = PlayerPedId()

		if IsPlayerFreeAiming(player) then
			if IsDisabledControlJustPressed(0, 24) and not isUsingSpell then
				local spell = Config.Spells[currentSpell]
				if spell.CanUse then
					isUsingSpell = true
					local l,c, e = RayCastGamePlayCamera(1000.0)
					if l then

						local coords = GetEntityCoords(weapon)
						RequestModel("prop_poolball_cue") while not HasModelLoaded("prop_poolball_cue") do Wait(0) end
						obj = CreateObject(`prop_poolball_cue`, coords.x, coords.y, coords.z, false, false, false)
						SetEntityAsMissionEntity(obj, true, true)
						SetEntityCompletelyDisableCollision(obj, true, false)
						UseParticleFxAsset("core")
						Handle2 = StartParticleFxLoopedOnEntity("proj_flare_trail", obj, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, true, true, true)
						SetParticleFxLoopedEvolution(Handle2, "speed", 0.5, false)
						SetParticleFxLoopedColour(Handle2, 0.0, 1.0, 0.0, false)
						SetParticleFxLoopedAlpha(Handle2, 100.0)
						
						while not SlideObject(obj, c.x, c.y, c.z, 1.0, 1.0, 1.0, false) do
							Wait(0)
							DrawSpellDescription()
							DrawSpellName({200, 50, 50})
							if not IsPlayerFreeAiming(player) then RemoveParticleFxFromEntity(obj) DeleteEntity(obj) obj = nil break end
						end
						RemoveParticleFxFromEntity(obj)
						DeleteEntity(obj)
						if spell.AgainstOthers and e and DoesEntityExist(e) and IsPedAPlayer(e) then
							local index = NetworkGetPlayerIndexFromPed(e)
							local id = GetPlayerServerId(index)
							TriggerServerEvent("wand:HitPlayer", id, currentSpell, c)
							goto skip_action
						end
					end
					spell.action(l,c,e, false)
					:: skip_action ::
					Config.Spells[currentSpell].CanUse = false
					local currspell = currentSpell
					SetTimeout(Config.Spells[currentSpell].Cooldown, function()
						Config.Spells[currspell].CanUse = true
					end)
					isUsingSpell = false
				end
			end
		else
			if obj then 
				DeleteEntity(obj)
				obj = nil
			end
		end
		getsuc, wephash = GetCurrentPedWeapon(ped, true)
		if not getsuc then TriggerServerEvent("wand:disableParticles")  wanding = false break end
		if wephash ~= Config.ModelName then TriggerServerEvent("wand:disableParticles")  wanding = false break end
		if Config.Spells[currentSpell].CanUse then
			DrawSpellName()
		else 
			DrawSpellName({50, 50, 200})
		end
			DrawSpellDescription()
		Wait(0)
	end
	RemoveNamedPtfxAsset("core") -- Clean up
end, false)

function DrawSpellName(colour)
	if not colour then colour = {200, 200, 200} end
	SetTextFont(0)
	SetTextScale(0.4, 0.3)
	SetTextColour(colour[1], colour[2], colour[3], 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName("Current Spell: " .. Config.Spells[currentSpell].name)
	EndTextCommandDisplayText(0.0, 0.0)
end

function DrawSpellDescription(colour)
	if not colour then colour = {150, 150, 150} end
	SetTextFont(0)
	SetTextScale(0.4, 0.3)
	SetTextColour(colour[1], colour[2], colour[3], 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName("" .. Config.Spells[currentSpell].description)
	EndTextCommandDisplayText(0.0, 0.02)
end


RegisterCommand('spell', function(src, args)
	if isUsingSpell then return end
	currentSpell = tonumber(args[1]) or 1
end, false)

RegisterCommand('nextspell', function(src, args)
	if isUsingSpell then return end
	currentSpell =  (currentSpell < #Config.Spells) and currentSpell + 1 or #Config.Spells
end, false)

RegisterCommand('lastspell', function(src, args)
	if isUsingSpell then return end
	currentSpell =  (currentSpell > 1) and currentSpell - 1 or 1
end, false)

RegisterKeyMapping("nextspell", "Next Spell", "keyboard", "PAGEUP")
RegisterKeyMapping("lastspell", "Previous Spell", "keyboard", "PAGEDOWN")
RegisterKeyMapping("wand", "Ready Wand", "keyboard", "HOME")

-- credit: https://forum.cfx.re/t/get-camera-coordinates/183555/14

function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot(0)
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = { 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end

RegisterNetEvent("Wand:ActivateSpell", function(data)
	if not Config.Spells[data.id] then 
		return
	end
	Config.Spells[data.id].action(true, data.coords, PlayerPedId(), true)
end)