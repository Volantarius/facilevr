AddCSLuaFile( "cl_vdmhud.lua" )
AddCSLuaFile( "cl_hud.lua" )

AddCSLuaFile( "cl_notify.lua" )
AddCSLuaFile( "cl_music.lua" )
AddCSLuaFile( "cl_init.lua" )

AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "map_manager.lua" )
include( "pickup_manager.lua" )
include( "sv_playerdeath.lua" )
include( "sv_roundlogic.lua" )
include( "sv_hl2dm.lua" )

hook.Add( "Initialize", "VDMInit", function()
	util.AddNetworkString( "vdm_hitmarker" )
	
	util.AddNetworkString( "vdmn_genericnotify" )
	util.AddNetworkString( "vdmn_gametypechange" )
	util.AddNetworkString( "vdmn_loadoutchange" )
	util.AddNetworkString( "vdmn_notifygame" )
	util.AddNetworkString( "vdmn_updateteams" )
	
	--util.AddNetworkString( "vdmn_queuetrack" )
	--util.AddNetworkString( "vdmn_roundmusic" )
	
	util.AddNetworkString( "vdmn_gm_setup" )
	util.AddNetworkString( "vdmn_gm_shutdown" )
	
	RunConsoleCommand("sv_stopspeed", "75")
	RunConsoleCommand("sv_friction", "4")
	RunConsoleCommand("sv_accelerate", "5")
	RunConsoleCommand("sv_airaccelerate", "0")
	RunConsoleCommand("sv_gravity", "800")
	RunConsoleCommand("sv_sticktoground", "0")
	
	-- We want these on all the time
	RunConsoleCommand("ai_disabled", "0")
	RunConsoleCommand("ai_ignoreplayers", "0")
	RunConsoleCommand("ai_serverragdolls", "0")
	RunConsoleCommand("npc_citizen_auto_player_squad", "0")
end )

-- Anyone who leaves should reset their movement con variables
hook.Add( "PlayerDisconnected", "VdmDisconnectFix", function( ply )
	ply:ConCommand("sv_stopspeed 75")
	ply:ConCommand("sv_friction 4")
	ply:ConCommand("sv_accelerate 5")
	ply:ConCommand("sv_airaccelerate 0")
	ply:ConCommand("sv_gravity 800")
	ply:ConCommand("sv_sticktoground 0")
end )

hook.Add( "ShutDown", "VdmShutdown", function()
	RunConsoleCommand("sv_stopspeed", "10")
	RunConsoleCommand("sv_friction", "8")
	RunConsoleCommand("sv_accelerate", "10")
	RunConsoleCommand("sv_airaccelerate", "10")
	RunConsoleCommand("sv_gravity", "600")
	RunConsoleCommand("sv_sticktoground", "1")
end )

concommand.Add( "vdm_coop_respawn", function( p, cmd, args )
	if ( !p:IsAdmin() ) then return end
	
	RunConsoleCommand( "sv_vdm_coop_respawn", args[1] )
end )

local player_GetAll, vdmGameTypeCV = player.GetAll, GetConVar( "sv_vdm_gametype" )

function GM:CleanUpTeams()
	local gametype_current = vdmGameTypeCV:GetString()
	local gameinfo = table.Copy(g_VdmGameTypes[ gametype_current ])
	
	for player_id,pl in ipairs( player_GetAll() ) do
		if ( IsValid( pl ) ) then
			local player_team = pl:Team()
			
			local joinable = false
			
			if ( gameinfo.OneTeam ) then
				if ( player_team == TEAM_PLAYER ) then
					joinable = true
				end
			else
				if ( player_team == TEAM_CT ) then
					joinable = true
				elseif ( player_team == TEAM_T ) then
					joinable = not gameinfo.ControlledTeam
				end
			end
			
			-- Don't include TEAM_UNASSIGNED..
			if ( player_team > 0 && player_team < 1001 && !joinable ) then
				local best_team = GAMEMODE:BestAutoTeam()
				
				-- If a player is in a unjoinable team, like the dummy team flag we need to move them out
				if ( best_team < 1001 && best_team > 0 ) then
					GAMEMODE:PlayerJoinTeam( pl, best_team )
					
					pl.LastTeamSwitch = 0
				end
			end
		end
	end
	
end

-- Sort by least amount of kills on team for a player
-- And call our BestAutoTeam, then move them! until the teams are return the same team for those teams lol
--[[function GM:BalanceTeams()
	
end]]

-- This is for gametypes to override setting up dummy teams or rebalance or hostages..
-- We can for example have CS:S, and then pick a player to be a hostage on TEAM_PLAYER!
function GM:SetupGameTeams()
	
end

-- (2022) Now uses our best team function
function GM:PlayerInitialSpawn( pl, transition )
	pl:KillSilent()
	
	pl:SetTeam( TEAM_SPECTATOR )
	
	pl.LastTeamSwitch = nil
	
	if ( pl:IsBot() ) then
		GAMEMODE:PlayerRequestTeam( pl, GAMEMODE:BestAutoTeam() )-- Different from Facile
		
		return
	end
end

-- (2022) Updated to check if the team balance is bad
-- Also to prevent the protected teams from being joinable, which doesn't fully protect that
function GM:PlayerCanJoinTeam( pl, teamid )
	
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches || 10
	
	if ( pl.LastTeamSwitch && RealTime() - pl.LastTeamSwitch < TimeBetweenSwitches ) then
		pl.LastTeamSwitch = pl.LastTeamSwitch + 1
		
		pl:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - pl.LastTeamSwitch ) ) + 1 ) )
		
		return false
	end
	
	local current_team = pl:Team()
	
	if ( current_team == teamid ) then
		pl:ChatPrint( "You're already on that team" )
		
		return false
	end
	
	local gametype_current = vdmGameTypeCV:GetString()
	local gameinfo = table.Copy(g_VdmGameTypes[ gametype_current ])
	
	-- Make sure controlled games keep their team lol
	if ( !gameinfo.OneTeam and gameinfo.ControlledTeam and current_team == TEAM_T and teamid != current_team ) then
		pl:ChatPrint( "You can't leave us!" )
		
		return false
	end
	
	-- If BestAutoTeam says you should join CT for example and the player wants T
	-- then this is a bad balance choice!
	if ( teamid > 0 && teamid < 1001 && teamid != GAMEMODE:BestAutoTeam() ) then
		pl:ChatPrint( "Team has too many players!" )
		
		return false
	end
	
	return true
	
end

function GM:PlayerHurt( ply, attacker, healthleft, healthtaken )
	if ( attacker:IsPlayer() && ply:IsPlayer() ) then
		if ( ply ~= attacker ) then
			net.Start( "vdm_hitmarker" )
			net.Send( attacker )
		end
	end
end

local vdmGameTypeCV = GetConVar( "sv_vdm_gametype" )

function GM:PlayerDeathSound( pl )
	return true
end

--local sfx_death = Sound( "NPC_Stalker.ScreamTrainCar" )
local sfx_death_silly = Sound( "Vol_GE_Silly.Single" )
local sfx_death_light = Sound( "Vol_GE_Reaction.Single" )

-- This is our better death call, that has logic from the different ways players can die
function GM:VdmPlayerDeathSound( pl, dmginfo )
	local pos = pl:GetShootPos()
	
	--[[if ( dmginfo:GetDamage() > 160 ) then
		--pl:EmitSound( sfx_death_silly )
		sound.Play( sfx_death_silly, pos )
	else
		--pl:EmitSound( sfx_death_light )
		sound.Play( sfx_death_light, pos )
	end]]
	
	sound.Play( sfx_death_light, pos )
	
end

--[[function GM:OnDamagedByExplosion( ply, dmginfo )
	return true
end]]

local sfx_hurt_test = Sound( "VdmCharacter_Taki.Hurt" )

-- Armor modification finalize, for cs:s styled damage
function GM:PostEntityTakeDamage( ent, dmginfo, took )
	if ( ent:IsPlayer() ) then
		
		--[[if ( took && ent:Alive() ) then
			ent:EmitSound( sfx_hurt_test )
		end]]
		
		-- Thats more like it
		if ( ent.vvArmorValue ) then
			ent:SetArmor( ent.vvArmorValue )
			ent.vvArmorValue = nil
		end
	end
end

--Source engine fcap variables
-- FCAP_IMPULSE_USE = 16
-- FCAP_CONTINUOUS_USE = 32
-- FCAP_ONOFF_USE = 64
-- FCAP_DIRECTIONAL_USE = 128
hook.Add( "PlayerUse", "hl2dmUseSounds", function( ply, ent )
	if ( ply:KeyPressed( IN_USE ) ) then
		local caps = ent:ObjectCaps()
		local useable = bit.band(caps,16) + bit.band(caps,32) + bit.band(caps,64) + bit.band(caps,128)
		
		local mvtype = true
		
		if ( ent:GetMoveType() == MOVETYPE_VPHYSICS ) then -- If physical, check if we can pickup
			mvtype = GAMEMODE:AllowPlayerPickup(ply, ent) -- If not then don't play the use sound
		end
		
		if ( IsValid(ent) and (useable > 0) and mvtype ) then
			ply:EmitSound( "HL2Player.Use" )
		end
	end
end )

local entsFindByClass = ents.FindByClass
local nwidtostr = util.NetworkIDToString

local cvWeaponsRemoveOnCleanup = CreateConVar("sv_vdm_removeoncleanup_weapons", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Remove weapons on cleanup.", 0, 1)
local cvChargersRemoveOnCleanup = CreateConVar("sv_vdm_removeoncleanup_chargers", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Remove chargers on cleanup.", 0, 1)

function GM:PostCleanupMap()
	local removeThese = {}
	
	if ( cvWeaponsRemoveOnCleanup:GetBool() ) then
		removeThese = table.Add( removeThese, entsFindByClass("weapon_*") )
		removeThese = table.Add( removeThese, entsFindByClass("ammo_*") )
		removeThese = table.Add( removeThese, entsFindByClass("item_ammo_*") )
		removeThese = table.Add( removeThese, entsFindByClass("item_box_buckshot") )
		removeThese = table.Add( removeThese, entsFindByClass("item_rpg_round") )
		removeThese = table.Add( removeThese, entsFindByClass("item_battery") )
		removeThese = table.Add( removeThese, entsFindByClass("item_healthkit") )
		removeThese = table.Add( removeThese, entsFindByClass("item_healthvial") )
		removeThese = table.Add( removeThese, entsFindByClass("item_longjump") )
	end
	
	if ( cvChargersRemoveOnCleanup:GetBool() ) then
		removeThese = table.Add( removeThese, entsFindByClass("func_healthcharger") )
		removeThese = table.Add( removeThese, entsFindByClass("func_recharge") )
		removeThese = table.Add( removeThese, entsFindByClass("item_healthcharger") )
		removeThese = table.Add( removeThese, entsFindByClass("item_suitcharger") )
	end
	
	for k,e in pairs( removeThese ) do
		e:Remove()
	end
	
	removeThese = nil
end

-- Just in case we need this later
--[[function GM:PrepPlayer( pl )
	pl:StripWeapons()
	pl:StripAmmo()
	pl:Spawn()
	pl:Freeze( true )
end]]

local cvSalvageWeapons = CreateConVar("sv_vdm_salvageweapons", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow players to pick up weapons for ammo.", 0, 1)

function GM:PlayerCanPickupWeapon( ply, ent )
	local salvage = cvSalvageWeapons:GetBool()
	
	if ( not salvage ) then
		return not ( ply:GetWeapon(ent:GetClass()):IsValid() )
	end
	
	return true
end

-- @Note: Weapons also need the WEAPON:EquipAmmo to account for salvaging weapons for all the ammo
-- CS:S ammo saving on dropped weapons feature!
function GM:PlayerDroppedWeapon( pl, weapon )
	if ( IsValid( pl ) ) then
		if ( pl:IsPlayer() ) then
			local alive = pl:Alive()-- Will return false if the player has dropped on death
			
			-- Only drop all the ammo on death, CS:S I do believe doesn't drop the player's ammo
			if ( !alive ) then
				weapon.ammo = pl:GetAmmoCount( weapon:GetPrimaryAmmoType() )
			end
		end
	end
end

-- @Note: Only when this is a new weapon for the player, otherwise WEAPON:EquipAmmo is called
function GM:WeaponEquip( weapon, pl )
	if ( IsValid( pl ) && weapon.ammo ~= nil ) then
		pl:GiveAmmo( weapon.ammo, weapon:GetPrimaryAmmoType() )
		
		weapon.ammo = 0
	end
end

local fall_fatal = 1100
local fall_maxsafe = 580
local fall_damage = 100 / ( fall_fatal - fall_maxsafe )

function GM:GetFallDamage( pl, flFallSpeed )
	--local pId = pl:GetClassID()
	--local pClass = nwidtostr(pId)
	
	--[[if ( pClass == "player_vdm_hidden" ) then
		return 0
	end]]
	
	return math.max( (flFallSpeed - fall_maxsafe) * fall_damage * 1.25, 0 )
end

-- @TODO: ConVar
function GM:AllowPlayerPickup( pl, object )
	return false
end