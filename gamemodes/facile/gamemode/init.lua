AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "cl_voting.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )
AddCSLuaFile( "cl_interactions.lua" )
AddCSLuaFile( "cl_pickteam.lua" )
AddCSLuaFile( "cl_targetid.lua" )
AddCSLuaFile( "cl_fahud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_deathnotice.lua" )

include( "shared.lua" )

include( "interactions/init.lua" )

include( "sv_voting.lua" )
include( "sv_playerdeath.lua" )
include( "sv_spectator.lua" )
include( "sv_teams.lua" )
include( "sv_roundlogic.lua" )
include( "player.lua" )

--include( "sv_bots.lua" )

-- Maybe run concommands here?
-- OnGamemodeLoaded is before Init
hook.Add("Initialize", "FacileInit", function()
	util.AddNetworkString( "facile_showclasses" )
	util.AddNetworkString( "facile_switchweapon" )
	util.AddNetworkString( "facile_playerstate" )

	util.AddNetworkString( "facile_updatetimer" )

	-- vr
	util.AddNetworkString( "favr_pose" )
	
	-- client to server
	util.AddNetworkString( "facile_requeststate" )
	
	RunConsoleCommand("ai_disabled", "0")
	RunConsoleCommand("ai_ignoreplayers", "0")
	RunConsoleCommand("ai_serverragdolls", "0")
	RunConsoleCommand("npc_citizen_auto_player_squad", "0")
	
	-- Bot shit
	RunConsoleCommand("bot_flipout", "0")
	RunConsoleCommand("bot_zombie", "1")
end)

-- Need to setup some functions that can allow the gamemode to set console variables
-- And then allow players who leave to reset them back, and if the server shuts down to reset as well
-- So things like gravity, etc.. can be changed with out much changed elsewhere
-- Specifically if going to a new gamemode that doesn't want to change anything and just default to normal.

function GM:PlayerSpawnAsSpectator( pl, skipDeath )
	-- BUG: Must strip everything before killing and then start spectate!
	-- skipDeath is for internal use, You want to strip, kill, then spectate in that order for no issues
	if (not skipDeath) then
		pl:StripWeapons()
		pl:StripAmmo()

		if ( pl:Alive() ) then pl:Kill() end
	end

	pl:SpectateEntity( nil )
	pl:Spectate( OBS_MODE_ROAMING )
end

-- Players already spawn as unassigned, so just go into spectate as soon as possible
function GM:PlayerInitialSpawn( pl, transition )
	pl:KillSilent()

	pl:SetTeam( TEAM_SPECTATOR )

	pl.LastTeamSwitch = nil

	if ( pl:IsBot() ) then
		GAMEMODE:PlayerRequestTeam( pl, team.BestAutoJoinTeam() )
		
		return
	end
end

-- Transitions are things that HL2 maps do, where they carry weapons over
function GM:PlayerSpawn( pl, transition )

	local pTeam = pl:Team()

	-- Never allow spectators to spawn!
	if ( pTeam == TEAM_SPECTATOR ) then
		pl:StripWeapons()
		pl:StripAmmo()

		pl:KillSilent()

		GAMEMODE:PlayerSpawnAsSpectator( pl, true )

		return
	end

	if ( pl.spawnClass ) then
		player_manager.SetPlayerClass( pl, pl.spawnClass )
		pl.spawnClass = nil
	end

	pl:UnSpectate()

	pl:SetupHands()

	player_manager.OnPlayerSpawn( pl, transition )
	player_manager.RunClass( pl, "Spawn" )

	if ( !transition ) then
		hook.Call( "PlayerLoadout", GAMEMODE, pl )
	end

	hook.Call( "PlayerSetModel", GAMEMODE, pl )

	-- Make sure anyone with vr is setup
	if ( pl.vr_mode ) then
		GAMEMODE:PlayerSetupVR( pl )
	end

	pl.ProtectTime = RealTime() + 3
	
	local ed = EffectData()
	ed:SetOrigin( pl:GetPos() )
	ed:SetEntity( pl )
	ed:SetScale( 3 )-- In place of how long the protection time lasts
	util.Effect( "vdm_protect", ed )

	net.Start("facile_playerstate")
		net.WriteUInt( 1, 32 )
	net.Send( pl )
end

function GM:PlayerLoadout( pl )

	-- Doesn't appear to be any good way of keeping weapons, so heres an attempt
	-- Doesn't count clips per weapon as ammo deduction

	if ( pl.SaveLoadoutTime && pl.SaveLoadoutTime - CurTime() == 0 ) then

		for k,v in ipairs( pl.SaveLoadout ) do
			pl:Give( v:GetClass(), false )
		end

		for id,amnt in pairs( pl.SaveLoadoutAmmo ) do
			pl:SetAmmo( amnt, id )
		end

		net.Start( "facile_switchweapon" )
		net.WriteString( pl.SaveLoadoutLastWeapon )
		net.Send( pl )

		pl.SaveLoadoutTime = nil
		pl.SaveLoadout = nil
		pl.SaveLoadoutLastWeapon = nil
		pl.SaveLoadoutAmmo = nil

	else
		player_manager.RunClass( pl, "Loadout" )
	end
end

function GM:ShowSpare1( pl )
	net.Start( "facile_showclasses" )
	net.Send( pl )
end

-- Doesn't have a concommand
function GM:AutoTeam( pl )
	local best_team = GAMEMODE:BestAutoTeam()
	
	GAMEMODE:PlayerRequestTeam( pl, best_team )
end

concommand.Add( "autoteam", function( p, cmd, args )
	GAMEMODE:AutoTeam( p )
end )

function GM:UpdatePhaseTimer( time, message )
	-- Relative to CurTime
	SetGlobalFloat( "FacileTimer", time )
	SetGlobalString( "FacileTimerMsg", message )

	net.Start( "facile_updatetimer" )
		net.WriteFloat( time )
		net.WriteString( message )
	net.Broadcast()
end

local nonsweps = {
	["weapon_shotgun"] = { clip1 = 6, clip1ammo = "Buckshot" },
	["weapon_crossbow"] = { clip1 = 1, clip1ammo = "XBowBolt" },
	["weapon_357"] = { clip1 = 6, clip1ammo = "357" },
	["weapon_pistol"] = { clip1 = 18, clip1ammo = "Pistol" },
	["weapon_smg1"] = { clip1 = 45, clip1ammo = "SMG1", clip2 = 1, clip2ammo = "SMG1_Grenade" },
	["weapon_ar2"] = { clip1 = 30, clip1ammo = "AR2", clip2 = 1, clip2ammo = "AR2AltFire" },

	--[[["weapon_rpg"] = { clip1 = 1, clip1def = 3, clip1ammo = "RPG_Round"},
	["weapon_slam"] = { clip1 = 1, clip1def = 3, clip1ammo = "slam"},]]

	["weapon_frag"] = { clip1 = 1, clip1ammo = "Grenade" }
}

local cvMagMul = CreateConVar("sv_facile_loadoutclipsize", "10", {FCVAR_ARCHIVE}, "Multiplier for clips given for loadouts", 1, 100)

function GM:LoadDeathmatchLoadout( ply )
	local LoadoutWeps = list.Get("FacileLoadoutWeapons")
	local validWeapons = LoadoutWeps["defaultSetValid"]

	local MagMul = cvMagMul:GetInt()

	for i = 0, 10 do
		local weaponclass = ply:GetInfo( ("cl_facile_loadout_weapon"..i) )
		weaponclass = string.Trim(weaponclass)

		if ( weaponclass ~= "" ) then
			if ( not validWeapons[weaponclass] ) then
				print("could not give: ", weaponclass)
				continue
			end

			local weaponInfo = weapons.Get( weaponclass )

			if ( weaponInfo == nil ) then
				if ( nonsweps[weaponclass] ) then
					local nonswepInfo = nonsweps[weaponclass]

					if ( nonswepInfo.clip1 ) then
						ply:GiveAmmo( nonswepInfo.clip1 * MagMul, nonswepInfo.clip1ammo, true )
					end

					if ( nonswepInfo.clip2 ) then
						ply:GiveAmmo( nonswepInfo.clip2 * MagMul, nonswepInfo.clip2ammo, true )
					end
				end
			else
				if ( weaponInfo.Primary.Ammo ~= "none" ) then
					if ( weaponInfo.Primary.ClipSize > 0 ) then
						ply:GiveAmmo( weaponInfo.Primary.ClipSize * MagMul, weaponInfo.Primary.Ammo, true )
					elseif ( weaponInfo.Primary.DefaultClip > 0 ) then
						ply:GiveAmmo( weaponInfo.Primary.DefaultClip * MagMul, weaponInfo.Primary.Ammo, true )
					end
				end

				if ( weaponInfo.Secondary.Ammo ~= "none" ) then
					if ( weaponInfo.Secondary.ClipSize > 0 ) then
						ply:GiveAmmo( weaponInfo.Secondary.ClipSize * MagMul, weaponInfo.Secondary.Ammo, true )
					elseif ( weaponInfo.Secondary.DefaultClip > 0 ) then
						ply:GiveAmmo( weaponInfo.Primary.DefaultClip * MagMul, weaponInfo.Secondary.Ammo, true )
					end
				end
			end

			ply:Give( weaponclass )
		end
	end

	LoadoutWeps = nil
	validWeapons = nil
end

local entity_cleanup = {}
local entities_tobecleaned = {}

function GM:AddToCleanUp( e, time_length )
	if ( !IsValid( e ) ) then return false end
	if ( e:IsPlayer() ) then return false end
	
	e.RemoveTime = CurTime() + time_length
	
	entity_cleanup[ e:EntIndex() ] = e
end

-- Clean up some entities throughout the game running
-- Things like NPCs or random entities for players
function GM:PerformTidyUp()
	entities_tobecleaned = {}
	
	local time_now = CurTime()
	
	for k,e in pairs( entity_cleanup ) do
		if ( time_now > e.RemoveTime ) then
			table.insert( entities_tobecleaned, {id = k, itself = e} )
		end
	end
	
	for k,et in ipairs( entities_tobecleaned ) do
		if ( IsValid( et.itself ) ) then
			et.itself:Remove()
		end
		
		entity_cleanup[et.id] = nil
	end
end

hook.Add( "PostCleanupMap", "faCleanupTidyup", function()
	entity_cleanup = {}
	entities_tobecleaned = {}
end)

function GM:TrailSetup( ply )
	if ( !ply:IsBot() ) then
		if ( ply:GetInfoNum( "cl_facile_trail_enabled", 0 ) < 1 ) then return end
	end

	local tempColor = Vector( ply:GetInfo( "cl_facile_trail_color" ) ) || Vector(1, 1, 1)

	local color = tempColor:ToColor()
	local additive = ply:GetInfoNum( "cl_facile_trail_add", 0 ) > 0
	local startWidth = math.Clamp( ply:GetInfoNum( "cl_facile_trail_start", 24 ), 2, 24 )
	local endWidth = math.Clamp( ply:GetInfoNum( "cl_facile_trail_end", 0 ), 0, 32 )
	local texture = ply:GetInfo( "cl_facile_trail" ) || "trails/smoke"

	if ( ply:IsBot() ) then
		tempColor = Vector(1, 1, 1)
		color = Color(255, 255, 255)
		additive = false
		startWidth = 24
		endWidth = 4
		texture = "trails/laser"
	end

	local res = 1 / ( startWidth + endWidth ) * 0.5

	local holder = ents.Create( "fa_spriteholder" )

	--Create the offset like so
	holder:SetPos( ply:GetPos() + Vector( 0, 0, 10 ) )
	holder:Spawn()

	local trail = util.SpriteTrail( holder, -1, color, additive, startWidth, endWidth, 12, res, texture )

	holder:DontDeleteOnRemove( trail )-- Just to make sure this doesn't happen

	-- game cleanup will remove
	holder:CallOnRemove( "fadontkill", function( ent, trailer )
		trailer:SetParent( nil )
		
		GAMEMODE:AddToCleanUp( trailer, 13 )
	end, trail)

	holder:SetParent( ply, -1 )

	-- In sv_playerdeath.lua we get the parented entites and delete the spriteholder there!
	-- Should maybe see if theres a better way of doing that
end

-- VR

local function receive_vrpose( len, p )

	local hmd_position = net.ReadVector()
	local hmd_angles = net.ReadAngle()

	-- Disable hand posing for now... Still unsure how to pose the players

	--[[local lefthand_position = net.ReadVector()
	local lefthand_angles = net.ReadAngle()

	local righthand_position = net.ReadVector()
	local righthand_angles = net.ReadAngle()]]

	-- Must read everything before checking and returning
	if ( !IsValid( p ) ) then return end
	if ( !p.vr_mode ) then return end
	
	p.hmd_position = hmd_position
	p.hmd_angles = hmd_angles

	--[[p.lefthand_position = lefthand_position
	p.lefthand_angles = lefthand_angles

	p.righthand_position = righthand_position
	p.righthand_angles = righthand_angles]]
end

net.Receive( "favr_pose", receive_vrpose )

function GM:PlayerSetupVR( p )
	local player_pos = p:GetPos()

	p:SetHull( Vector(-12, -12, 0), Vector(12, 12, 72) )
	p:SetHullDuck( Vector(-12, -12, 0), Vector(12, 12, 36) )

	-- We have our own flashlight system now
	p:Flashlight( false )
	
	-- TODO: Gonna have to change this in the future
	p:DrawShadow( false )

	-- Despite being called a vr entity, this is just a third person camera setup
	-- All of this can be re-used to make a good 3rd person camera system
	local vr_view = p.vr_view_entity

	if ( !IsValid( vr_view ) ) then
		vr_view = ents.Create( "fa_thirdpersoncamera" )
		vr_view:SetPos( player_pos )
		vr_view:Spawn()

		vr_view:SetOwner( p )

		p.vr_view_entity = vr_view
	end

	--local head_bone = p:LookupBone( "ValveBiped.Bip01_Head1" )
	--p:ManipulateBoneScale( head_bone, Vector(0, 0, 0) )

	-- @Note: This doesn't change from vehicles
	p:SetViewEntity( vr_view )
end

local player_GetAll = player.GetAll

local function PlayerEnableVR( p )
	-- If already started don't re-enable?
	if ( p.vr_mode ) then return end
	
	-- Network VR mode
	p:SetNWBool( "VR", true )
	
	p.vr_mode = true
	
	net.Start("facile_playerstate")
		net.WriteUInt( 256, 32 )
	net.Send( p )
	
	GAMEMODE:PlayerSetupVR( p )
	
	--[[local rhand = ents.Create( "sent_vdmvr_gloves" )
	local lhand = ents.Create( "sent_vdmvr_gloves" )
	
	rhand:Spawn()
	lhand:Spawn()]]
	
	--[[hook.Add("Think", "FAVRHands", function()
		for k, p in ipairs( player_GetAll() ) do
			if ( p.vr_mode && p.hmd_position ) then
				
				local player_position = p:GetPos()
				
				local rhand_pos_info = p:GetInfo( "favr_fire_pos" )
				local lhand_pos_info = p:GetInfo( "favr_off_pos" )
				
				local rhand_pos = Vector( rhand_pos_info ) + player_position
				local lhand_pos = Vector( lhand_pos_info ) + player_position
				
				local rhand_valid = IsValid( rhand )
				local lhand_valid = IsValid( lhand )
				
				if ( !rhand_valid ) then rhand = ents.Create( "sent_vdmvr_gloves" ) rhand:Spawn() end
				if ( !lhand_valid ) then lhand = ents.Create( "sent_vdmvr_gloves" ) lhand:Spawn() end
				
				if ( IsValid( lhand ) && IsValid( rhand ) ) then
					local rphys = rhand:GetPhysicsObject()
					local lphys = lhand:GetPhysicsObject()
					
					rhand:SetOwner( p )
					lhand:SetOwner( p )
					
					local rphys_pos = rphys:GetPos()
					local lphys_pos = lphys:GetPos()
					local rphys_vel = rphys:GetVelocity()
					local lphys_vel = lphys:GetVelocity()
					
					local rhand_real = rhand:WorldSpaceCenter() - rhand_pos
					local rhand_target_position = rhand_pos - rhand_real
					
					local lhand_real = lhand:WorldSpaceCenter() - lhand_pos
					local lhand_target_position = lhand_pos - lhand_real
					
					local r_output_vel = rphys_vel
					local l_output_vel = lphys_vel
					
					local r_snapshot = rphys:GetFrictionSnapshot()
					local r_angular_velocity = rphys:GetAngleVelocity()
					
					if ( r_snapshot and #r_snapshot > 0 ) then
						for k,dat in ipairs( r_snapshot ) do
							if ( IsValid(dat.Other) and dat.Other:IsMoveable() ) then
								local snap_normal = dat.Normal
								
								r_angular_velocity = snap_normal * ( r_angular_velocity:Dot( snap_normal ) )
								
								local proj = r_output_vel:Dot( snap_normal )
								--local proj = snap_normal:Dot( output_velocity )
								
								if ( proj > 0 ) then
									r_output_vel = r_output_vel - (snap_normal * proj)
								end
							end
						end
					end
					
					local l_snapshot = lphys:GetFrictionSnapshot()
					local l_angular_velocity = lphys:GetAngleVelocity()
					
					if ( l_snapshot and #l_snapshot > 0 ) then
						for k,dat in ipairs( l_snapshot ) do
							if ( IsValid(dat.Other) and dat.Other:IsMoveable() ) then
								local snap_normal = dat.Normal
								
								l_angular_velocity = snap_normal * ( l_angular_velocity:Dot( snap_normal ) )
								
								local proj = l_output_vel:Dot( snap_normal )
								
								if ( proj > 0 ) then
									l_output_vel = l_output_vel - (snap_normal * proj)
								end
							end
						end
					end
					
					local rpos_diff = rphys_pos - rhand_pos
					local lpos_diff = lphys_pos - lhand_pos
					
					if ( rpos_diff:LengthSqr() > 16384 || lpos_diff:LengthSqr() > 16384 ) then
						rhand:SetPos( rhand_pos )
						lhand:SetPos( lhand_pos )
					else
						
						local r_farts = rphys_pos - rhand_target_position
						local l_farts = lphys_pos - lhand_target_position
						
						local rphys_off_vel, _ = rphys:CalculateVelocityOffset( r_farts * rphys:GetMass() * -16, rhand_pos )
						
						local lphys_off_vel, _ = lphys:CalculateVelocityOffset( l_farts * lphys:GetMass() * -16, lhand_pos )
						
						rphys:SetAngleVelocityInstantaneous( r_angular_velocity )
						
						rphys:SetVelocityInstantaneous( (rphys:GetVelocity() * -1) + r_output_vel )
						
						rphys:AddVelocity( rphys_off_vel )
						
						lphys:SetAngleVelocityInstantaneous( l_angular_velocity )
						
						lphys:SetVelocityInstantaneous( (lphys:GetVelocity() * -1) + l_output_vel )
						
						lphys:AddVelocity( lphys_off_vel )
						
					end
				end
				
			end
		end
	end)]]
end

local function PlayerDisableVR( p )
	if ( p:GetNWBool( "VR", false ) ) then
		p:DrawShadow( true )
	end
	
	-- Network VR mode
	p:SetNWBool( "VR", false )
	
	hook.Remove("Think", "FAVRHands")
	
	p.vr_mode = false
end

-- Players will request modes or random junk
-- We want a super simple way of doing that here
local function RecievePlayerRequest( len, p )
	local value = net.ReadUInt(32)
	
	if ( value == 50 ) then
		GAMEMODE:PlayerSpecMode( p )
	end
	
	if ( value == 51 ) then
		GAMEMODE:PlayerSpecNext( p )
	end
	
	if ( value == 52 ) then
		GAMEMODE:PlayerSpecPrev( p )
	end
	
	-- Player requesting to start VR
	if ( value == 100 ) then
		PlayerEnableVR( p )
	end
	
	if ( value == 101 ) then
		PlayerDisableVR( p )
	end
end

net.Receive( "facile_requeststate", RecievePlayerRequest )

concommand.Add( "fa_changelevel", function( p, cmd, args )
	if ( !p:IsAdmin() ) then return end
	
	RunConsoleCommand( "changelevel", args[1] )
end )

concommand.Add( "fa_gravity", function( p, cmd, args )
	if ( !p:IsAdmin() ) then return end
	
	RunConsoleCommand( "sv_gravity", args[1] )
end )

local last_time = 0
local player_GetAll = player.GetAll

function GM:FacileTick()

	--local current_time = RealTime()
	--local delta = current_time - last_time

	for k, p in ipairs( player_GetAll() ) do

		--[[if ( p.vr_mode && p.hmd_position ) then
			local player_pos = p:GetPos()

			if ( IsValid( p.vr_view_entity ) ) then
				p.vr_view_entity:SetPos( player_pos + p.hmd_position )
				p.vr_view_entity:SetAngles( p.hmd_angles )
			end

		end]]
		
		if ( p.vr_mode ) then
			local player_pos = p:GetPos()
			
			local pinfo_hmd_pos = p:GetInfo( "favr_hmd_pos" )
			local pinfo_hmd_ang = p:GetInfo( "favr_hmd_ang" )
			
			local hmd_pos = Vector( pinfo_hmd_pos )
			local hmd_ang = Angle( pinfo_hmd_ang )
			
			p.hmd_position = hmd_pos
			p.hmd_angles = hmd_ang
			
			if ( IsValid( p.vr_view_entity ) ) then
				p.vr_view_entity:SetPos( player_pos + hmd_pos )
				p.vr_view_entity:SetAngles( hmd_ang )
			end
			
		end

	end

end

--[[
	Fixs! A lot of maps don't have the right settings for their entities so lets fix that!
	
	Update water lods??
	
	Fix fog for maps
]]
--local sun_material = Material( "sprites/light_glow02_add_noz" )

hook.Add( "InitPostEntity", "facilefixs", function()
	local ent_environments = ents.FindByClass( "light_environment" )
	local ent_shadow_controls = ents.FindByClass( "shadow_control" )
	local ent_suns = ents.FindByClass( "env_sun" )
	
	local main_sky_pitch = -24
	local main_sky_angles = Angle(0, 120, 0)
	local main_sky_brightness = Color(255, 255, 255, 200)
	local main_sky_ambient = Color(255, 255, 255, 20)
	
	local valid_light_env = false
	local main_light_env = nil
	
	if ( #ent_environments > 0 ) then
		valid_light_env = true
		main_light_env = ent_environments[1]
		
		if ( main_light_env.ambient ) then
			local pieces = string.Split( main_light_env.ambient, " " )
			
			if (#pieces == 4) then
				main_sky_ambient = Color( pieces[1], pieces[2], pieces[3], pieces[4] )
			end
		end
		
		if ( main_light_env.light ) then
			local pieces = string.Split( main_light_env.light, " " )
			
			if (#pieces == 4) then
				main_sky_brightness = Color( pieces[1], pieces[2], pieces[3], pieces[4] )
			end
		end
		
		if ( main_light_env.pitch ) then
			main_sky_pitch = tonumber( main_light_env.pitch )
		else
			main_sky_pitch = -85
		end
		
		main_sky_angles = main_light_env:GetAngles()
	else
		print("(Facile)", "No lighting entity!")
	end
	
	local main_shadow_control = nil
	local main_sun = nil
	local main_sun_valid = false
	
	if ( #ent_shadow_controls > 0 ) then
		main_shadow_control = ent_shadow_controls[1]
	else
		main_shadow_control = ents.Create( "shadow_control" )
		
		main_shadow_control:Spawn()
		
		print("(Facile)", "No shadow entity!")
	end
	
	if ( #ent_suns > 0 ) then
		main_sun = ent_suns[1]
		
		main_sun_valid = true
	else
		-- Spawns! But doesn't setup any materials or anything correctly
		-- TODO: Bug report?
		
		--[[main_sun = ents.Create( "env_sun" )
		
		main_sun:SetKeyValue( "material", "sprites/light_glow02_add_noz" )
		main_sun:SetKeyValue( "overlaymaterial", "sprites/light_glow02_add_noz" )
		
		main_sun:SetKeyValue( "overlaysize", "-1" )
		main_sun:SetKeyValue( "overlaycolor", "0 0 0" )
		main_sun:SetKeyValue( "HDRColorScale", "1.0" )
		main_sun:SetKeyValue( "rendercolor", "100 80 80" )
		main_sun:SetKeyValue( "size", "16" )
		main_sun:SetKeyValue( "use_angles", "1" )
		
		main_sun:SetMaterial( "sprites/light_glow02_add_noz" )
		
		main_sun:Spawn()
		
		main_sun_valid = true]]
		
		print("(Facile)", "No sun entity!")
	end
	
	main_shadow_control:SetKeyValue( "color", Format("%i %i %i", main_sky_ambient.r * 0.5, main_sky_ambient.g * 0.5, main_sky_ambient.b * 0.5) )
	
	main_shadow_control:SetKeyValue( "angles", Format("%f %f %f", main_sky_pitch * -1, main_sky_angles[2], 0) )
	main_shadow_control:SetKeyValue( "disableallshadows", "0" )
	main_shadow_control:SetKeyValue( "distance", "48" )
	main_shadow_control:SetKeyValue( "enableshadowsfromlocallights", "1" )
	
	if ( main_sun_valid ) then
		local better_angle = Angle(main_sky_pitch, main_sky_angles[2] - 180, 0)
		
		-- GMOD has it's own keyvalue to use
		main_sun:SetKeyValue( "sun_dir", tostring( better_angle:Forward() ) )
	end
	
	-- 
	-- Next up! Try to fix cubemaps to use a real time thing?? HMM... Then try to fix all the fog to use the skybox
	-- 
	
	--local ent_fog_controller = ents.FindByClass( "env_fog_controller" )
end )