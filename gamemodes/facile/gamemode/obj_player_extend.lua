AddCSLuaFile()

local meta = FindMetaTable( "Player" )
if ( !meta ) then return end

-- Used for holding the player from respawning when choosing a player class
function meta:SetRespawn( enable )
	self:SetNWBool( "CanRespawn", enable )
end

-- Use this for checking if player's have a class chosen for CanRoundStart
function meta:CanRespawn()
	return self:GetNWBool( "CanRespawn", false )
end

-- Checks if player class is being used for the team
function meta:ValidPlayerClass()
	local pClass = player_manager.GetPlayerClass( self )
	
	if ( !pClass ) then return false end

	local tClasses = team.GetClass( self:Team() )

	if ( !tClasses ) then return false end

	local valid = false -- just in case, cant remember if the loop can break all scope
	
	for k,class in ipairs( tClasses ) do
		if ( class == pClass ) then
			valid = true
			return valid
		end
	end
	
	return valid
end

-- VR, so we can replace the shooting position!
--
-- This totally works! But only for scripted weapons...
-- All of HL2 weapons would need to be re-written.. Including the physgun
--
-- This also means that anything non-facile will have to also get this code treatment

local old_GetShootPos = meta.GetShootPos
local old_GetAimVector = meta.GetAimVector

function meta:GetShootPos()
	
	if ( CLIENT && VR_MODE ) then
		
		if ( self.mainhand_pos ~= nil ) then
			
			return (self.mainhand_pos + Vector(0, 0, 0))
		end
		
	elseif ( SERVER && self.vr_mode ) then
		local pinfo_fire_pos = self:GetInfo( "favr_fire_pos" )
		
		if ( pinfo_fire_pos ) then
			return Vector( pinfo_fire_pos ) + self:GetPos()
		end
		
	end
	
	return old_GetShootPos( self )
end

function meta:GetAimVector()
	
	if ( CLIENT && VR_MODE ) then
		
		if ( self.mainhand_vec ~= nil ) then
			
			return (self.mainhand_vec + Vector(0, 0, 0))
		end
		
	elseif ( SERVER && self.vr_mode ) then
		local pinfo_fire_vec = self:GetInfo( "favr_fire_vec" )
		
		if ( pinfo_fire_vec ) then
			return Vector( pinfo_fire_vec )
		end
		
	end
	
	return old_GetAimVector( self )
end