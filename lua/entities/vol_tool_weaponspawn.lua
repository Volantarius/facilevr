
AddCSLuaFile()
DEFINE_BASECLASS( "vol_base_edit" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Weapon Helper"
ENT.Category = "Volantarius"

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	self:SetMaterial("vdmtools/weapon_tool")
	
	if ( CLIENT ) then return end
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "ForceClass", {
		KeyName = "forceclass",
		Edit = {
			title = "Force spawn class",
			type = "Boolean",
			order = 1
	} } )
	
	if ( SERVER ) then
		self:SetForceClass( false )
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	local CircleMat = Material( "sgm/helpersafe" )
	local Sprite = Material( "effects/pickup_ring" )
	local SpriteGlow = Material( "effects/pickup_glow" )
	local SpriteCol = Color( 40, 192, 0 )
	
	function ENT:DrawTranslucent()
		local trace = {}
		trace.start 	= self:GetPos() + Vector(0,0,50)
		trace.endpos 	= trace.start + Vector(0,0,-300)
		trace.filter 	= self
		
		local tr = util.TraceLine( trace )
		
		if not tr.HitWorld then
			tr.HitPos = self:GetPos()
		end
		
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 128, 128, Color(109, 182, 39, 80) )
		
		render.SetMaterial( Sprite )
		render.DrawSprite( tr.HitPos + Vector(0,0,32), 56, 56, SpriteCol )
		
		render.SetMaterial( SpriteGlow )
		render.DrawSprite( tr.HitPos + Vector(0,0,32), 56, 56, SpriteCol )
	end
end