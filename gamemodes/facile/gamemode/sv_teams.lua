function GM:PlayerRequestClass( pl, class, disablemessage )
	
	local pTeam = pl:Team()

	local tClasses = team.GetClass( pTeam )
	if ( !tClasses ) then return end

	local requestedClass = tClasses[ class ]
	if ( !requestedClass ) then return end

	--player_manager.SetPlayerClass( pl, requestedClass )
	pl.spawnClass = requestedClass

	pl:SetRespawn( true )

	if ( !disablemessage ) then
		pl:ChatPrint( "Your class will change to '".. baseclass.Get( requestedClass ).DisplayName .. "' when you spawn" )
	end

end

concommand.Add( "changeclass", function( pl, cmd, args ) hook.Call( "PlayerRequestClass", GAMEMODE, pl, tonumber(args[1]) ) end )

-- Use this to switch players to new player classes on that team
function GM:PlayerUpdateClasses( pl, teamid )
	
	if ( teamid == TEAM_SPECTATOR ) then return end
	
	local pClasses = team.GetClass( teamid )
	
	if ( pClasses ) then
		local numClasses = #pClasses

		if ( numClasses > 1 ) then

			if ( pl:IsBot() ) then
				GAMEMODE:PlayerRequestClass( pl, math.random( 1, numClasses ), true )
				
				pl:SetRespawn( true )
			else
				pl:SetRespawn( false )

				net.Start( "facile_showclasses" )
				net.Send( pl )
			end

		else
			player_manager.SetPlayerClass( pl, pClasses[1] )
			
			pl:SetRespawn( true )
		end
	else
		ErrorNoHalt( "(FACILE): No classes found for team: " .. team.GetName(teamid) .. "\n" )
		
		--player_manager.SetPlayerClass( pl, "player_default" )

		pl:SetRespawn( false )-- Maybe make a variable to allow players to spawn when in a shit player class??
	end
	
end

function GM:PlayerCanJoinTeam( pl, teamid )
	
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches || 10
	
	if ( pl.LastTeamSwitch && RealTime() - pl.LastTeamSwitch < TimeBetweenSwitches ) then
		pl.LastTeamSwitch = pl.LastTeamSwitch + 1

		pl:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - pl.LastTeamSwitch ) ) + 1 ) )

		return false
	end
	
	if ( pl:Team() == teamid ) then
		pl:ChatPrint( "You're already on that team" )

		return false
	end
	
	-- Keep game balance
	if ( teamid > 0 && teamid < 1001 && teamid != team.BestAutoJoinTeam() ) then
		pl:ChatPrint( "Team has too many players!" )
		
		return false
	end
	
	return true
	
end

-- Called from ConCommand, "changeteam"
function GM:PlayerRequestTeam( pl, teamid )

	if ( !GAMEMODE.TeamBased ) then return end

	if ( !team.Joinable( teamid ) ) then
		pl:ChatPrint( "You can't join that team" )

		return false
	end

	if ( !GAMEMODE:PlayerCanJoinTeam( pl, teamid ) ) then
		return false
	end

	GAMEMODE:PlayerJoinTeam( pl, teamid )
end

--[[---------------------------------------------------------
	Name: gamemode:PlayerJoinTeam( player, team )
	Desc: Helper function to set the player's team and class
	This will prompt the player a list of classes to choose
-----------------------------------------------------------]]
function GM:PlayerJoinTeam( pl, teamid )

	if ( teamid == TEAM_SPECTATOR ) then
		pl:SetTeam( teamid )
		return
	end
	
	pl:StripWeapons()
	pl:StripAmmo()
	
	local iOldTeam = pl:Team()
	
	if ( pl:Alive() ) then
		--if ( iOldTeam == TEAM_SPECTATOR || iOldTeam == TEAM_UNASSIGNED ) then
		if ( iOldTeam == TEAM_UNASSIGNED ) then
			pl:KillSilent()
		else
			pl:Kill()
		end
	end
	
	pl:SetTeam( teamid )
	
	player_manager.ClearPlayerClass( pl )

	GAMEMODE:PlayerUpdateClasses( pl, teamid )
end

--[[---------------------------------------------------------
	Name: gamemode:OnPlayerChangedTeam( player, oldteam, newteam )
	Desc: Helper function now, use this in your gamemode.
-----------------------------------------------------------]]
function GM:OnPlayerChangedTeam( pl, oldteam, newteam ) end


--[[---------------------------------------------------------
	Name: gamemode:PlayerChangedTeam( player, oldteam, newteam )
	Desc: Originally OnPlayerChangedTeam
	This is called from player:SetTeam

	You shouldn't override this unless you know what you are
	doing. OnPlayerChangedTeam, should be where you add stuff
-----------------------------------------------------------]]
function GM:PlayerChangedTeam( pl, oldteam, newteam )

	-- Do NOT spawn players in this function!
	-- Do NOT change teams in this function! Can cause a loop!

	if ( newteam == TEAM_SPECTATOR ) then
		if ( pl:Alive() ) then
			pl:StripWeapons()
			pl:StripAmmo()
			
			if ( oldteam == TEAM_UNASSIGNED ) then
				pl:KillSilent()
			else
				pl:Kill()
			end
		end
		
		player_manager.ClearPlayerClass( pl )
		
		GAMEMODE:PlayerSpawnAsSpectator( pl, true )
	end

	if ( oldteam ~= TEAM_CONNECTING && !pl:IsBot() ) then
		pl.LastTeamSwitch = RealTime()
	end

	-- Replace with better looking message for team switching
	PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", pl:Nick(), team.GetName( newteam ) ) )

	GAMEMODE:OnPlayerChangedTeam( pl, oldteam, newteam )
end