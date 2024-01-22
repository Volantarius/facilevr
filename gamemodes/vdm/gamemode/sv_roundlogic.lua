hook.Remove( "Tick", "FacilePhaseTick" )-- Just in case remove the old Facile phase hook

local player_GetAll = player.GetAll

-- (2021) Made sure that only the teams that can be joined get prepped
--[[local function quickPrep()
	for teamId,teamTbl in pairs( team.GetAllTeams() ) do
		if ( teamId > 0 && teamId < 1002 && teamTbl.Joinable ) then
			for k,pl in ipairs( team.GetPlayers(teamId) ) do
				if ( pl:CanRespawn() ) then
					GAMEMODE:PrepPlayer( pl )
				end
			end
		end
	end
end]]

-- (2022) Hidden, Suicide Barrels, Deathrun
-- These all have dummy teams that are controlled by the game!
-- Soooo lets allow unjoinable teams to spawn
-- The round logic now makes sure any unjoinable team gets moved to spectate
local function quickPrep()
	for player_id,pl in ipairs( player_GetAll() ) do
		if ( IsValid( pl ) ) then
			local player_team = pl:Team()
			
			if ( player_team > 0 && player_team < 1001 && pl:CanRespawn() ) then
				GAMEMODE:PrepPlayer( pl )
			end
		end
	end
end

-- Helper to count how many people are waiting to play
-- Skips teams that can't be played
local function waitingToJoin( checkAlive )
	local alive_players = 0
	local alive_t = 0
	local alive_ct = 0
	
	local joinable_players = team.Joinable( TEAM_PLAYER )
	local joinable_t = team.Joinable( TEAM_T )
	local joinable_ct = team.Joinable( TEAM_CT )
	
	for player_id,pl in ipairs( player_GetAll() ) do
		if ( IsValid( pl ) ) then
			local player_team = pl:Team()
			local checked_alive = not pl:Alive()
			local joinable = false
			
			if ( checkAlive ) then
				checked_alive = checkAlive
			end
			
			if ( player_team == TEAM_PLAYER ) then
				
				joinable = joinable_players
				
			elseif ( player_team == TEAM_T ) then
				
				joinable = joinable_t
				
			elseif ( player_team == TEAM_CT ) then
				
				joinable = joinable_ct
				
			end
			
			if ( joinable && checked_alive && pl:CanRespawn() ) then
				if ( player_team == TEAM_PLAYER ) then
					
					alive_players = alive_players + 1
					
				elseif ( player_team == TEAM_T ) then
					
					alive_t = alive_t + 1
					
				elseif ( player_team == TEAM_CT ) then
					
					alive_ct = alive_ct + 1
					
				end
			end
		end
	end
	
	return ( alive_players + alive_t + alive_ct )
end

local function aliveTeamCount()
	local alive_players = 0
	local alive_t = 0
	local alive_ct = 0
	
	for player_id,pl in ipairs( player_GetAll() ) do
		if ( IsValid( pl ) && pl:Alive() ) then
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
	
	return alive_players, alive_t, alive_ct
end

local cvPreroundTime = CreateConVar("sv_vdm_preroundtime", "5", {FCVAR_ARCHIVE}, "Delay before starting a VDM round.", 4, 20)
local cvPostroundTime = CreateConVar("sv_vdm_postroundtime", "3", {FCVAR_ARCHIVE}, "Delay after a VDM round.", 1, 30)

local cvDeathmatchTime = CreateConVar("sv_vdm_deathmatchtime", "1", {FCVAR_ARCHIVE}, "Minutes for each deathmatch type.", 1, 240)
local cvCSTime = CreateConVar("sv_vdm_striketime", "5", {FCVAR_ARCHIVE}, "Minutes for each counter-strike type.", 1, 30)

--local cvPlayerTrails = CreateConVar( "sv_vdm_playertrails", "1", {FCVAR_ARCHIVE}, "Force players spawn with or without trails." )
local cvPlayerTrails = GetConVar( "sv_vdm_playertrails" )
local phaseAllowTrails = false
local phaseAllowRespawn = false
local phaseIsWarmUp = false

local phaseGenerateIndex = 5

local phaseKey = {
	-- Do not duplicate or remove this phase!
	WaitingForPlayers = 0,
	
	RoundStarting = 1,
	RoundWarmup = 2,
	RoundActive = 3,
	RoundOver = 4,
	
	ChangeGameType = 898,
	UpdateTeams = 899,
	DebugStartup = 900,
	DebugPhase = 901
}

-- Seperated from shared so that we can grab phaseKeys easily
-- Probably don't have to touch SHARED actually..
local sv_gameTypes = {
	["deathmatch"] = {
		PhaseIndex = phaseKey.RoundStarting
	},
	
	["teamdeathmatch"] = {
		PhaseIndex = phaseKey.RoundStarting
	},
	
	["csdm"] = {
		PhaseIndex = phaseKey.RoundStarting
	},
	
	["fartcops"] = {
		PhaseIndex = phaseKey.RoundStarting
	},
	
	["testgamewithquotes"] = {
		PhaseIndex = phaseKey.DebugStartup
	}
}

-- Other types have to be defined below.. because LUA

-- Maybe make this visible on clients, but they can't change it of course...
local vdmGameTypeNext = CreateConVar( "sv_vdm_gametypenext", "testgamewithquotes", {FCVAR_ARCHIVE}, "Do not change directly!! Use vdm_changegametype" )

local vdmCoopAllowRespawn = GetConVar( "sv_vdm_coop_respawn" )

-- DO NOT CHANGE DIRECTLY!!!!!!!!
local vdmGameTypeCV = GetConVar( "sv_vdm_gametype" )

local vdmLoadout = GetConVar( "sv_vdm_loadout" )

local function GametypeAutoComplete( cmd, stringargs )
	stringargs = string.Trim(stringargs)
	stringargs = string.lower(stringargs)
	
	local tbl = {}
	
	for k,v in pairs( sv_gameTypes ) do
		if ( string.find( k, stringargs ) ) then
			table.insert(tbl, cmd .. " " .. k)
		end
	end
	
	return tbl
end

local function ChangeGameType( ply, cmd, args, argStr )
	local ass = args[1]
	
	if ( sv_gameTypes[ ass ] == nil ) then
		print("Gametype does not exist!")
		return
	end
	
	local gametypeinfo = sv_gameTypes[ ass ]
	
	-- Save the gametype state for other maps and stuff
	vdmGameTypeNext:SetString( ass )
	
	net.Start("vdmn_gametypechange")
		net.WriteString( ass )
	net.Broadcast()
end

concommand.Add( "vdm_changegametype", function(ply, cmd, args, argStr) ChangeGameType(ply, cmd, args, argStr) end, GametypeAutoComplete, nil, {FCVAR_NONE} )

local phaseCurrent = phaseKey.ChangeGameType

local round = 0
local roundCallDelay = 0 -- Relative to CurTime

local timeToStartPhase = 0
local phaseBreak = false
local phaseChangeTeams = false
local phaseUpdatedGametype = false

local phaseFunc = {
	[ phaseKey.ChangeGameType ] = function( timeNow )
		phaseAllowRespawn = false
		
		phaseChangeTeams = false -- UPDATE
		phaseUpdatedGametype = false
		
		local gametype_next = vdmGameTypeNext:GetString()
		local gametype_current = vdmGameTypeCV:GetString()
		
		local printTeamsNotify = false
		
		local delay = 2
		
		local shGameInfoNext = table.Copy(g_VdmGameTypes[ gametype_next ])
		
		if ( gametype_next ~= gametype_current ) then
			phaseUpdatedGametype = true
			
			local shGameInfo = table.Copy(g_VdmGameTypes[ gametype_current ])
			
			-- SHUTDOWN ANY CURRENT GAME, and the next game will get ran!
			GAMEMODE:BroadcastShutdownGameType( gametype_current )
			
			if ( shGameInfoNext.OneTeam ~= shGameInfo.OneTeam ) then
				phaseChangeTeams = true
				
				printTeamsNotify = true
			end
			
			-- Switch to next gametype
			-- Update the convar before updating teams
			vdmGameTypeCV:SetString( gametype_next )
			
			GAMEMODE:UpdateTeams()
			
			net.Start("vdmn_updateteams")
				net.WriteBool( printTeamsNotify )
			net.Broadcast()
			
			-- If changed give players a chance to setup
			delay = 0.5
		end
		
		roundCallDelay = timeNow + delay
		
		local next_phase = phaseKey.WaitingForPlayers
		
		if ( phaseUpdatedGametype ) then
			next_phase = phaseKey.UpdateTeams
		end
		
		phaseCurrent = next_phase
	end,
	
	[ phaseKey.UpdateTeams ] = function( timeNow )
		-- When teams change, we must check if all the players have a class thats okay for that team
		-- Otherwise kill and show them the menu
		
		if ( phaseUpdatedGametype ) then
			if ( phaseChangeTeams ) then
				-- Moving players into a new team is already handled below!
				
				-- Enum for show teams on the client!
				net.Start("facile_playerstate")
					net.WriteUInt( 50, 32 )
				net.Broadcast()
				
			else
				
				for player_id,pl in ipairs( player_GetAll() ) do
					if ( not pl:ValidPlayerClass() ) then
						if ( pl:Alive() ) then
							pl:Kill()
						end
						
						pl:SetRespawn( false )
						
						player_manager.ClearPlayerClass( pl )
						
						-- This will determine if the player needs the select class window or not
						-- And handles bots!
						GAMEMODE:PlayerUpdateClasses( pl, pl:Team() )
					end
				end
				
			end
		end
		
		roundCallDelay = timeNow + 1
		
		phaseCurrent = phaseKey.WaitingForPlayers
	end,
	
	[ phaseKey.WaitingForPlayers ] = function( timeNow )
		-- Do NOT duplicate, this is used to start any other phase type
		local gametype_current = vdmGameTypeCV:GetString()
		
		local gametypeInfo = sv_gameTypes[ gametype_current ]
		
		--phaseAllowRespawn = false
		
		if ( waitingToJoin( true ) < 1 ) then
			roundCallDelay = timeNow + 2
			
			GAMEMODE:UpdatePhaseTimer( 0, "Waiting for players" )
			
			-- Allow a chance for gametype to change
			phaseCurrent = phaseKey.ChangeGameType
			
			return
		end
		
		-- Run gametype lua file!
		GAMEMODE:BroadcastSetupGameType( gametype_current )
		
		-- Clean the teams! Make sure no player is stuck in a bad team!
		-- Should this be a function here??? This is very specific to this
		GAMEMODE:CleanUpTeams()
		
		-- Now let the gametype setup the teams
		GAMEMODE:SetupGameTeams()
		
		net.Start("vdmn_genericnotify")
			net.WriteString( "Round starting in 3 seconds!" )
		net.Broadcast()
		
		timeToStartPhase = timeNow + 3
		
		GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Starting" )
		
		phaseCurrent = gametypeInfo.PhaseIndex
	end,
	
	--[[	BASIC GAME PHASES	]]
	[ phaseKey.RoundStarting ] = function( timeNow )
		if ( timeNow < timeToStartPhase ) then
			return
		end
		
		local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
		
		phaseAllowRespawn = true
		
		if ( shGameInfo.AllowTrails ) then
			phaseAllowTrails = shGameInfo.AllowTrails
		end
		
		net.Start("vdmn_notifygame")
			net.WriteString( shGameInfo.PrintName )
			net.WriteString( vdmLoadout:GetString() )
		net.Broadcast()
		
		-- Before cleanup! and before prep!
		--[[if ( shGameInfo.SaveLoadout ) then
			GAMEMODE:SetupSaveLoadout()
		end]]
		
		game.CleanUpMap()
		
		if ( shGameInfo.CustomSpawns || shGameInfo.CustomWeapons || shGameInfo.CustomPowerups ) then
			GAMEMODE:VdmPickupsUpdateLoadout()-- Uhh idk why this is commented out on the main phase
			
			--                     spawns, weapons, powerups
			GAMEMODE:VdmBuildPickups(
				shGameInfo.CustomSpawns || false,
				shGameInfo.CustomWeapons || false,
				shGameInfo.CustomPowerups || false
			)
		end
		
		-- Helper function to prep players in joinable teams
		quickPrep()
		phaseIsWarmUp = true
		
		timeToStartPhase = timeNow + cvPreroundTime:GetInt()
		
		GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Warm up" )
		
		phaseCurrent = phaseKey.RoundWarmup
	end,
	
	[ phaseKey.RoundWarmup ] = function( timeNow )
		if ( timeNow < timeToStartPhase ) then
			return
		end
		
		phaseIsWarmUp = false
		phaseAllowRespawn = true
		
		-- Ok for DM to unfreeze everyone
		for k,pl in ipairs( player_GetAll() ) do
			pl:Freeze( false )
		end
		
		round = round + 1
		
		timeToStartPhase = timeNow + (cvDeathmatchTime:GetInt() * 60)
		
		local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
		
		GAMEMODE:UpdatePhaseTimer( timeToStartPhase, shGameInfo.PrintName )
		
		phaseCurrent = phaseKey.RoundActive
	end,
	
	[ phaseKey.RoundActive ] = function( timeNow )
		local roundActive = timeNow < timeToStartPhase
		
		if ( roundActive ) then
			return
		end
		
		phaseAllowRespawn = false
		
		net.Start("vdmn_genericnotify")
			net.WriteString( "TIME UP!" )
		net.Broadcast()
		
		GAMEMODE:UpdatePhaseTimer( -2, "Time up" )
		
		timeToStartPhase = timeNow + cvPostroundTime:GetInt()
		phaseCurrent = phaseKey.RoundOver
	end,
	
	[ phaseKey.RoundOver ] = function( timeNow )
		if ( timeNow < timeToStartPhase ) then
			return
		end
		
		phaseAllowRespawn = false
		
		-- On gametype change we should do the same.. but with scoreboard
		-- Freeze players??
		-- Maybe a message for who wins with the highest kills etc.
		
		--timeToStartPhase = timeNow + 5
		
		-- Whenever a phase is over, go and change to the next game type if possible
		phaseCurrent = phaseKey.ChangeGameType
	end,
	
	[ phaseKey.DebugStartup ] = function( timeNow )
		phaseAllowRespawn = false
		
		PrintMessage( HUD_PRINTTALK, "Starting debug!" )
		
		game.CleanUpMap()
		
		GAMEMODE:VdmBuildPickups( true, true, true )
		
		roundCallDelay = timeNow + 2
		
		phaseCurrent = phaseKey.DebugPhase
	end,
	
	--[[	DEBUG PHASE 	]]
	[ phaseKey.DebugPhase ] = function( timeNow )
		local pleaseChange = vdmGameTypeNext:GetString() ~= vdmGameTypeCV:GetString()
		
		if (not pleaseChange) then
			phaseAllowRespawn = true
			
			GAMEMODE:UpdatePhaseTimer( -1, "Debugging" )
			
			roundCallDelay = timeNow + 60
			PrintMessage( HUD_PRINTTALK, "Debug phase yo!" )
			return
		end
		
		phaseAllowRespawn = false
		
		PrintMessage( HUD_PRINTTALK, "Leaving debug mode in 3 seconds!" )
		
		roundCallDelay = timeNow + 2
		
		phaseCurrent = phaseKey.ChangeGameType
	end
}

local function RegisterPhase( phaseName, phaseFunction )
	phaseKey[phaseName] = phaseGenerateIndex
	
	phaseFunc[phaseGenerateIndex] = phaseFunction
	
	phaseGenerateIndex = phaseGenerateIndex + 1
end

--[[	----	----	----	----	----	]]

local last_tidyup = CurTime()

local function PhaseTick()
	local curTime = CurTime()
	
	--if ( curTime > roundCallDelay and not phaseBreak ) then
	if ( curTime > roundCallDelay ) then
		
		if ( phaseFunc[phaseCurrent] ~= nil ) then
			
			phaseFunc[phaseCurrent]( curTime )
			
			if ( curTime < (timeToStartPhase - 30) and curTime > last_tidyup ) then
				GAMEMODE:PerformTidyUp()
				
				last_tidyup = curTime + 15
			end
			
		else
			ErrorNoHalt( "(VDM) Could not find phase: ", phaseCurrent )
			
			-- Go back to debug as a fallback
			phaseCurrent = 900
		end
		
	end
	
end

hook.Add( "Tick", "FacilePhaseTick", PhaseTick )

--[[	----	----	----	----	----	]]

--[[
	-- RIGHT so we can use other existing phase logic, we only need the starting logic for gametypes
	-- Well for some, the game length has to be changed sometimes, but still	
	
	battleroyal
	
	--> We can just create the base types:
		LAST MAN STANDING, battleroyal basically
]]

RegisterPhase( "csRoundStarting", function( timeNow )
	if ( timeNow < timeToStartPhase ) then
		return
	end
	
	local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
	
	--phaseAllowRespawn = true
	
	if ( shGameInfo.AllowTrails ) then
		phaseAllowTrails = shGameInfo.AllowTrails
	end
	
	net.Start("vdmn_notifygame")
		net.WriteString( shGameInfo.PrintName )
		net.WriteString( vdmLoadout:GetString() )
	net.Broadcast()
	
	-- Before cleanup! and before prep!
	--[[if ( shGameInfo.SaveLoadout ) then
		GAMEMODE:SetupSaveLoadout()
	end]]
	
	game.CleanUpMap()
	
	if ( shGameInfo.CustomSpawns || shGameInfo.CustomWeapons || shGameInfo.CustomPowerups ) then
		GAMEMODE:VdmPickupsUpdateLoadout()-- Uhh idk why this is commented out on the main phase
		
		--                     spawns, weapons, powerups
		GAMEMODE:VdmBuildPickups(
			shGameInfo.CustomSpawns || false,
			shGameInfo.CustomWeapons || false,
			shGameInfo.CustomPowerups || false
		)
	end
	
	-- Helper function to prep players in joinable teams
	quickPrep()
	phaseIsWarmUp = true
	
	timeToStartPhase = timeNow + cvPreroundTime:GetInt()
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Warm Up" )
	
	phaseCurrent = phaseKey.csRoundWarmup
end )

-- [[	====	====	====	====	====	====	====]]
--     Counter-Strike game type starts here
-- [[	====	====	====	====	====	====	====]]

sv_gameTypes["cs"] = {
	PhaseIndex = phaseKey.csRoundStarting
}

sv_gameTypes["deathrun"] = {
	PhaseIndex = phaseKey.csRoundStarting
}

RegisterPhase( "csRoundWarmup", function( timeNow )
	if ( timeNow < timeToStartPhase ) then
		return
	end
	
	phaseIsWarmUp = false
	phaseAllowRespawn = false
	
	for k,pl in ipairs( player_GetAll() ) do
		pl:Freeze( false )
	end
	
	local alive_players, alive_t, alive_ct = aliveTeamCount()
	
	local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
	
	local gameTime = 5
	
	if ( shGameInfo.RoundTime ) then
		gameTime = shGameInfo.RoundTime
	else
		gameTime = cvCSTime:GetInt()
	end
	
	timeToStartPhase = timeNow + (gameTime * 60)
	
	-- shGameInfo.ControlledTeam
	-- Oh yeah we gotta make sure this is setup lol
	local count_check = (alive_t + alive_ct) < 2
	
	if ( shGameInfo.ControlledTeam ) then
		count_check = alive_ct < 1
	end
	
	if ( count_check ) then
		GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Waiting For Players" )
		
		phaseCurrent = phaseKey.csWaitForPlayers
	else
		GAMEMODE:UpdatePhaseTimer( timeToStartPhase, shGameInfo.PrintName )
		
		round = round + 1
		phaseCurrent = phaseKey.csRoundActive
	end
end )

RegisterPhase( "csWaitForPlayers", function( timeNow )
	local roundActive = timeNow < timeToStartPhase
	
	-- shGameInfo.ControlledTeam
	-- Oh yeah we gotta make sure this is setup lol
	--local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
	
	local alive_players, alive_t, alive_ct = aliveTeamCount()
	
	if ( roundActive && waitingToJoin() < 1 && (alive_t + alive_ct) > 0 ) then
		roundCallDelay = timeNow + 0.5
		
		return
	end
	
	phaseAllowTrails = false
	
	msg = "Draw!"
	
	net.Start("vdmn_genericnotify")
		net.WriteString( msg )
	net.Broadcast()
	
	GAMEMODE:UpdatePhaseTimer( -2, msg )
	
	timeToStartPhase = timeNow + cvPostroundTime:GetInt()
	
	phaseCurrent = phaseKey.RoundOver
end )

RegisterPhase( "csRoundActive", function( timeNow )
	local roundActive = timeNow < timeToStartPhase
	
	local alive_players, alive_t, alive_ct = aliveTeamCount()
	
	if ( roundActive && alive_t > 0 && alive_ct > 0 ) then return end
	
	local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
	
	-- @Todo: Add gametype based function for checking to end the round
	
	local msg = "Uhhh what"
	
	if ( alive_t == 0 ) then
		msg = shGameInfo.TeamCTName .. " win!"
		team.AddScore( TEAM_CT, 1 )
		
	elseif ( alive_ct == 0 ) then
		msg = shGameInfo.TeamTName .. " win!"
		team.AddScore( TEAM_T, 1 )
		
	elseif ( !roundActive ) then
		--msg = "Time up!"
		msg = shGameInfo.TeamTName .. " win!"-- Like in CS:S
		team.AddScore( TEAM_T, 1 )
		
	end
	
	net.Start("vdmn_genericnotify")
		net.WriteString( msg )
	net.Broadcast()
	
	phaseAllowTrails = false
	
	GAMEMODE:UpdatePhaseTimer( -2, msg )
	
	timeToStartPhase = timeNow + cvPostroundTime:GetInt()
	
	-- Use the default round over since theres nothing really else we need
	phaseCurrent = phaseKey.RoundOver
end )

--[[	----	----	----	----	----	]]
--[[	----	----	----	----	----	]]

RegisterPhase( "coopRoundStarting", function( timeNow )
	if ( timeNow < timeToStartPhase ) then
		return
	end
	
	local shGameInfo = table.Copy( g_VdmGameTypes[ vdmGameTypeCV:GetString() ] )
	
	phaseAllowRespawn = true
	
	if ( shGameInfo.AllowTrails ) then
		phaseAllowTrails = shGameInfo.AllowTrails
	end
	
	net.Start("vdmn_notifygame")
		net.WriteString( shGameInfo.PrintName )
		net.WriteString( vdmLoadout:GetString() )
	net.Broadcast()
	
	-- Don't need to save loadouts
	
	game.CleanUpMap()
	
	if ( shGameInfo.CustomSpawns || shGameInfo.CustomWeapons || shGameInfo.CustomPowerups ) then
		GAMEMODE:VdmPickupsUpdateLoadout()-- Uhh idk why this is commented out on the main phase
		
		--                     spawns, weapons, powerups
		GAMEMODE:VdmBuildPickups(
			shGameInfo.CustomSpawns || false,
			shGameInfo.CustomWeapons || false,
			shGameInfo.CustomPowerups || false
		)
	end
	
	quickPrep()
	phaseIsWarmUp = true
	
	timeToStartPhase = timeNow + cvPreroundTime:GetInt()
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Warm Up" )
	
	phaseCurrent = phaseKey.coopRoundWarmup
end )

sv_gameTypes["coop"] = {
	PhaseIndex = phaseKey.coopRoundStarting
}

RegisterPhase( "coopRoundWarmup", function( timeNow )
	if ( timeNow < timeToStartPhase ) then
		return
	end
	
	phaseIsWarmUp = false
	phaseAllowRespawn = vdmCoopAllowRespawn:GetBool()
	
	for k,pl in ipairs( player_GetAll() ) do
		pl:Freeze( false )
	end
	
	round = round + 1
	
	timeToStartPhase = timeNow + (240 * 60)
	
	--local gametype_name = vdmGameTypeCV:GetString()
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Co-Op" )
	
	phaseCurrent = phaseKey.coopRoundActive
end )

RegisterPhase( "coopRoundActive", function( timeNow )
	local roundActive = timeNow < timeToStartPhase
	
	local alive_players, alive_t, alive_ct = aliveTeamCount()
	
	if ( roundActive and ( (alive_players > 0) or phaseAllowRespawn ) ) then
		local allowRespawns = vdmCoopAllowRespawn:GetBool()
		
		if (allowRespawns != phaseAllowRespawn) then
			local msg = "uhh hlep"
			
			phaseAllowRespawn = allowRespawns
			
			if (allowRespawns) then
				msg = "Co-Op respawning enabled."
			else
				msg = "Co-Op respawning disabled."
			end
			
			PrintMessage( HUD_PRINTTALK, msg )-- Because overlapping messages lol
		end
		
		return
	end
	
	local msg = "Time up!"
	
	if ( alive_players < 1 ) then
		msg = "Everyone died!"
	end
	
	net.Start("vdmn_genericnotify")
		net.WriteString( msg )
	net.Broadcast()
	
	GAMEMODE:UpdatePhaseTimer( -2, msg )
	
	phaseAllowRespawn = false
	
	timeToStartPhase = timeNow + cvPostroundTime:GetInt()
	phaseCurrent = phaseKey.RoundOver
end )

--[[	----	----	----	----	----	]]

-- Any player that wants to join the game during warm up, this gets called to spawn them frozen and prepped for the round
-- Return true to prevent spawning by normal ways, so you can spawn them or not
function GM:PhaseOnRespawn( pl )
	
	if ( phaseIsWarmUp ) then
		GAMEMODE:PrepPlayer( pl )
		
		-- Only return true if you spawned the player!
		return true
	end
	
	return false
end

function GM:PhaseAllowRespawn( pl )
	-- Only have to set which ones return true to allow spawning
	
	return phaseAllowRespawn
end

function GM:SetupSaveLoadout()
	
	for k,pl in ipairs( player_GetAll() ) do
		if ( pl:Alive() && ( !pl.spawnClass || player_manager.GetPlayerClass( pl ) == pl.spawnClass ) ) then
			
			pl.SaveLoadoutTime = CurTime()
			pl.SaveLoadout = pl:GetWeapons()
			pl.SaveLoadoutLastWeapon = pl:GetActiveWeapon():GetClass()
			pl.SaveLoadoutAmmo = pl:GetAmmo()

		end
	end

end

function GM:PlayerLoadout( pl )
	
	-- Doesn't appear to be any good way of keeping weapons, so heres an attempt
	-- Doesn't count clips per weapon as ammo deduction
	
	--[[if ( pl.SaveLoadoutTime && pl.SaveLoadoutTime - CurTime() == 0 ) then
		
		--for k,v in ipairs( pl.SaveLoadout ) do
		--	pl:Give( v:GetClass(), false )
		--	print( pl, "oops", v:GetClass() )-- TODO .................................................
		--end
		
		--for id,amnt in pairs( pl.SaveLoadoutAmmo ) do
		--	pl:SetAmmo( amnt, id )
		--end
		
		net.Start( "facile_switchweapon" )
		net.WriteString( pl.SaveLoadoutLastWeapon )
		net.Send( pl )
		
		pl.SaveLoadoutTime = nil
		pl.SaveLoadout = nil
		pl.SaveLoadoutLastWeapon = nil
		pl.SaveLoadoutAmmo = nil
		
	else]]
		player_manager.RunClass( pl, "Loadout" )
	--end
	
	-- !! I wanted an area to do some more stuff to the player without global variables across the lua
	-- Actually inverse check is much better
	local canSpawnTrails = cvPlayerTrails:GetInt()
	
	if ( canSpawnTrails > 0 ) then
		if ( canSpawnTrails == 2 || phaseAllowTrails ) then
			GAMEMODE:TrailSetup( pl )
		end
	end
	
end