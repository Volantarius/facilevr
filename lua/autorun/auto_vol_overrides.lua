AddCSLuaFile()

-- Remove that annoying ass bullshit
hook.Add( "OnDamagedByExplosion", "DisableSound", function(ply, dmginfo)
	-- 35 is default with annoying ass ringing
	-- 39 complete deafness for a second is really nice for some punchy effects
	--ply:SetDSP(32, false)-- slight deaf without annoying ass ring
	return true
end )

game.AddParticles("particles/ge_muzzle_fx.pcf")

player_manager.AddValidModel( "death",	"models/player/death.mdl" )
player_manager.AddValidHands( "death",	"models/weapons/c_arms_citizen.mdl",	2, "0000000" )

--[[player_manager.AddValidModel( "jeanette", "models/character/santa_monica/jeanette.mdl" )
player_manager.AddValidHands( "jeanette", "models/weapons/c_arms_citizen.mdl",	2, "0000000" )

player_manager.AddValidModel( "brujah_female", "models/character/pc/female/brujah/brujah_female_armor_3.mdl" )
player_manager.AddValidHands( "brujah_female", "models/weapons/c_arms_citizen.mdl",	2, "0000000" )]]

player_manager.AddValidModel( "Angel Diabla", "models/cyanblue/kof/diabla/diabla.mdl" );
player_manager.AddValidHands( "Angel Diabla", "models/cyanblue/kof/diabla/arms/diabla.mdl", 0, "00000000" )

list.Set( "NPC", "npc_diabla_kof", {
	Name = "Angel Diabla",
	Class = "npc_citizen",
	Health = "100",
	KeyValues = { citizentype = 4 },
	Model = "models/cyanblue/kof/diabla/npc/diabla.mdl",
	Category = "King of Fighters"
} )

hook.Add("Initialize", "preVDMInit", function()

	-- 27 in base GMOD
	-- +8

	game.AddAmmoType({
		name = "vdm_556mm",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		tracer = TRACER_LINE
	})

	game.AddAmmoType({
		name = "vdm_556box",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		tracer = TRACER_LINE
	})

	game.AddAmmoType({
		name = "vdm_762mm",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		tracer = TRACER_LINE
	})

	game.AddAmmoType({
		name = "vdm_338mag",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2800,
		minsplash = 12,
		maxsplash = 16,
		tracer = TRACER_LINE
	})

	game.AddAmmoType({
		name = "vdm_50ae",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		tracer = TRACER_LINE
	})

	-- (2023) Use the already existing 9 and 45 ammos
	--[[game.AddAmmoType({
		name = "vdm_9mm",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2000,
		minsplash = 5,
		maxsplash = 10,
		tracer = TRACER_LINE
	})]]

	game.AddAmmoType({
		name = "vdm_57mm",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2000,
		minsplash = 4,
		maxsplash = 8,
		tracer = TRACER_LINE
	})

	--[[game.AddAmmoType({
		name = "vdm_45acp",
		dmgtype = DMG_BULLET,
		plydmg = 0,
		npcdmg = 0,
		force = 2100,
		minsplash = 6,
		maxsplash = 10,
		tracer = TRACER_LINE
	})]]

end)

if CLIENT then
	language.Add("vdm_556mm_ammo", 		"5.56x45mm")
	language.Add("vdm_556box_ammo", 	"5.56x45mm Box")
	language.Add("vdm_762mm_ammo", 		"7.62x39mm")
	language.Add("vdm_338mag_ammo", 	".338 Magnum")
	language.Add("vdm_50ae_ammo", 		".50 AE")
	--language.Add("vdm_9mm_ammo", 		"9x19mm")
	language.Add("vdm_57mm_ammo", 		"5.7x28mm")
	--language.Add("vdm_45acp_ammo", 		".45 ACP")
	
	--flashbang
	--smoke grenade
	--frag grenade

	--shotguns use buckshot
	--[[
		Shotguns use default buckshot

		HL2 ammo names!
		---------------
		Pistol
		SMG1
		357
		Buckshot
	]]

	return
end

--[[-------------------------------------------------------------------------
	VolShowSpawns
	-------------------------------------------------------------------------
	Shows the position of info_player entites with a helper entitie.
---------------------------------------------------------------------------]]
local function VolShowSpawns( ply, cmd, args )
	local volpspawns = ents.FindByClass( "vol_tool_playerspawn" )
	
	for k,e in pairs( volpspawns ) do
		e:Remove()
	end
	
	local spawnpoints = ents.FindByClass( "info_player_deathmatch" )
	
	if ( #spawnpoints <= 0 ) then
		print("Cannot find any spawn points!")
		return
	else
		print("FOUND "..#spawnpoints.." spawn points.")
	end
	
	for k,e in pairs( spawnpoints ) do
		local cl = e:GetClass()
		local ent = ents.Create( "vol_tool_playerspawn" )
		
		if (!IsValid(ent)) then continue end
		
		ent:SetColor( Color( 0,255,0 ) )
		
		ent:SetPos(e:GetPos())
		ent:SetAngles(e:GetAngles())
		ent:SetSpawnType( cl )
		ent:SetUseInVdm( false )
		
		ent:Spawn()
	end
end

concommand.Add("vol_show_spawns", VolShowSpawns, nil, nil, {FCVAR_CHEAT, FCVAR_DONTRECORD, FCVAR_SPONLY})

--[[-------------------------------------------------------------------------
	VolWriteSpawns
	-------------------------------------------------------------------------
	Later add vol_tool_speccam support to add spectator positions, if I
	really want to
---------------------------------------------------------------------------]]
local function VolWriteSpawns( ply, cmd, args )
	print("Beginning to write spawn points.")
	
	local vdmSpawnsPotential = ents.FindByClass( "vol_tool_playerspawn" )
	local vdmSpawns = {}
	
	for k,e in pairs( vdmSpawnsPotential ) do
		if ( e:GetUseInVdm() ) then
			table.insert(vdmSpawns, e)
		end
	end
	
	local vdmWeapons = ents.FindByClass( "vol_tool_weaponspawn" )
	local vdmPowerUps = ents.FindByClass( "vol_tool_powerupspawn" )
	
	print("FOUND! "..#vdmSpawns.." spawn points.")
	print("FOUND! "..#vdmWeapons.." weapon spawn points.")
	print("FOUND! "..#vdmPowerUps.." power up spawn points.")
	
	local tbl = {}
	tbl.version = 1.4
	tbl.spawnPoints = {}
	tbl.weaponPoints = {}
	tbl.powerUpPoints = {}
	
	print("Building table to be jsonified")
	
	for k,e in pairs( vdmSpawns ) do
		local pos = e:GetPos()
		local ang = e:GetAngles()
		
		table.insert( tbl.spawnPoints, {{pos.x, pos.y, pos.z}, {ang.x, ang.y, ang.z}} )
	end
	
	for k,e in pairs( vdmWeapons ) do
		local pos = e:GetPos()
		
		table.insert( tbl.weaponPoints, {{pos.x, pos.y, pos.z}} )
	end
	
	for k,e in pairs( vdmPowerUps ) do
		local pos = e:GetPos()
		local powerup = e:GetPowerUpClass()
		
		table.insert( tbl.powerUpPoints, {{pos.x, pos.y, pos.z}, powerup} )
	end
	
	local json = util.TableToJSON(tbl, false)--true
	
	if ( json == nil || json == "" ) then
		print("FAILED! JSON failed to create.")
		return
	end
	
	-- Doesn't have a directory thing, kinda bummy
	file.Write( "vdm_"..string.lower(game.GetMap())..".json", json )
	
	print("FINISHED!", "Written to Data.")
end

concommand.Add("vol_write_spawns", VolWriteSpawns, nil, nil, {FCVAR_CHEAT, FCVAR_DONTRECORD, FCVAR_SPONLY})

--[[-------------------------------------------------------------------------
	VolReadSpawns
	-------------------------------------------------------------------------
	Reads the vdm_(map).json from data and creates the helper entities!
---------------------------------------------------------------------------]]
local function VolReadSpawns( ply, cmd, args )
	print("Beginning to read spawn points.")
	
	local mapjson = file.Read( "vdm_"..string.lower(game.GetMap())..".json", "DATA" )
	
	if ( mapjson == nil ) then
		ErrorNoHalt("Could not find map JSON to load spawn points!")
		return
	end
	
	print("LOADED! Found map json.")
	
	local tbl = util.JSONToTable( mapjson )
	
	if ( tbl.version == nil || tbl.version ~= 1.4 ) then
		print("FAILED! Incorrect version or not a compatable json.")
		return
	end
	
	print("OK! Correct version! Creating points now!")
	
	--tbl.spawnPoints = {{pos.x, pos.y, pos.z}, {ang.x, ang.y, ang.z}}
	for k,dat in pairs( tbl.spawnPoints ) do
		local ent = ents.Create( "vol_tool_playerspawn" )
		
		if (!IsValid(ent)) then
			ErrorNoHalt("Can not create vol_tool_playerspawn!!")
			break
		end
		
		ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
		ent:SetAngles(Angle(dat[2][1], dat[2][2], dat[2][3]))
		ent:SetUseInVdm( true )--Make sure we can re-write!
		
		ent:Spawn()
	end
	
	--tbl.weaponPoints = {{pos.x, pos.y, pos.z}}
	for k,dat in pairs( tbl.weaponPoints ) do
		local ent = ents.Create( "vol_tool_weaponspawn" )
		
		if (!IsValid(ent)) then
			ErrorNoHalt("Can not create vol_tool_weaponspawn!!")
			break
		end
		
		ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
		
		ent:Spawn()
	end
	
	--tbl.powerUpPoints = {{pos.x, pos.y, pos.z}, powerup}
	for k,dat in pairs( tbl.powerUpPoints ) do
		local ent = ents.Create( "vol_tool_powerupspawn" )
		
		if (!IsValid(ent)) then
			ErrorNoHalt("Can not create vol_tool_powerupspawn!!")
			break
		end
		
		ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
		ent:SetPowerUpClass(dat[2])
		
		ent:Spawn()
	end
	
	print("FINISHED! Map json loaded and created points!")
end

concommand.Add("vol_read_spawns", VolReadSpawns, nil, nil, {FCVAR_CHEAT, FCVAR_DONTRECORD, FCVAR_SPONLY})