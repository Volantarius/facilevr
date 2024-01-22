
AddCSLuaFile()
DEFINE_BASECLASS( "vol_base_edit" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Power Up Helper"
ENT.Category = "Volantarius"

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	self:SetMaterial("vdmtools/powerup_tool")
	
	if ( CLIENT ) then return end
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
end

local PowerUpValues = {
	[1] = "Armor",
	[2] = "Health",
	[3] = "2x Health"
}

local function makePowerUpTable()
	local ntbl = {}
	
	for k,v in ipairs(PowerUpValues) do
		ntbl[v] = k
	end
	
	return ntbl
end

function ENT:UpdateHintText( name, old, new )
	self:SetOverlayText( PowerUpValues[new] )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "PowerUpClass", {
		KeyName = "powerup", Edit = {
			title = "Power Up Class",
			type = "Combo",
			order = 2,
			text = "Choose..",
			values = makePowerUpTable()--YAY it works!!!
	} } )
	
	if ( SERVER ) then
		self:NetworkVarNotify( "PowerUpClass", self.UpdateHintText )
		
		self:SetPowerUpClass( 1 )
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	local CircleMat = Material( "sgm/helpersafe" )
	local Sprite = Material( "effects/pickup_ring" )
	local SpriteGlow = Material( "effects/pickup_glow" )
	local SpriteCol = Color( 213, 132, 0 )--Color( 40, 192, 0 )
	--56
	
	function ENT:DrawTranslucent()
		local trace = {}
		trace.start 	= self:GetPos() + Vector(0,0,50)
		trace.endpos 	= trace.start + Vector(0,0,-300)
		trace.filter 	= self
		
		local tr = util.TraceLine( trace )
		
		if not tr.HitWorld then
			tr.HitPos = self:GetPos()
		end
		
		-- 20 collision size, but 56 sounds better
		
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 128, 128, Color(213, 132, 0, 80) )
		
		render.SetMaterial( Sprite )
		render.DrawSprite( tr.HitPos + Vector(0,0,32), 56, 56, SpriteCol )--56 size is what it was
		
		render.SetMaterial( SpriteGlow )
		render.DrawSprite( tr.HitPos + Vector(0,0,32), 56, 56, SpriteCol )
	end
end