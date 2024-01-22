AddCSLuaFile()

ENT.Type = "brush"
ENT.Base = "base_entity"

function ENT:Initialize()
end

function ENT:StartTouch( entity )
	--print( "ouchie", entity )
end

function ENT:EndTouch( entity )
end

-- Called every tick
function ENT:Touch( entity )
end

function ENT:PassesTriggerFilters( entity )
	return true
end

-- Soo we have to grab the key getting set for the buyzone! This is for the TEAM_
function ENT:KeyValue( key, value )
end

function ENT:Think()
	--[[local pos = self:GetPos()
	local min, max = self:GetCollisionBounds()
	
	debugoverlay.Box( pos, min, max, 0.3, Color(255, 255, 255, 25) )]]
end

function ENT:OnRemove()
end