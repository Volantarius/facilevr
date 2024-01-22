local VDMMapJSON = {}
local VDMMapLoaded = false

function GM:VdmGetMapJSON()
	-- ADD AN ADDITIONAL search in the addon's folder, using THIRDPARTY
	-- That way the addon has its own JSON that shouldn't conflict with the ones I
	-- am currently working on!!!
	
	-- If we already have the map return it lol
	if ( VDMMapLoaded ) then
		print("(VDM)", "Loading existing map table.")
		return VDMMapJSON
	end
	
	local json = file.Read( "vdm_"..string.lower(game.GetMap())..".json", "DATA" )
	
	if ( json == nil ) then
		print("(VDM) Could not find map JSON to load spawn points!")
		return nil
	end
	
	local tbl = util.JSONToTable( json )
	
	if ( tbl.version == nil || tbl.version ~= 1.4 ) then
		print("(VDM) FAILED! Incorrect version or not a compatable json.")
		return nil
	end
	
	VDMMapLoaded = true
	VDMMapJSON = table.Copy(tbl)
	
	return VDMMapJSON
end

function GM:VdmBuildPickups( buildSpawns, buildWeapons, buildPowerups )
	buildSpawns = buildSpawns || false
	buildWeapons = buildWeapons || false
	buildPowerups = buildPowerups || false
	
	if ( not buildSpawns && not buildWeapons and not buildPowerups ) then
		return
	end
	
	local tbl = GAMEMODE:VdmGetMapJSON()
	
	if ( tbl == nil ) then
		return
	end
	
	--tbl.spawnPoints = {{pos.x, pos.y, pos.z}, {ang.x, ang.y, ang.z}}
	if ( buildSpawns ) then
		for k,dat in pairs( tbl.spawnPoints ) do
			local ent = ents.Create( "vdm_player_spawn" )
			
			if (!IsValid(ent)) then
				ErrorNoHalt("Coudln't finish creating player spawn points!")
				break
			end
			
			ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
			ent:SetAngles(Angle(dat[2][1], dat[2][2], dat[2][3]))
			
			ent:Spawn()
		end
	end
	
	--tbl.weaponPoints = {{pos.x, pos.y, pos.z}}
	if ( buildWeapons ) then
		for k,dat in pairs( tbl.weaponPoints ) do
			local ent = ents.Create( "vdm_spawner_weapon" )
			
			if (!IsValid(ent)) then
				ErrorNoHalt("Coudln't finish creating weapon spawn points!")
				break
			end
			
			ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
			
			ent:Spawn()
		end
	end
	
	--tbl.powerUpPoints = {{pos.x, pos.y, pos.z}, powerup}
	if ( buildPowerups ) then
		for k,dat in pairs( tbl.powerUpPoints ) do
			local ent = ents.Create( "vdm_spawner_powerup" )
			
			if (!IsValid(ent)) then
				ErrorNoHalt("Coudln't finish creating item spawn points!")
				break
			end
			
			ent:SetPos(Vector(dat[1][1], dat[1][2], dat[1][3]))
			--ent:SetPowerUpClass(dat[2])
			
			ent:Spawn()
		end
	end
	
	print("(VDM)", "Map json loaded and created points!")
end