function GM:PrepPlayer( pl )
	pl:StripWeapons()
	pl:StripAmmo()
	pl:Spawn()
	pl:Freeze( true )
end

function GM:SetupSaveLoadout()
	
	for k,pl in ipairs( player.GetAll() ) do
		if ( pl:Alive() && ( !pl.spawnClass || player_manager.GetPlayerClass( pl ) == pl.spawnClass ) ) then

			pl.SaveLoadoutTime = CurTime()
			pl.SaveLoadout = pl:GetWeapons()
			pl.SaveLoadoutLastWeapon = pl:GetActiveWeapon():GetClass()
			pl.SaveLoadoutAmmo = pl:GetAmmo()

		end
	end

end

local phase = {
	DebugPhase = -1,

	WaitingForPlayers = 0,

	RoundStarting = 1,
	RoundWarmup = 2,
	RoundActive = 3,
	RoundOver = 4
}

--local phaseCurrent = phase.WaitingForPlayers
local phaseCurrent = phase.DebugPhase

local round = 0

local waitGrace = 2
local timeToStartPhase = 10

-- How many players needed to start a round
local playersNeeded = 1

function GM:PhaseAllowRespawn( pl )
	-- Only have to set which ones return true to allow spawning

	if ( phaseCurrent == phase.DebugPhase ) then

		return true
	elseif ( phaseCurrent == phase.RoundWarmup ) then
		
		return true
	elseif ( phaseCurrent == phase.RoundActive ) then
		-- This is how you prevent players from spawning in your round

		return false
	end

	return false
end

-- Which ever is allowed to spawn above, can be caught down here to prep, or whatever
function GM:PhaseOnRespawn( pl )

	if ( phaseCurrent == phase.RoundWarmup ) then
		GAMEMODE:PrepPlayer( pl )

		-- Only return true if you spawned the player!
		return true
	end

	return false
end

local function DebugPhase()
	waitGrace = CurTime() + 30
	PrintMessage( HUD_PRINTTALK, "Debug phase yo!" )
	
	GAMEMODE:UpdatePhaseTimer( CurTime() + 30, "Debugging" )
	
	return
end

local function WaitingForPlayers()

	local players = 0

	for k,pl in ipairs( player.GetAll() ) do
		local pTeam = pl:Team()

		if ( pTeam > 0 && pTeam < 1002 && pl:CanRespawn() ) then
			players = players + 1
		end
	end

	if ( players < playersNeeded ) then
		waitGrace = CurTime() + 3-- We don't want to check each tick
		return
	end

	PrintMessage( HUD_PRINTTALK, "Round starting" )

	timeToStartPhase = CurTime() + 3-- Can be a convar to change the value on the fly
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Round Starting" )
	
	phaseCurrent = phase.RoundStarting-- Make this a convar, so that you can change which phase to goto
	
end

local function RoundStarting()

	if ( CurTime() < timeToStartPhase ) then
		return
	end

	PrintMessage( HUD_PRINTTALK, "Round warm up" )

	-- Before cleanup! and before prep!
	GAMEMODE:SetupSaveLoadout()

	game.CleanUpMap()

	for k,pl in ipairs( player.GetAll() ) do
		local pTeam = pl:Team()

		if ( pTeam > 0 && pTeam < 1002 && pl:CanRespawn() ) then
			GAMEMODE:PrepPlayer( pl )
		end
	end

	timeToStartPhase = CurTime() + 5
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "Warm Up" )
	
	phaseCurrent = phase.RoundWarmup
end

local function RoundWarmup()

	if ( CurTime() < timeToStartPhase ) then
		return
	end

	PrintMessage( HUD_PRINTTALK, "Round started" )

	for k,pl in ipairs( player.GetAll() ) do
		pl:Freeze( false )
	end

	round = round + 1

	--timeToStartPhase = CurTime() + (5 * 60)
	timeToStartPhase = CurTime() + 20
	
	GAMEMODE:UpdatePhaseTimer( timeToStartPhase, "LIVE" )
	
	phaseCurrent = phase.RoundActive
end

local function RoundActive()

	local roundActive = CurTime() < timeToStartPhase

	local aliveCount = 0

	--[[for k,pl in ipairs( player.GetAll() ) do
		if ( pl:Alive() ) then
			aliveCount = aliveCount + 1
		end
	end]]

	for k,pl in ipairs( player.GetHumans() ) do-- FOR TESTING ZOMBIE BOTS LOL
		if ( pl:Alive() ) then
			aliveCount = aliveCount + 1
		end
	end

	if ( roundActive && aliveCount > 0 ) then
		return
	end

	if ( !roundActive && aliveCount > 0 ) then

		PrintMessage( HUD_PRINTTALK, "TIME UP" )

	elseif ( aliveCount == 0 ) then
		
		PrintMessage( HUD_PRINTTALK, "EVERYONE DEAD" )
	end

	timeToStartPhase = CurTime() + 5
	phaseCurrent = phase.RoundOver
end

local function RoundOver()

	if ( CurTime() < timeToStartPhase ) then
		return
	end

	PrintMessage( HUD_PRINTTALK, "Round over" )

	phaseCurrent = phase.WaitingForPlayers
end

--[[	----	----	]]

local function PhaseTick()

	if ( phaseCurrent == phase.WaitingForPlayers && CurTime() > waitGrace ) then
		WaitingForPlayers()

	elseif ( phaseCurrent == phase.RoundStarting ) then
		RoundStarting()

	elseif ( phaseCurrent == phase.RoundWarmup ) then
		RoundWarmup()

	elseif ( phaseCurrent == phase.RoundActive ) then
		RoundActive()

	elseif ( phaseCurrent == phase.RoundOver ) then
		RoundOver()

	elseif ( phaseCurrent == phase.DebugPhase && CurTime() > waitGrace ) then

		DebugPhase()
	end

end

hook.Add( "Tick", "FacilePhaseTick", PhaseTick )
