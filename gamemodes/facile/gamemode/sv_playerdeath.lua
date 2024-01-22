function GM:PostPlayerDeath( pl )
	pl:Freeze( false )
	
	net.Start("facile_playerstate")
		net.WriteUInt(0, 32)
	net.Send( pl )
	
	if ( pl:GetObserverMode() == OBS_MODE_NONE ) then
		if ( !pl.vr_mode ) then
			pl:Spectate( OBS_MODE_DEATHCAM )
		else
			pl:SpectateEntity( nil )
			pl:Spectate( OBS_MODE_ROAMING )
		end
	end
	
	for k,ent in ipairs( pl:GetChildren() ) do
		if ( ent:GetClass() == "fa_spriteholder" ) then
			ent:Remove()
		end
	end
end

function GM:DoPlayerDeath( pl, attacker, dmginfo )
	
	pl:CreateRagdoll()

	pl:AddDeaths( 1 )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		
		if ( attacker == pl ) then
			
			if ( GAMEMODE.TakeFragOnSuicide ) then
				
				attacker:AddFrags( -1 )
				
				-- Seems a little harse actually lol
				if ( GAMEMODE.TeamBased && GAMEMODE.AddFragsToTeamScore ) then
					team.AddScore( attacker:Team(), -1 )
				end
				
			end
			
		else
			
			attacker:AddFrags( 1 )
			
			if ( GAMEMODE.TeamBased && GAMEMODE.AddFragsToTeamScore ) then
				team.AddScore( attacker:Team(), 1 )
			end
			
		end
		
	end
	
	if ( GAMEMODE.EnableFreezeCam && IsValid( attacker ) && attacker:IsPlayer() && attacker != ply ) then
	
		pl:SpectateEntity( attacker )
		pl:Spectate( OBS_MODE_FREEZECAM )
		
	end

end

function GM:PlayerDeathThink( pl )
	local pTeam = pl:Team()

	if ( pTeam == TEAM_SPECTATOR ) then return end

	local current_time = CurTime()

	-- from death linger time
	--[[if ( pl.DeathTime && time > pl.DeathTime + 1 && pl:GetObserverMode() < 3 ) then
		--GAMEMODE:BecomeObserver( pl )
		pl:Spectate( OBS_MODE_DEATHCAM )
	end]]

	if ( !pl:CanRespawn() ) then return end

	if ( !GAMEMODE:PhaseAllowRespawn( pl ) ) then return end

	if ( pl.NextSpawnTime && pl.NextSpawnTime > current_time ) then return end

	if ( pl:IsBot() || pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) ) then
		if ( !GAMEMODE:PhaseOnRespawn( pl ) ) then
			pl:Spawn()
		end
	end
end

function GM:PlayerSilentDeath( victim )
	local current_time = CurTime()

	victim.NextSpawnTime = current_time + GAMEMODE.MinimumDeathLength
	victim.DeathTime = current_time
end

function GM:EntityTakeDamage( ent, dmginfo )
	if ( ent:IsPlayer() ) then
		
		-- On a weapon you assign a bitflag
		-- Then GM:ParseExtendedDeathIcons in client will add the icon to the death notice
		local damageCustom = dmginfo:GetDamageCustom()

		local headshot = 0
		
		if ( dmginfo:IsBulletDamage() and ent:LastHitGroup() == HITGROUP_HEAD ) then
			headshot = 1
		end
		
		-- first flag is reserved for headshots
		damageCustom = bit.bor( damageCustom, headshot )

		ent.m_iDmgCustom = damageCustom

	end
end

util.AddNetworkString( "PlayerKilled" )
util.AddNetworkString( "PlayerKilledSelf" )
util.AddNetworkString( "PlayerKilledByPlayer" )

function GM:PlayerDeath( pl, inflictor, attacker )
	local current_time = CurTime()

	pl.NextSpawnTime = current_time + GAMEMODE.MinimumDeathLength
	pl.DeathTime = current_time

	pl.m_iDmgCustom = pl.m_iDmgCustom || 0
	
	--print(pl, inflictor, attacker)--func_movelinear
	
	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = pl end

	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end

	player_manager.RunClass( pl, "Death", inflictor, attacker )

	if ( attacker == pl ) then

		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( pl )
			net.WriteString( inflictor:GetClass() )
			net.WriteUInt( pl.m_iDmgCustom, 16 )
		net.Broadcast()

		MsgAll( pl:Nick() .. " suicided!\n" )

	return
	end

	-- Get weapon held
	if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then

		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( inflictor ) ) then inflictor = attacker end

	end

	if ( attacker:IsPlayer() ) then

		net.Start( "PlayerKilledByPlayer" )

			net.WriteEntity( pl )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
			net.WriteUInt( pl.m_iDmgCustom, 16 )

		net.Broadcast()

		MsgAll( attacker:Nick() .. " killed " .. pl:Nick() .. " using " .. inflictor:GetClass() .. "\n" )

	return
	end

	net.Start( "PlayerKilled" )

		net.WriteEntity( pl )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )
		net.WriteUInt( pl.m_iDmgCustom, 16 )

	net.Broadcast()

	MsgAll( pl:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )

end