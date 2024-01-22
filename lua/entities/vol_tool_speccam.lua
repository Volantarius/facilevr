
AddCSLuaFile()
DEFINE_BASECLASS( "vol_base_edit" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Spectate Helper"
ENT.Category = "Volantarius"

function ENT:Initialize()
	
	BaseClass.Initialize( self )
	
	self:EnableForwardArrow()
	
	if ( CLIENT ) then return end
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	
end

function ENT:SetupDataTables()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

-- 75 angle FOV

--[[if CLIENT then
	local CircleMat = Material( "sgm/helpersafe" )
	
	function ENT:DrawTranslucent()
		local trace = {}
		trace.start 	= self:GetPos() + Vector(0,0,50)
		trace.endpos 	= trace.start + Vector(0,0,-300)
		trace.filter 	= self
		
		local tr = util.TraceLine( trace )
		
		if not tr.HitWorld then
			tr.HitPos = self:GetPos()
		end
		
		local color = table.Copy( self:GetColor() )
		color.a = 80--40
		
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 32, 32, color )
	end
end]]