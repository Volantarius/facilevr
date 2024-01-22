local stuffToSpawn = {
	["item_battery"] = true,
	["item_healthvial"] = true,
	["item_healthkit"] = true,
	
	-- Maybe? CS:S weapons?? idk
	--["weapon_ak47"] = true,
	
	["weapon_ar2"] = true,
	["weapon_bugbait"] = true,
	["weapon_crossbow"] = true,
	["weapon_crowbar"] = true,
	["weapon_frag"] = true,
	["weapon_physcannon"] = true,
	["weapon_pistol"] = true,
	["weapon_rpg"] = true,
	["weapon_shotgun"] = true,
	["weapon_smg1"] = true,
	["weapon_stunstick"] = true,
	["weapon_slam"] = true,
	["weapon_357"] = true,
	
	["item_ammo_pistol"] = true,
	["item_ammo_pistol_large"] = true,
	["item_ammo_smg1"] = true,
	["item_ammo_smg1_large"] = true,
	["item_ammo_ar2"] = true,
	["item_ammo_ar2_large"] = true,
	["item_ammo_357"] = true,
	["item_ammo_357_large"] = true,
	["item_ammo_crossbow"] = true,
	["item_box_buckshot"] = true,
	["item_rpg_round"] = true,
	["item_ammo_smg1_grenade"] = true,
	["item_ammo_ar2_altfire"] = true
}

-- @Volantarius: SUPER NEAT
local cvAllowRespawns = CreateConVar("sv_vdm_hl2respawns", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "HL2DM weapon respawning.", 0, 1)
local cvRespawnTime = CreateConVar("sv_vdm_hl2respawns_time", "20", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "HL2DM respawn time.", 3, 40)

hook.Add( "InitPostEntity", "hl2dmSetupItems", function()
	local items = {}
	
	items = table.Add( items, ents.FindByClass("weapon_*") )
	items = table.Add( items, ents.FindByClass("item_ammo_*") )
	items = table.Add( items, ents.FindByClass("item_box_buckshot") )
	items = table.Add( items, ents.FindByClass("item_rpg_round") )
	items = table.Add( items, ents.FindByClass("item_battery") )
	items = table.Add( items, ents.FindByClass("item_health*") )
	
	for k,wep in pairs( items ) do
		wep.legacy_origin = wep:GetPos()
		wep.legacy_angles = wep:GetAngles()
		wep.legacy_spwned = true
	end
end )

local hl2mpItemsToRespawn = {}

-- @Todo: Make the GM table just point to this!
local function AddWeaponToRespawn( item, time, position, angles )
	local class = item:GetClass()
	local eindex = item:EntIndex()
	
	--print("ADDED: ", item:GetClass(), eindex, time)
	
	hl2mpItemsToRespawn[eindex] = {
		key = eindex,
		time = time,
		pos = position,
		ang = angles,
		classname = item:GetClass()
	}
	
	return true
end

hook.Add( "EntityRemoved", "hl2dmRemoveCall", function( ent )
	local class = ent:GetClass()
	
	--print("REMOVED:", ent)
	
	if (ent.legacy_origin ~= nil && ent.legacy_angles ~= nil && ent.legacy_spwned ~= nil && stuffToSpawn[class] ~= nil) then
		if (ent.legacy_spwned) then
			AddWeaponToRespawn( ent, CurTime(), ent.legacy_origin, ent.legacy_angles )
		end
	end
end )

hook.Add( "WeaponEquip", "hl2dmEquipCall", function( wep, ply )
	local class = wep:GetClass()
	
	--print("EQUIPED:", wep)
	--ply:EmitSound("HL2Player.PickupWeapon")
	
	if (wep.legacy_spwned ~= nil) then
		if (wep.legacy_spwned) then
			
			if (wep.legacy_origin ~= nil && wep.legacy_angles ~= nil && stuffToSpawn[class] ~= nil) then
				AddWeaponToRespawn( wep, CurTime(), wep.legacy_origin, wep.legacy_angles )
			end
			
			wep.legacy_spwned = false -- Make sure this isn't re-added
		end
	end
	
	
end )

local hl2mpEntriesToDelete = {}

local hl2mpSpawnEffect = EffectData()
hl2mpSpawnEffect:SetNormal( Vector(0, 0, 1) )

local sfx_spawn = Sound( "AlyxEmp.Charge" )

-- Handles spawning and deleting entries from list
hook.Add("Tick", "hl2dmSpawnTimer", function()
	local ctime = CurTime()
	
	if ( ctime % 2 == 0 && cvAllowRespawns:GetBool() ) then
		local respawn_time = cvRespawnTime:GetInt()
		
		for id,item in pairs(hl2mpItemsToRespawn) do
			if (ctime > item.time + respawn_time) then
				hl2mpEntriesToDelete = table.Add( hl2mpEntriesToDelete, {{id = id}} )
				
				local newEnt = ents.Create( item.classname )
				
				if ( !IsValid( newEnt ) ) then continue end
				
				newEnt:SetPos( item.pos )
				newEnt:SetAngles( item.ang )
				newEnt.legacy_origin = item.pos
				newEnt.legacy_angles = item.ang
				newEnt.legacy_spwned = true
				newEnt:Spawn()
				newEnt:EmitSound( sfx_spawn )
				
				hl2mpSpawnEffect:SetOrigin( item.pos )
				util.Effect( "stunstickimpact", hl2mpSpawnEffect, true, true )
			end
		end
		
		--PrintTable(hl2mpItemsToRespawn)
		--print("----------", "========", "---------")
		--PrintTable(hl2mpEntriesToDelete)
		
		for k,item in pairs(hl2mpEntriesToDelete) do
			hl2mpItemsToRespawn[item.id] = nil -- This should remove the key `item.id`, unless the engine just skips it
			-- Very nice since table.remove will re-order tables
		end
		
		hl2mpEntriesToDelete = {} -- Make sure to clear the removal table
		--
	end
end)

-- Really neat! This will get rid of these from running during shutdown
-- Instead they are removed at the beginning
hook.Add( "ShutDown", "hl2dmStopPrints", function()
	hook.Remove("EntityRemoved", "hl2dmRemoveCall")
	hook.Remove("Think",         "hl2dmSpawnTimer")
end )