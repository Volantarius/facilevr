DEFINE_BASECLASS( "gamemode_base" )

-- Use not so ear damaging DSP
function GM:OnDamagedByExplosion( pl, dmginfo )
	pl:SetDSP( 32, false )
end

local fall_fatal = 1100
local fall_maxsafe = 580
local fall_damage = 100 / ( fall_fatal - fall_maxsafe )

function GM:GetFallDamage( pl, flFallSpeed )

	if ( GAMEMODE.RealisticFallDamage ) then

		return math.max( (flFallSpeed - fall_maxsafe) * fall_damage * 1.25, 0 )
		
	end
	
	return 10
end

function GM:PlayerShouldTakeDamage( ply, attacker )

	-- SPAWN PROTECTION TEST LOL
	if ( RealTime() < ply.ProtectTime ) then
		return false
	end

	local attackerValid = IsValid( attacker )

	if ( GAMEMODE.NoPlayerSelfDamage && attackerValid && ply == attacker ) then return false end
	
	if ( GAMEMODE.NoPlayerDamage ) then return false end
	
	if ( GAMEMODE.NoPlayerTeamDamage && attackerValid ) then
		if ( attacker.Team && ply:Team() == attacker:Team() && ply != attacker ) then return false end
	end
	
	local attackerPlayer = attacker:IsPlayer()

	if ( attackerValid && attackerPlayer && GAMEMODE.NoPlayerPlayerDamage ) then return false end
	if ( attackerValid && !attackerPlayer && GAMEMODE.NoNonPlayerPlayerDamage ) then return false end
	
	return true

end

function GM:AllowPlayerPickup( pl, object )
	return false
end

-- Maybe later add this
function GM:PlayerShouldTaunt( ply, actid )
	return false
end

function GM:CanPlayerSuicide( ply )
	return !GAMEMODE.NoPlayerSuicide
end 

--[[function GM:OnPlayerHitGround( ply, bInWater, bOnFloater, flFallSpeed )

	-- Apply damage and play collision sound here
	-- then return true to disable the default action
	--MsgN( ply, bInWater, bOnFloater, flFallSpeed )
	--return true
	
	ply:ChatPrint( string.format("aaa %s %s %f", bInWater, bOnFloater, flFallSpeed) )

end]]

function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	return false

	--BaseClass.OnPhysgunFreeze( self, weapon, phys, ent, ply )
end

--[[function GM:PlayerSetModel( ply )
	player_manager.RunClass( ply, "SetModel" )
end]]

-- Custom fucking flashlights
function GM:PlayerSwitchFlashlight( pl, wish_state )
	local player_team = pl:Team()
	
	-- Don't allow poo teams flashlight
	if ( player_team < 1 && player_team > 1000 ) then
		return false
	end
	
	--[[
		Custom flashlights!
		
		We basically don't allow the ingame one at all, and use a networked variable
	]]
	if ( pl:CanUseFlashlight() ) then
		local current_mode = pl:GetNWBool( "FaFlashlight", false )
		local new_mode = not current_mode
		
		if ( not pl:Alive() ) then
			-- TODO: Somehow attach the client ragdoll???
			--local ragdoll = pl:GetRagdollEntity()
			
			new_mode = false
		end
		
		pl:SetNWBool( "FaFlashlight", new_mode )
		
		local state_send = 2
		
		if ( new_mode ) then
			state_send = 3
		end
		
		net.Start("facile_playerstate")
			net.WriteUInt(state_send, 32)
		net.Send( pl )
	end
	
	return false
end