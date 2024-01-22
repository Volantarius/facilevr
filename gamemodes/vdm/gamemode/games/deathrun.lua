AddCSLuaFile()

local player_GetAll, round_number = player.GetAll, 0

function GM:SetupDeathrunRules()
	if ( SERVER ) then
		
		function GAMEMODE:SetupGameTeams()
			-- Go through everyone who hasn't played yet
			round_number = round_number + 1
			
			local has_played = {}
			local hasnt_played = {}
			
			for player_id,pl in ipairs( player_GetAll() ) do
				if ( IsValid( pl ) ) then
					local player_team = pl:Team()
					
					if ( player_team == TEAM_T || player_team == TEAM_CT ) then
						if ( pl.has_played == nil ) then
							table.insert( hasnt_played, pl )
						elseif ( pl.has_played ) then
							table.insert( has_played, pl )
						end
					end
				end
			end
			
			local hasnt_count = #hasnt_played
			local has_count = #has_played
			
			if ( hasnt_count == 0 ) then
				for k,p in ipairs( has_played ) do
					p.has_played = nil
				end
				
				hasnt_count = has_count
				hasnt_played = has_played
			end
			
			local random_hasnt_played_index = math.random( 1, hasnt_count )
			
			local new_player = hasnt_played[random_hasnt_played_index]
			
			GAMEMODE:PlayerJoinTeam( new_player, TEAM_T )
			
			new_player.LastTeamSwitch = 10
			
			new_player.has_played = true
		end
		
		function GAMEMODE:CanPlayerSuicide( pl )
			return false
		end
		
	else
		
		
		
	end
end

--[[----	----	----	----	----	----	----	----]]

function GM:ShutdownDeathrunRules()
	if ( SERVER ) then
		
		
		
	else
		
		
		
	end
end