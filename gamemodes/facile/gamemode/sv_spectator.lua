-- Check the wiki for the OBS_MODE enumerable values
-- You may add checks for seperate modes for other teams!
function GM:IsValidSpectatorMode( pl, mode )
	-- 4, 6
	return mode > 3 && mode < 7
end

-- You may add checks for seperate modes for other teams!
function GM:GetNextSpectatorMode( pl, mode )
	-- 4, 6
	local nextmode = mode + 1

	if ( !self:IsValidSpectatorMode( pl, nextmode ) ) then
		nextmode = 4
	end

	return nextmode
end

-- Fuck this for now
--[[function GM:GetValidSpectatorEntityNames( pl )

	-- Note: Override this and return valid entity names per player/team

	return GAMEMODE.ValidSpectatorEntities

end]]

function GM:IsValidSpectatorTarget( pl, ent, skip )

	if ( !IsValid( ent ) ) then return false end
	if ( ent == pl ) then return false end
	
	local entPlayer = ent:IsPlayer()
	
	if (not entPlayer) then
		--[[if ( !skip ) then
			-- Skips another validity check, just to speed up some other functions
			
			if ( !table.HasValue( self:GetValidSpectatorEntityNames( pl ), ent:GetClass() ) ) then return false end
		end]]
		return false
	end
	
	if ( !ent:Alive() || ent:GetObserverMode() > 0 ) then return false end
	if ( pl:Team() != TEAM_SPECTATOR && GAMEMODE.CanOnlySpectateOwnTeam && pl:Team() != ent:Team() ) then return false end
	
	return true
end

function GM:GetSpectatorTargets( pl )

	--[[local t = {}

	for k, v in ipairs( self:GetValidSpectatorEntityNames() ) do
		t = table.Merge( t, ents.FindByClass( v ) )
	end]]
	
	return ents.FindByClass( "player" )

end

function GM:StartEntitySpectate( pl )

	local CurrentSpectateEntity = pl:GetObserverTarget()

	if ( self:IsValidSpectatorTarget( pl, CurrentSpectateEntity ) ) then
		pl:SpectateEntity( CurrentSpectateEntity )
		return
	end
	
	local targets = self:GetSpectatorTargets( pl )
	
	if ( #targets <= 1 ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
		return
	end
	
	local randomInd = 0
	local found = false
	
	for i=0, #targets do
		
		randomInd = math.random( 1, #targets - i )
		
		if ( self:IsValidSpectatorTarget( pl, targets[randomInd], true ) ) then
			pl:SpectateEntity( targets[randomInd] )
			found = true
			return
		end
		
		table.remove( targets, randomInd )
		
	end

	if ( !found ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
	end
	
end

function GM:NextEntitySpectate( pl )

	local cTarget = pl:GetObserverTarget()

	if ( !IsValid( cTarget ) ) then
		self:StartEntitySpectate( pl )
		return
	end
	
	local targets = self:GetSpectatorTargets( pl )

	if ( #targets <= 1 ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
		return
	end
	
	local found = false
	local cIndex = -1
	
	for k, v in ipairs(targets) do
		
		if ( cIndex ~= -1 and self:IsValidSpectatorTarget( pl, targets[k], true ) ) then
			pl:SpectateEntity( targets[k] )
			found = true
			return
		end
		
		if ( v == cTarget ) then
			cIndex = k
		end
		
	end
	
	if ( !found ) then
		
		for i=1, cIndex do
			
			if ( self:IsValidSpectatorTarget( pl, targets[i], true ) ) then
				pl:SpectateEntity( targets[i] )
				found = true
				return
			end
			
		end
		
	end
	
	if ( !found ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
	end
	
end

function GM:PrevEntitySpectate( pl )

	local cTarget = pl:GetObserverTarget()
	
	if ( !IsValid( cTarget ) ) then
		self:StartEntitySpectate( pl )
		return
	end

	local targets = self:GetSpectatorTargets( pl )
	
	if ( #targets <= 1 ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
		return
	end
	
	local found = false
	local cIndex = -1
	
	for k=#targets, 1, -1 do
		
		if ( cIndex ~= -1 and self:IsValidSpectatorTarget( pl, targets[k], true ) ) then
			pl:SpectateEntity( targets[k] )
			found = true
			return
		end
		
		if ( targets[k] == cTarget ) then
			cIndex = k
		end
		
	end
	
	if ( cIndex == 1 ) then
		cIndex = #targets
	end
	
	if ( !found ) then
		
		for i=cIndex, 1, -1 do
			
			if ( self:IsValidSpectatorTarget( pl, targets[i], true ) ) then
				pl:SpectateEntity( targets[i] )
				found = true
				return
			end
			
		end
		
	end
	
	if ( !found ) then
		self:ChangeObserverMode( pl, OBS_MODE_ROAMING )
	end

end

--[[ /////////////////////////////////////////////////////////////////////// ]]

-- Specifically will run player:Spectate
-- Only use this if you know the player may not be spectating
-- Otherwise do not use this to make players spectate
function GM:BecomeObserver( pl )
	
	local modeCl = pl:GetInfoNum( "cl_spec_mode", OBS_MODE_CHASE )

	if ( GAMEMODE:IsValidSpectatorMode( pl, modeCl ) ) then
		pl:Spectate( modeCl )
		GAMEMODE:ChangeObserverMode( pl, modeCl )
		return
	end
	
	local nextmode = GAMEMODE:GetNextSpectatorMode( pl, modeCl )

	pl:Spectate( nextmode )
	GAMEMODE:ChangeObserverMode( pl, nextmode )
	
end

function GM:ChangeObserverMode( pl, mode )
	
	pl:ConCommand( "cl_spec_mode "..mode )
	
	-- Only use player:Spectate to setup the entity spectating and stuff!
	-- Setting the observer mode will only alter the move system and stuff
	
	local target = pl:GetObserverTarget()
	
	-- Sometimes we can get an invalid target
	-- UnSpectate quickly to nullify the target, `SpectateEntity(NULL)` does not work as of (Jan 2021)
	if ( IsValid(target) and not self:IsValidSpectatorTarget( pl, target ) ) then
		pl:UnSpectate()
		pl:Spectate( mode )
	end
	
	--net facile_playerstate
	
	pl:SetObserverMode( mode )
	
	if ( mode > 0 && mode < 6 ) then
		self:StartEntitySpectate( pl, mode )
		return
	end
	
end

function GM:PlayerSpecMode( pl )
	local mode = pl:GetObserverMode()
	
	if ( pl:Alive() || mode < 1 ) then return end
	
	local modeCl = pl:GetInfoNum( "cl_spec_mode", OBS_MODE_CHASE )
	
	-- Revert to player's spec mode!
	if ( mode != modeCl && GAMEMODE:IsValidSpectatorMode( pl, modeCl ) ) then
		GAMEMODE:ChangeObserverMode( pl, modeCl )
		return
	end
	
	local nextmode = GAMEMODE:GetNextSpectatorMode( pl, modeCl )

	GAMEMODE:ChangeObserverMode( pl, nextmode )
end

concommand.Add( "spec_mode",  function ( pl, cmd, args ) GAMEMODE:PlayerSpecMode( pl ) end )

function GM:PlayerSpecNext( pl )
	local mode = pl:GetObserverMode()
	
	if ( pl:Alive() || mode < 1 || mode == 6 ) then return end

	local modeCl = pl:GetInfoNum( "cl_spec_mode", OBS_MODE_CHASE )

	local modeValid = GAMEMODE:IsValidSpectatorMode( pl, modeCl )

	if ( modeValid && mode != modeCl ) then

		GAMEMODE:ChangeObserverMode( pl, modeCl )

		return

	elseif ( !modeValid && mode != modeCl ) then

		local goodmode = GAMEMODE:GetNextSpectatorMode( pl, modeCl )

		GAMEMODE:ChangeObserverMode( pl, goodmode )

		return

	end
	
	GAMEMODE:NextEntitySpectate( pl )
end

concommand.Add( "spec_next",  function ( pl, cmd, args ) GAMEMODE:PlayerSpecNext( pl ) end )

function GM:PlayerSpecPrev( pl )
	local mode = pl:GetObserverMode()
	
	if ( pl:Alive() || mode < 1 || mode == 6 ) then return end

	local modeCl = pl:GetInfoNum( "cl_spec_mode", OBS_MODE_CHASE )

	local modeValid = GAMEMODE:IsValidSpectatorMode( pl, modeCl )

	if ( modeValid && mode != modeCl ) then

		GAMEMODE:ChangeObserverMode( pl, modeCl )

		return

	elseif ( !modeValid && mode != modeCl ) then

		local goodmode = GAMEMODE:GetNextSpectatorMode( pl, modeCl )

		GAMEMODE:ChangeObserverMode( pl, goodmode )

		return

	end
	
	GAMEMODE:PrevEntitySpectate( pl )
end

concommand.Add( "spec_prev",  function ( pl, cmd, args ) GAMEMODE:PlayerSpecPrev( pl ) end )