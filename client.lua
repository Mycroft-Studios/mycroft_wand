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
local currentSpell = 1
local Handle = nil
local obj = nil
RegisterCommand('wand', function()
	local ped = PlayerPedId()
	local getsuc, wephash = GetCurrentPedWeapon(ped, true)
	if not getsuc then return end
	if wephash ~= Config.ModelName then return end

	wanding = not wanding
	if not wanding then return RemoveParticleFx(Handle, false) end
	local player = PlayerId()

	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(10)
		
		end
	end
	local Coords = GetEntityCoords(ped)
	local weapon = GetCurrentPedWeaponEntityIndex(ped)
	if wanding then
		UseParticleFxAsset("core")
		Handle = StartNetworkedParticleFxLoopedOnEntity("veh_light_red_trail", weapon, 0.45, 0.0, 0.1, 0.0, 0.0, 0.0, 0.3, true, true, true)
		SetParticleFxLoopedEvolution(Handle, "speed", 1.0, false)
		SetParticleFxLoopedColour(Handle, 0.0, 1.0, 0.0, false)
		SetParticleFxLoopedAlpha(Handle, 100.0)
	else
		SetParticleFxLoopedEvolution(Handle, "speed", 1.0, false)
		SetParticleFxLoopedColour(Handle, 0.1, 1.0, 0.0, false)
	end
	while wanding do
		SetPedAmmo(ped, Config.ModelName, 0)
		DisableControlAction(0, 24, true)
		DisablePlayerFiring(player, true)
		ped = PlayerPedId()
		Coords = GetEntityCoords(ped)
		local oldweapon = weapon
		weapon = GetCurrentPedWeaponEntityIndex(ped)
		if weapon ~= oldweapon then
			oldweapon = weapon
			UseParticleFxAsset("core")
			Handle = StartNetworkedParticleFxLoopedOnEntity("veh_light_red_trail", weapon, 0.45, 0.0, 0.1, 0.0, 0.0, 0.0, 0.3, true, true, true)
			SetParticleFxLoopedEvolution(Handle, "speed", 1.0, false)
			SetParticleFxLoopedColour(Handle, 0.0, 1.0, 0.0, false)
			SetParticleFxLoopedAlpha(Handle, 100.0)
		end
		if IsPlayerFreeAiming(player) then
			if IsDisabledControlJustPressed(0, 24) then
				local l,c, e = RayCastGamePlayCamera(1000.0)
				if l then
					local dist = #(Coords - c)
					local coords = GetEntityCoords(weapon)
					RequestModel("prop_poolball_cue") while not HasModelLoaded("prop_poolball_cue") do Wait(0) end
					obj = CreateObject(`prop_poolball_cue`, coords.x, coords.y, coords.z, false, false, false)
					SetEntityAsMissionEntity(obj, true, true)
					SetEntityCompletelyDisableCollision(obj, true, false)
					UseParticleFxAsset("core")
					Handle2 = StartParticleFxLoopedOnEntity("proj_flare_trail", obj, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, true, true, true)
					SetParticleFxLoopedEvolution(Handle2, "speed", 0.5, false)
					SetParticleFxLoopedColour(Handle2, 0.0, 1.0, 0.0, false)
					SetParticleFxLoopedAlpha(Handle2, 100.0)
					local time = 0
					while not SlideObject(obj, c.x, c.y, c.z, 1.0, 1.0, 1.0, false) do
						Wait(0)
						DrawSpellDescription()
						DrawSpellName({200, 50, 50})
						if not IsPlayerFreeAiming(player) then  RemoveParticleFxFromEntity(obj) DeleteEntity(obj) obj = nil break end
					end
					RemoveParticleFxFromEntity(obj)
					DeleteEntity(obj)
				end
				--ShootSingleBulletBetweenCoords(Coords. x , Coords.y, Coords.z + 0.3, c.x, c.y,c.z, 0.0, true, "weapon_flaregun", ped, false, false, 1.0)
				Config.Spells[currentSpell].action(l,c,e)
			end
		else
			if obj then 
				DeleteEntity(obj)
				obj = nil
			end
		end
		getsuc, wephash = GetCurrentPedWeapon(ped, true)
		if not getsuc then RemoveParticleFx(Handle, false) wanding = false break end
		if wephash ~= Config.ModelName then RemoveParticleFx(Handle, false) wanding = false break end
		DrawSpellDescription()
		DrawSpellName()
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
	currentSpell = tonumber(args[1]) or 1
end, false)

RegisterCommand('nextspell', function(src, args)
	currentSpell =  (currentSpell < #Config.Spells) and currentSpell + 1 or #Config.Spells
end, false)

RegisterCommand('lastspell', function(src, args)
	currentSpell =  (currentSpell > 1) and currentSpell - 1 or 1
end, false)

RegisterKeyMapping("nextspell", "Next Spell", "keyboard", "PAGEUP")
RegisterKeyMapping("lastspell", "Previous Spell", "keyboard", "PAGEDOWN")

-- credit: https://forum.cfx.re/t/get-camera-coordinates/183555/14
function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
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
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end