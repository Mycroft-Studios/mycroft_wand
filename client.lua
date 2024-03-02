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
local PlayerID = PlayerId()
local ServerID = GetPlayerServerId(PlayerID)

WandHandler = setmetatable({}, WandHandler)
WandHandler.__index = WandHandler
WandHandler.inUse = false
WandHandler.isUsingSpell = false
WandHandler.currentSpell = 1
WandHandler.Handle = nil
WandHandler.obj = nil
WandHandler.EnabledParticles = {}

function WandHandler:Toggle()
	self.inUse = not self.inUse
	if self.inUse then
		TriggerServerEvent("wand:enableParticles")
		
	else
		return TriggerServerEvent("wand:disableParticles")
	end
end

function WandHandler:CreateObject(weapon)
	RequestModel("prop_poolball_cue")
	while not HasModelLoaded("prop_poolball_cue") do Wait(0) end

	local coords = GetEntityCoords(weapon)

	self.obj = CreateObject(`prop_poolball_cue`, coords.x, coords.y, coords.z, false, false, false)
	SetEntityAsMissionEntity(self.obj, true, true)
	SetEntityCompletelyDisableCollision(self.obj, true, false)
	UseParticleFxAsset("core")
	local particles = StartParticleFxLoopedOnEntity("proj_flare_trail", self.obj, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, true,
		true, true)
	SetParticleFxLoopedEvolution(particles, "speed", 0.5, false)
	SetParticleFxLoopedColour(particles, 0.0, 1.0, 0.0, false)
	SetParticleFxLoopedAlpha(particles, 100.0)
end

function WandHandler:PtfxLoop()
	CreateThread(function()
        RequestNamedPtfxAsset("core")

        -- Wait until it's done loading.
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(0)
        end

        local particleTbl = {}

        for i = 0, 25 do
            UseParticleFxAsset("core")
            local partiResult = StartParticleFxLoopedOnEntity("ent_amb_elec_crackle", PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, false, false, false)
            particleTbl[#particleTbl + 1] = partiResult
            Wait(0)
        end

        Wait(200)
        for _, parti in ipairs(particleTbl) do
            StopParticleFxLooped(parti, true)
        end
    end)
end

function WandHandler:UseSpell()
	self.isUsingSpell = true
	local l, c, e = RayCastGamePlayCamera(1000.0)
	local spell = Config.Spells[self.currentSpell]
	local stopSpell = false
	if l and not spell.selfCast then
		local weapon = GetCurrentPedWeaponEntityIndex(self.ped)
		self:CreateObject(weapon)
		while not SlideObject(self.obj, c.x, c.y, c.z, 1.0, 1.0, 1.0, false) do
			Wait(0)
			if not IsPlayerFreeAiming(PlayerID) then
				RemoveParticleFxFromEntity(self.obj)
				DeleteEntity(self.obj)
				self.obj = nil
				stopSpell = true
				break
			end
		end

		if stopSpell then self.isUsingSpell = false return end

		RemoveParticleFxFromEntity(self.obj)
		DeleteEntity(self.obj)

		if spell.AgainstOthers and e and DoesEntityExist(e) and IsPedAPlayer(e) then
			local index = NetworkGetPlayerIndexFromPed(e)
			local id = GetPlayerServerId(index)
			TriggerServerEvent("wand:HitPlayer", id, self.currentSpell, c)
			goto skip_action
		end
	end
	if spell.selfCast and Config.UseParticlesForSelfCast then
		self:PtfxLoop()
	end
	:: skip_action ::
	self.isUsingSpell = false
	spell.action(l, c, e, false)

	Config.Spells[self.currentSpell].CanUse = false
	local currspell = self.currentSpell
	SetTimeout(Config.Spells[self.currentSpell].Cooldown, function()
		Config.Spells[currspell].CanUse = true
	end)

end

function WandHandler:UseWand()
	local ped = PlayerPedId()
	local getsuc, wephash = GetCurrentPedWeapon(ped, true)
	if not getsuc then return end
	if wephash ~= Config.ModelName then return end

	self:Toggle()
	self:DrawThread()
	CreateThread(function()
		while self.inUse do
			SetPedAmmo(ped, Config.ModelName, 0)
			DisableControlAction(0, 24, true)
			DisablePlayerFiring(PlayerID, true)
			self.ped = PlayerPedId()

			if IsPlayerFreeAiming(PlayerID) then
				if IsDisabledControlJustPressed(0, 24) and not self.isUsingSpell then
					local spell = Config.Spells[self.currentSpell]
					if spell.CanUse then
						self:UseSpell()
					end
				end
			else
				if self.obj then
					DeleteEntity(self.obj)
					self.obj = nil
				end
			end
			getsuc, wephash = GetCurrentPedWeapon(ped, true)
			if not getsuc then
				TriggerServerEvent("wand:disableParticles")
				self.isUsingSpell = false
				self.inUse = false
				break
			end
			if wephash ~= Config.ModelName then
				TriggerServerEvent("wand:disableParticles")
				self.isUsingSpell = false
				self.inUse = false
				break
			end
			Wait(0)
		end
		RemoveNamedPtfxAsset("core") -- Clean up
	end)
end

function WandHandler:DrawThread()
	CreateThread(function()
		while self.inUse do
			if self.isUsingSpell then
				self:DrawSpellName({ 200, 50, 50 })
			elseif Config.Spells[self.currentSpell].CanUse then
				self:DrawSpellName()
			else
				self:DrawSpellName({ 50, 50, 200 })
			end
			self:DrawSpellDescription()
			Wait(0)
		end
	end)
end

function WandHandler:DrawSpellName(colour)
	if not colour then colour = { 200, 200, 200 } end
	SetTextFont(0)
	SetTextScale(0.4, 0.3)
	SetTextColour(colour[1], colour[2], colour[3], 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName("Current Spell: " .. Config.Spells[self.currentSpell].name)
	EndTextCommandDisplayText(0.0, 0.0)
end

function WandHandler:DrawSpellDescription(colour)
	if not colour then colour = { 150, 150, 150 } end
	SetTextFont(0)
	SetTextScale(0.4, 0.3)
	SetTextColour(colour[1], colour[2], colour[3], 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName("" .. Config.Spells[self.currentSpell].description)
	EndTextCommandDisplayText(0.0, 0.02)
end

RegisterCommand("wand", function()
	WandHandler:UseWand()
end)

RegisterCommand('spell', function(src, args)
	if WandHandler.isUsingSpell then return end
	WandHandler.currentSpell = tonumber(args[1]) or 1
end, false)

RegisterCommand('nextspell', function(src, args)
	if WandHandler.isUsingSpell then return end
	WandHandler.currentSpell = (WandHandler.currentSpell < #Config.Spells) and WandHandler.currentSpell + 1 or
	#Config.Spells
end, false)

RegisterCommand('lastspell', function(src, args)
	if WandHandler.isUsingSpell then return end
	WandHandler.currentSpell = (WandHandler.currentSpell > 1) and WandHandler.currentSpell - 1 or 1
end, false)

RegisterKeyMapping("nextspell", "Next Spell", "keyboard", "PAGEUP")
RegisterKeyMapping("lastspell", "Previous Spell", "keyboard", "PAGEDOWN")
RegisterKeyMapping("wand", "Ready Wand", "keyboard", "HOME")

RegisterNetEvent("Wand:ActivateSpell", function(data)
	if source == '' then return end

	if not Config.Spells[data.id] then
		return
	end
	Config.Spells[data.id].action(true, data.coords, PlayerPedId(), true)
end)

function WandHandler:RequestParticles()
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(10)
		end
	end
	return
end

function WandHandler:UseParticles(player, netid)
	local Ped = player == ServerID and PlayerPedId() or NetToPed(netid)
	if not Ped or Ped == 0 or not DoesEntityExist(Ped) then return end

	self:RequestParticles()

	local weapon = GetCurrentPedWeaponEntityIndex(Ped)
	if not weapon or not DoesEntityExist(weapon) then return end

	UseParticleFxAsset("core")
	local handle = StartNetworkedParticleFxLoopedOnEntity("veh_light_red_trail", weapon, 0.35, 0.0, 0.1, 0.0, 0.0, 0.0,
		0.3, true, true, true)
	SetParticleFxLoopedEvolution(handle, "speed", 1.0, false)
	SetParticleFxLoopedColour(handle, 0.0, 1.0, 0.0, false)
	SetParticleFxLoopedAlpha(handle, 100.0)

	self.EnabledParticles[player] = handle
end

RegisterNetEvent("wand:startParticles", function(player, netid)
	print(source, type(source))
	if source == '' then return end
	WandHandler:UseParticles(player, netid)
end)

RegisterNetEvent("wand:removeParticles", function(player)
	if source == '' then return end

	if not WandHandler.EnabledParticles[player] then return end
	RemoveParticleFx(WandHandler.EnabledParticles[player], false)
	WandHandler.EnabledParticles[player] = nil
end)

-- credit: https://forum.cfx.re/t/get-camera-coordinates/183555/14

function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = {
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
	local a, b, c, d, e = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(cameraCoord.x, cameraCoord.y,
		cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end
