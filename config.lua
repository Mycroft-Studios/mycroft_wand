Config = {}
Config.ModelName = `weapon_flaregun`
Config.Spells = {
	{
		name = "BoomBoom!", -- based on Expulso
		description = "Expulso -> Spawns Explosions",
		action = function(hit, coords, entity, remote)
			AddExplosion(coords.x, coords.y, coords.z, 9, 100.0, true, false, 0)
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable spell :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = false -- set to true if another player is required to execute
	},
	{
		name = "Spawnus My Anus!", -- based upon Erecto - Erects tents or other structures
		description = "Erecto -> Spawns Objects",
		action = function(hit, coords, entity, remote)
			local x = GetEntityForwardX(PlayerPedId())
			local y = GetEntityForwardY(PlayerPedId())
			local Coords = GetEntityCoords(PlayerPedId())
			if not hit then coords = vector3(Coords.x + (x * 6.0), Coords.y + (y * 6.0), Coords.z) end
			local objList = {"prop_train_ticket_02_tu","v_ind_cfbucket","v_ind_cm_ladder", "prop_mp_conc_barrier_01", "prop_bskball_01","v_ind_cm_tyre08","v_ind_meatclner", "v_ind_rc_shovel", "prop_vend_snak_01_tu", "p_ld_soc_ball_01"}
			local currentObj = objList[math.random(1, #objList)]
			RequestModel(currentObj) while not HasModelLoaded(currentObj) do Wait(0) end
			local obj = CreateObject(joaat(currentObj), coords.x, coords.y, coords.z, true, false, false)
			SetEntityHeading(obj, math.random(-180, 180))
			SetEntityVelocity(obj, 0.0, 0.0, 0.2)
			SetEntityAsNoLongerNeeded(obj)
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = false -- set to true if another player is required to execute
	},
	{
		name = "Transformers Assemble!", -- based upon Vera Verto - transfiguration spell to turn animals into water goblets.
		description = "Vera Verto -> Turns Entities into Dildos",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if not entity or not DoesEntityExist(entity) then return end
			NetworkRequestControlOfEntity(entity)
			while not NetworkHasControlOfEntity(entity) do 
				Wait(0)
			end
			SetEntityAsMissionEntity(entity, true, true)
			local entity_coords = GetEntityCoords(entity) or coords
			local entity_velocity = GetEntityVelocity(entity)
			local currentObj = "amplys_dildo"
			DeleteEntity(entity)
			RequestModel(currentObj) while not HasModelLoaded(currentObj) do Wait(0) end
			local obj = CreateObject(joaat(currentObj), entity_coords.x, entity_coords.y, entity_coords.z, true, false, false)
			SetEntityHeading(obj, math.random(-180, 180))
			ActivatePhysics(obj)
			--SetEntityVelocity(obj, entity_velocity)
			SetEntityAsNoLongerNeeded(obj)
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "WingGuard la LeviAsshole!", -- based upon wingardium leviosa
		description = "wingardium leviosa -> Levitate Objects",
		action = function(hit, coords, entity, remote)
			local offset = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity))
			if not hit then return end
			if not entity or not DoesEntityExist(entity) then return end
			while IsPlayerFreeAiming(PlayerId()) do
				SetEntityAlpha(entity, 200, false)
				local world, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
				if IsControlPressed(0, 14) then
					offset -= 1
				elseif IsControlPressed(0, 15) then
					offset += 1
				end
				if offset < 0 then
					offset = -offset
				end
				local pos = world + normal * offset
				if GetEntityType(entity) == 1 and IsPedAPlayer(entity) then
					local index = NetworkGetPlayerIndexFromPed(entity)
					local id = GetPlayerServerId(index)
					TriggerServerEvent("wand:PlayerLevitate", id, pos)
				end
				SetEntityCoordsNoOffset(entity, pos.x, pos.y, pos.z)
				Wait(0)
				if not entity or not DoesEntityExist(entity) then break end
			end
			ResetEntityAlpha(entity)
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = false -- DO NOT ENABLE FOR THIS ONE, THIS USES SEPERATE NETWORKING
	},
	{
		name = "Pushy!", -- based upon Repelo Muggletum (Repels Muggles)
		description = "Repelo Muggletum -> Repels Muggles",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local x = GetEntityForwardX(PlayerPedId())
				local y = GetEntityForwardY(PlayerPedId())
				local curr = GetEntityVelocity(entity)
				SetEntityVelocity(entity, x * 500.0, y * 500.0, curr.z)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 2000, -- 2 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Assession!", -- based upon Alarte Ascendare/Ascendio
		description = "Ascendio -> Makes Entities Fly",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local curr = GetEntityVelocity(entity)
				SetEntityVelocity(entity, curr.x, curr.y,  50.0)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 2000, -- 2 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Handyman Sam!", -- based upon Reparo
		description = "Reparo -> Fixes/Revives Entities",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then 
				if GetEntityType(entity) == 1 then
					ResurrectPed(entity)
					SetEntityCoords(entity, coords.x, coords.x, coords.z + 0.5, true, false, false, false)
					SetEntityHealth(entity, GetEntityMaxHealth(entity))
				elseif GetEntityType(entity) == 2 then
					SetVehicleUndriveable(entity, false)
					SetVehicleFixed(entity)
					SetVehicleEngineOn(entity, true, false, false)
					SetVehicleDirtLevel(entity, 0.0)
					SetVehicleOnGroundProperly(entity)
				end
				if entity == PlayerPedId() then
					ResurrectPed(entity)
					local coords = GetEntityCoords(entity)
					NetworkResurrectLocalPlayer(coords.x, coords.x, coords.z + 0.5, 0.0, false, false)
					SetEntityHealth(entity, GetEntityMaxHealth(entity))
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1000, -- 1 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Touch Down!", -- based on Deprimo/Descendo
		description = "Descendo -> Brings Entity to the earth",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local curr = GetEntityVelocity(entity)
				SetEntityVelocity(entity, curr.x, curr.y, -250.0)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1000, -- 1 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Slow Poke!", -- based upon Arresto Momentum
		description = "Arresto Momentum -> Slow Down entities",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local curr = GetEntityVelocity(entity)
				SetEntityVelocity(entity, curr.x / 2, -curr.y / 2, curr.z / 2)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 2500, -- 2.5 seconds - set to 1 to disable cooldown
		AgainstOthers = true, -- set to true if another player is required to execute
	},
	{
		name = "Snow Balling!", -- based upon (Bewitched Snowballs)
		description = "Bewitched Snowballs -> Launch Snowballs",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			RequestWeaponAsset("weapon_snowball", 31, 0)
			while not HasWeaponAssetLoaded("weapon_snowball") do Wait(0) end
			for i = 1, 15 do
				if not IsPlayerFreeAiming(PlayerId()) then 
					return
				end
				local Coords = GetEntityCoords(PlayerPedId())
				local a = GetPedBoneCoords(PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_L_Hand "), 0.0,0.0,0.0)
				ShootSingleBulletBetweenCoords(a.x, a.y, a.z, coords.x, coords.y, coords.z , 5.0, false, "weapon_snowball", PlayerPedId(), true, false, 1.0)
				Wait(50)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 500, -- 0.5 seconds - set to 1 to disable cooldown
		AgainstOthers = false -- set to true if another player is required to execute
	},
	{
		name = "Ice Ice, Baby!", -- based on Petrificus Totalus
		description = "Petrificus Totalus -> Feeze Entites",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local curr = IsEntityPositionFrozen(entity)
				if IsEntityAPed(entity) then ClearPedTasks(entity) SetBlockingOfNonTemporaryEvents(entity, not curr) end
				FreezeEntityPosition(entity, not curr)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1000, -- 1 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Just Dance!", -- based on Tarantallegra
		description = "Tarantallegra -> Forces Ped to Dance",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				if GetEntityType(entity) == 1 then
					ClearPedTasks(entity)
					RequestAnimDict("anim@amb@nightclub@lazlow@hi_railing@") while not HasAnimDictLoaded("anim@amb@nightclub@lazlow@hi_railing@") do Wait(0) end
					TaskPlayAnim(entity, "anim@amb@nightclub@lazlow@hi_railing@", "ambclub_13_mi_hi_sexualgriding_laz", 5.0, 5.0, -1, 49, -1, false, false , false)
					SetBlockingOfNonTemporaryEvents(entity, true)
					RequestModel("ba_prop_battle_glowstick_01") while not HasModelLoaded("ba_prop_battle_glowstick_01") do Wait(0) end
					local prop1 = CreateObject(`ba_prop_battle_glowstick_01`, coords.x + 3.0, coords.y, coords.z, true, false, false)
					AttachEntityToEntity(prop1, entity, GetPedBoneIndex(entity, 28422), 0.0700, 0.1400, 0.0, -80.0, 20.0, 0.0, true, true,
					false, true, 1, true)
					local prop2 = CreateObject(`ba_prop_battle_glowstick_01`, coords.x - 3.0, coords.y, coords.z, true, false, false)
					AttachEntityToEntity(prop2, entity, GetPedBoneIndex(entity, 60309), 0.0700, 0.0900, 0.0, -120.0, -20.0, 0.0, true, true,
					false, true, 1, true)
					SetEntityAsNoLongerNeeded(prop1)
					SetEntityAsNoLongerNeeded(prop2)
					SetModelAsNoLongerNeeded("ba_prop_battle_glowstick_01")
					RemoveAnimDict("anim@amb@nightclub@lazlow@hi_railing@")
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1400, -- 1.5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Flappy Bird!", -- based on Avis/Oppugno
		description = "Avis/Oppugno -> Shoots Birds From Wand",
		action = function(hit)
			RequestModel("a_c_cormorant") while not HasModelLoaded("a_c_cormorant") do Wait(0) end
			local Coords = GetEntityCoords(PlayerPedId())
			for i = 1, 30 do
				local x = GetEntityForwardX(PlayerPedId())
				local y = GetEntityForwardY(PlayerPedId())
				local bird = CreatePed(1, `a_c_cormorant`, Coords.x + (x * math.random(2, 5)), Coords.y + (y* math.random(2, 5)), Coords.z + 0.2, GetEntityHeading(PlayerPedId()), true, false)
				Wait(40)
				SetEntityVelocity(bird, x * math.random(50, 60), y * math.random(50, 60), math.random(5, 10))
				SetEntityAsNoLongerNeeded(bird)
				Wait(5)
				if not IsPlayerFreeAiming(PlayerId()) then
					break
				end
			end
			SetModelAsNoLongerNeeded("a_c_cormorant")
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1, --10000 -- 10 seconds - set to 1 to disable cooldown
		AgainstOthers = false -- set to true if another player is required to execute
	},
	{
		name = "Abra Kadabra!", -- based upon Avada Kedavra
		description = "Avada Kedavra -> Insta-Kill any Ped",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				if GetEntityType(entity) == 1 then
					SetEntityHealth(entity, 0)
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 1, -- 60000 -- 1 minute - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "ExeliArmPits!", -- Based upon Expelliarmus
		description = "Expelliarmus -> Unarms Peds",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				if GetEntityType(entity) == 1 then
					SetCurrentPedWeapon(entity, "weapon_unarmed", true)
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 2500, -- 2.5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "No Pain, No Gain!", -- Based upon Crucio
		description = "Crucio -> Torture Peds",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				if GetEntityType(entity) == 1 then
					ApplyDamageToPed(entity, GetEntityHealth(entity) * 0.99, false)
					local curr = GetEntityVelocity(entity)
					SetEntityVelocity(entity, curr.x, curr.y, 50.0)
					SetPedToRagdoll(entity, 1000, 1000, 0, false, false, false)
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{
		name = "Epstein!", -- based upon Episkey
		description = "Episkey -> Heals Minor Injuries",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				if GetEntityType(entity) == 1 then
					if GetEntityHealth(entity) > GetEntityMaxHealth(entity) / 2 then
						SetEntityHealth(entity, GetEntityMaxHealth(entity))
					end
				end
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 2 * 60000, -- 2 minutes - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{ 
		name = "Reversey!",
		description = "Reverses an Entities Velocity",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if entity and DoesEntityExist(entity) then
				local curr = GetEntityVelocity(entity)
				SetEntityVelocity(entity, -curr.x * 60.0, -curr.y * 60.0, curr.z)
			end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
	{ 
		name = "Shape Shifter!",
		description = "Changes Another Players Model!",
		action = function(hit, coords, entity, remote)
			if not hit then return end
			if not remote then return end
			local modelList = {"mp_f_stripperlite", "mp_m_bogdangoon","u_m_y_mani","u_m_y_justin","u_m_y_staggrm_01", "u_m_y_pogo_01","u_m_y_rsranger_01", "a_c_crow","u_m_y_imporage", "a_c_cow", "a_m_y_hipster_02", "a_m_m_tranvest_01", "a_f_m_beach_01", "mp_m_niko_01"}
			local model = joaat(modelList[math.random(1, #modelList)])
			if IsModelInCdimage(model) and IsModelValid(model) then
				RequestModel(model)
				while not HasModelLoaded(model) do
				  Wait(0)
				end
				SetPlayerModel(PlayerId(), model)
				SetModelAsNoLongerNeeded(model)
			  end
		end,
        CanUse = true, -- used for cooldowns, you can also set to false to perm disable :)
        Cooldown = 5000, -- 5 seconds - set to 1 to disable cooldown
		AgainstOthers = true -- set to true if another player is required to execute
	},
}

