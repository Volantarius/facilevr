DeriveGamemode( "facile" )

TEAM_PLAYER = 1-- Or 3, both should somehow share this value... urrrp
TEAM_T = 2
TEAM_CT = 3

include( "obj_player_extend.lua" )
include( "sh_player.lua" )

-- Idea to initialize all of the game logic for a gametype and shut it down on the fly (override functions on the fly)
include( "games/hl2dm.lua" )
include( "games/hidden.lua" )
include( "games/deathrun.lua" )

include( "player_class/player_vdm.lua" )
include( "player_class/player_vdm_default.lua" )
include( "player_class/player_vdm_broyal.lua" )
include( "player_class/player_vdm_cs.lua" )

include( "player_class/player_vdm_death.lua" )
include( "player_class/player_vdm_runner.lua" )

include( "player_class/player_vdm_hidden.lua" )
include( "player_class/player_vdm_fart.lua" )
include( "player_class/player_vdm_halflife.lua" )

include( "player_class/player_vdm_ball.lua" )

include( "player_class/player_vdm_vr.lua" )

GM.Name 		= "Volantarius' Deathmatch"
GM.Author 		= "Volantarius"
GM.Email 		= ""
GM.Website 		= ""

GM.AllowAutoTeam 	= false

GM.NoPlayerTeamDamage = false

GM.EnableFreezeCam = true

GM.MaximumDeathLength = 11
GM.MinimumDeathLength = 1

GM.NoAutomaticSpawning = false

GM.CanOnlySpectateOwnTeam = false

--[[=================================================================================]]

local vdmGameTypeCV = CreateConVar( "sv_vdm_gametype", "deathmatch", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_LUA_SERVER }, "Do not change directly!" )

CreateConVar( "sv_vdm_coop_respawn", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_LUA_SERVER }, "Allow spawning during coop gameplay.", 0, 1 )
CreateConVar( "sv_vdm_playertrails", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_LUA_SERVER }, "Force players spawn with or without trails.", 0, 5 )

-- hostage_entity for hostage spawns lol
-- Need to account for Team Fortress 'info_player_teamspawn' and its team value I THINK

g_VdmGameTypes = {
	["deathmatch"] = {
		TeamPlayerSpawns = {"info_player_teamspawn", "info_player_deathmatch", "vdm_player_spawn", "info_player_start"},
		
		TeamPlayerClasses = {"player_vdm_default"},
		
		AllowTrails = false,
		SaveLoadout = false,
		
		CustomSpawns = true,
		CustomWeapons = true,
		CustomPowerups = true,
		
		OneTeam = true,
		ControlledTeam = false,
		NoPlayerTeamDamage = false,
		
		PrintName = "Deathmatch"
	},
	
	["fartcops"] = {
		TeamPlayerSpawns = {"info_player_teamspawn", "info_player_deathmatch", "vdm_player_spawn", "info_player_start"},
		
		TeamPlayerClasses = {"player_vdm_fart"},
		
		RoundTime = 3,
		
		AllowTrails = true,
		SaveLoadout = false,
		
		CustomSpawns = true,
		CustomWeapons = true,
		CustomPowerups = true,
		
		OneTeam = true,
		ControlledTeam = false,
		NoPlayerTeamDamage = false,
		
		PrintName = "Fart Cops"
	},
	
	["teamdeathmatch"] = {
		TeamTSpawns = {"info_player_terrorist", "info_player_combine", "info_player_axis"},
		TeamCTSpawns = {"info_player_counterterrorist", "info_player_rebel", "info_player_allies"},
		
		TeamTClasses = {"player_vdm_default"},
		TeamCTClasses = {"player_vdm_default"},
		
		TeamTName = "Terrorists",
		TeamCTName = "Counter-Terrorists",
		
		AllowTrails = false,
		SaveLoadout = false,
		
		CustomSpawns = true,
		CustomWeapons = true,
		CustomPowerups = true,
		
		OneTeam = false,
		ControlledTeam = false,
		NoPlayerTeamDamage = false,
		
		PrintName = "Team Deathmatch"
	},
	
	--[[	REMEMBER TO DUPLICATE THE GAMETYPE IN ROUNDLOGIC and setup the logic for the gametype!!!	]]
	
	--[[["battleroyal"] = {
		TeamPlayerSpawns = VDM_TEAM_PLAYER_SPAWNPOINTS,
		
		TeamPlayerClasses = {"player_vdm_broyal"},
		
		RoundTime = 3,
		
		AllowTrails = false,
		SaveLoadout = false,
		
		CustomSpawns = true,
		CustomWeapons = false,
		CustomPowerups = false,
		
		OneTeam = true,
		ControlledTeam = false,
		NoPlayerTeamDamage = false,
		
		PrintName = "Battle Royal"
	},]]
	
	-- Or just a COOP thing that can have a console command to enable/disable coop respawns
	-- Although bhop may have a few custom things for respawning..
	["coop"] = {
		TeamPlayerSpawns = {"info_player_teamspawn", "info_player_deathmatch", "vdm_player_spawn", "info_player_start"},
		
		--TeamPlayerClasses = { "player_vdm_halflife" },
		TeamPlayerClasses = { "player_vdm_cs" },
		
		AllowTrails = true,
		SaveLoadout = false,
		
		CustomSpawns = false,
		CustomWeapons = false,
		CustomPowerups = false,
		
		OneTeam = true,
		ControlledTeam = false,
		NoPlayerTeamDamage = true,
		
		PrintName = "Co-Op"
	},
	
	["cs"] = {
		TeamTSpawns = {"info_player_terrorist", "info_player_combine", "info_player_axis"},
		TeamCTSpawns = {"info_player_counterterrorist", "info_player_rebel", "info_player_allies"},
		
		TeamTClasses = {"player_vdm_cs"},
		TeamCTClasses = {"player_vdm_cs"},
		
		TeamTName = "Terrorists",
		TeamCTName = "Counter-Terrorists",
		
		AllowTrails = false,
		SaveLoadout = true,
		
		CustomSpawns = false,
		CustomWeapons = false,
		CustomPowerups = false,
		
		OneTeam = false,
		ControlledTeam = false,
		NoPlayerTeamDamage = true,
		
		PrintName = "Counter-Strike"
	},
	
	["csdm"] = {
		TeamPlayerSpawns = {
		"info_player_terrorist",
		"info_player_combine",
		"info_player_axis",
		"info_player_counterterrorist",
		"info_player_rebel",
		"info_player_allies",
		"info_player_teamspawn",
		"info_player_deathmatch",
		"vdm_player_spawn"
		},
		
		TeamTSpawns = {"info_player_terrorist", "info_player_combine", "info_player_axis"},
		TeamCTSpawns = {"info_player_counterterrorist", "info_player_rebel", "info_player_allies"},
		
		TeamTClasses = {"player_vdm_cs"},
		TeamCTClasses = {"player_vdm_cs"},
		TeamPlayerClasses = {"player_vdm_cs"},
		
		TeamTName = "Terrorists",
		TeamCTName = "Counter-Terrorists",
		
		AllowTrails = true,
		SaveLoadout = false,
		
		-- @Todo: Change later! Maybe???
		CustomSpawns = false,
		CustomWeapons = false,
		CustomPowerups = false,
		
		OneTeam = true,
		ControlledTeam = false,
		NoPlayerTeamDamage = false,
		
		PrintName = "CS:DM"
	},
	
	["deathrun"] = {
		TeamTSpawns = {"info_player_terrorist", "info_player_combine", "info_player_axis"},
		TeamCTSpawns = {"info_player_counterterrorist", "info_player_rebel", "info_player_allies"},
		
		TeamTClasses = { "player_vdm_death" },
		TeamCTClasses = { "player_vdm_runner" },
		
		TeamTName = "Deaths",
		TeamCTName = "Runners",
		
		RoundTime = 5,
		
		AllowTrails = true,
		SaveLoadout = true,
		
		CustomSpawns = false,
		CustomWeapons = true,
		CustomPowerups = true,
		
		OneTeam = false,
		ControlledTeam = true,-- Sets OpFor to be unjoinable
		NoPlayerTeamDamage = true,
		
		Startup = GM.SetupDeathrunRules,
		Shutdown = GM.ShutdownDeathrunRules,
		
		PrintName = "Deathrun"
	},
	
	["testgamewithquotes"] = {
		TeamPlayerSpawns = {
		"info_player_terrorist",
		"info_player_combine",
		"info_player_axis",
		"info_player_counterterrorist",
		"info_player_rebel",
		"info_player_allies",
		"info_player_teamspawn",
		"info_player_deathmatch",
		"vdm_player_spawn"
		},
		TeamTSpawns = nil,-- Will be skipped if one team
		TeamCTSpawns = nil,
		
		TeamPlayerClasses = {"player_vdm_default", "player_vdm_broyal", "player_vdm", "player_vdm_cs", "player_vdm_hidden", "player_vdm_halflife", "player_vdm_ball", "player_vdm_vr"},
		TeamTClasses = nil,-- Will be skipped if one team
		TeamCTClasses = nil,
		
		-- Are not tied!
		AllowTrails = true,
		SaveLoadout = false,
		
		CustomSpawns = true,
		CustomWeapons = true,
		CustomPowerups = true,
		
		OneTeam = true,
		ControlledTeam = false,-- Will set OpFor team as non joinable, and allow the gametype to assign Opfor
		NoPlayerTeamDamage = false,
		
		Startup = GM.SetupHalfLifeRules,
		Shutdown = GM.ShutdownHalfLifeRules,
		
		PrintName = "test game with quotes"
	}
}

function GM:DetermineBestAutoTeam( alive_players, alive_t, alive_ct )
	local gametype_current = vdmGameTypeCV:GetString()
	local gameinfo = table.Copy(g_VdmGameTypes[ gametype_current ])
	
	if ( gameinfo.OneTeam ) then
		return TEAM_PLAYER
	else
		if ( gameinfo.ControlledTeam ) then
			
			return TEAM_CT
			
		else
			
			local current_balance = 1
			
			if ( alive_ct > 0 ) then
				current_balance = alive_t / alive_ct
			end
			
			-- Here we can set the balance with a percentage!
			if ( current_balance >= 0.5 ) then
				-- Too many opfor
				return TEAM_CT
			else
				-- Too many blufor
				return TEAM_T
			end
		end
	end
	
	-- If nothing worked spectate lol
	return TEAM_SPECTATOR
end

-- Use this to replace the default team.BestAutoJoinTeam
function GM:BestAutoTeam()
	local alive_players = 0
	local alive_t = 0
	local alive_ct = 0
	
	for player_id,pl in pairs( player.GetAll() ) do
		if ( IsValid( pl ) ) then
			local player_team = pl:Team()
			
			if ( player_team == TEAM_PLAYER ) then
				
				alive_players = alive_players + 1
				
			elseif ( player_team == TEAM_T ) then
				
				alive_t = alive_t + 1
				
			elseif ( player_team == TEAM_CT ) then
				
				alive_ct = alive_ct + 1
				
			end
		end
	end
	
	local best_team = GAMEMODE:DetermineBestAutoTeam( alive_players, alive_t, alive_ct )
	
	return best_team
end

local function teamsSetupPlayer( joinable )
	team.SetUp( TEAM_PLAYER, "Grunts", Color( 0, 190, 0 ), joinable )
end

local function teamsSetupForces( joinable, ControlledTeam )
	local opfor_join = joinable
	
	-- (2022) Allow Opfor to be used for assigning randomly chosen players
	if ( joinable && ControlledTeam ) then
		opfor_join = false
	end
	
	team.SetUp( TEAM_T, "OpFor", Color( 255, 151, 0 ), opfor_join )
	team.SetUp( TEAM_CT, "BluFor", Color( 31, 151, 255 ), joinable )
end

function GM:VDMSetTeamOne( spawnClasses, playerClasses )
	teamsSetupPlayer( true )
	teamsSetupForces( false, false )
	
	team.SetSpawnPoint( TEAM_PLAYER, spawnClasses )
	
	team.SetClass( TEAM_PLAYER, playerClasses )
end

function GM:VDMSetTeamTwo( TspawnClasses, TplayerClasses, CTspawnClasses, CTplayerClasses, ControlledTeam )
	teamsSetupPlayer( false )
	teamsSetupForces( true, ControlledTeam )
	
	team.SetSpawnPoint( TEAM_T, TspawnClasses )
	team.SetSpawnPoint( TEAM_CT, CTspawnClasses )
	
	team.SetClass( TEAM_T, TplayerClasses )
	team.SetClass( TEAM_CT, CTplayerClasses )
end

local defColor = Color( 255, 70, 70 )

function GM:UpdateTeams( notify )
	local gametype_current = vdmGameTypeCV:GetString()
	
	--if CLIENT then print( gametype_current ) end
	
	local gameinfo = table.Copy(g_VdmGameTypes[ gametype_current ])
	
	if ( CLIENT and notify ) then
		local teamName = "Single Team"
		
		if ( not gameinfo.OneTeam ) then
			teamName = "Multiple Teams"
		end
		
		chat.AddText( defColor, "(VDM)", color_white, " Changed game team set to ", defColor, teamName, color_white, ", please join a new team!" )
		surface.PlaySound( "volantarius/mxp/max_tip.wav" )
	end
	
	GAMEMODE.NoPlayerTeamDamage = gameinfo.NoPlayerTeamDamage
	
	if ( gameinfo.OneTeam ) then
		GAMEMODE:VDMSetTeamOne( gameinfo.TeamPlayerSpawns, gameinfo.TeamPlayerClasses )
	else
		GAMEMODE:VDMSetTeamTwo( gameinfo.TeamTSpawns, gameinfo.TeamTClasses, gameinfo.TeamCTSpawns, gameinfo.TeamCTClasses, gameinfo.ControlledTeam )
	end
end

if CLIENT then
	--net.Receive( "vdmn_updateteams", function(len) hook.Call( "UpdateTeams", GAMEMODE, net.ReadBool() ) end )
	net.Receive( "vdmn_updateteams", function(len) GAMEMODE:UpdateTeams( net.ReadBool() ) end )
end

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end
	
	teamsSetupPlayer(true)
	teamsSetupForces(false)
	
	-- This works for using point_viewcontrol
	team.SetSpawnPoint( TEAM_SPECTATOR, {"point_viewcontrol", "ttt_spectator_spawn"} )
	
	team.SetSpawnPoint( TEAM_PLAYER, VDM_TEAM_PLAYER_SPAWNPOINTS )
	team.SetClass( TEAM_PLAYER, VDM_TEAM_PLAYER_PCLASS )
	
	-- Must create all data before hand, so that there is a fallback
	team.SetSpawnPoint( TEAM_T, VDM_TEAM_PLAYER_SPAWNPOINTS )
	team.SetSpawnPoint( TEAM_CT, VDM_TEAM_PLAYER_SPAWNPOINTS )
	team.SetClass( TEAM_T, VDM_TEAM_PLAYER_PCLASS )
	team.SetClass( TEAM_CT, VDM_TEAM_PLAYER_PCLASS )
	
	-- (2021) Finally update all the teams based on gametype for new clients!!
	GAMEMODE:UpdateTeams( false )
end

--[[====	====	====	====]]

sound.Add({
	name = "VdmCharacter_Taki.Death",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = {
		")volantarius/soulcalibur/E_VO_CV_003_103.wav",
		")volantarius/soulcalibur/E_VO_CV_003_104.wav",
		")volantarius/soulcalibur/E_VO_CV_003_105.wav",
		")volantarius/soulcalibur/E_VO_CV_003_106.wav",
		")volantarius/soulcalibur/E_VO_CV_003_107.wav",
		")volantarius/soulcalibur/E_VO_CV_003_108.wav",
		")volantarius/soulcalibur/E_VO_CV_003_110.wav",
		")volantarius/soulcalibur/E_VO_CV_003_111.wav",
		")volantarius/soulcalibur/E_VO_CV_003_112.wav",
		")volantarius/soulcalibur/E_VO_CV_003_113.wav",
		")volantarius/soulcalibur/E_VO_CV_003_115.wav"
	}
})

sound.Add({
	name = "VdmCharacter_Taki.Hurt",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = {
		")volantarius/soulcalibur/E_VO_CV_003_74.wav",
		")volantarius/soulcalibur/E_VO_CV_003_75.wav",
		")volantarius/soulcalibur/E_VO_CV_003_76.wav",
		")volantarius/soulcalibur/E_VO_CV_003_77.wav"
	}
})

--[[====	====	====	====]]

local translatePM = player_manager.TranslatePlayerModel

-- What model, animation to use in the team select menu, and model color (vector)
GM.TeamSelectModels = {
	[TEAM_PLAYER] = {
		--model = translatePM("stripped"),
		model = translatePM("chell"),
		pose = "pose_standing_01",
		color = Color( 0, 190, 0 ):ToVector()
	},
	
	[TEAM_T] = {
		model = translatePM("css_leet"),
		pose = "pose_standing_01",
		color = Color( 255, 151, 0 ):ToVector()
	},
	
	[TEAM_CT] = {
		model = translatePM("css_gasmask"),
		pose = "pose_standing_01",
		color = Color( 31, 151, 255 ):ToVector()
	}
}

GM.WeaponLoadoutCategories = { CSS = true, VDM = true, ["Half-Life 2"] = true }

-- @Volantarius: Dangerous expirementation going on here!

-- Global Setup
function GM:SetupGameType( gametype_name )
end

-- Global Shutdown
-- This one is important because theres some functions that we need to set to a default all the time
function GM:ShutdownGameType( gametype_name )
	if ( SERVER ) then
		
		function GAMEMODE:SetupGameTeams()
			
		end
		
		function GAMEMODE:CanPlayerSuicide( pl )
			return !GAMEMODE.NoPlayerSuicide
		end
		
		--[[function GAMEMODE:AllowPlayerPickup( pl, object )
			return false
		end]]
		
		-- @Note: Was thinking of using baseclass from VDM, but that will cause recursion. Only facile.
		--[[function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
			return false

			--BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )
		end]]
		
	else
		
		
		
	end
end

function GM:BroadcastSetupGameType( gametype_name )
	if ( SERVER ) then
		net.Start( "vdmn_gm_setup" )
			net.WriteString( gametype_name )
		net.Broadcast()
	end
	
	print("STARTING GAMETYPE:", gametype_name)
	
	GAMEMODE:SetupGameType( gametype_name )
	
	local gameinfo_pointer = g_VdmGameTypes[ gametype_name ]
	
	if ( gameinfo_pointer.Startup ~= nil && gameinfo_pointer.Shutdown ~= nil ) then
		gameinfo_pointer.Startup()
	end
end

function GM:BroadcastShutdownGameType( gametype_name )
	if ( SERVER ) then
		net.Start( "vdmn_gm_shutdown" )
			net.WriteString( gametype_name )
		net.Broadcast()
	end
	
	print("SHUTTING DOWN GAMETYPE:", gametype_name)
	
	GAMEMODE:ShutdownGameType( gametype_name )
	
	local gameinfo_pointer = g_VdmGameTypes[ gametype_name ]
	
	if ( gameinfo_pointer.Shutdown ~= nil && gameinfo_pointer.Startup ~= nil ) then
		gameinfo_pointer.Shutdown()
	end
end

if ( CLIENT ) then
	net.Receive( "vdmn_gm_setup", function(len) hook.Call( "BroadcastSetupGameType", GAMEMODE, net.ReadString() ) end )
	
	net.Receive( "vdmn_gm_shutdown", function(len) hook.Call( "BroadcastShutdownGameType", GAMEMODE, net.ReadString() ) end )
end