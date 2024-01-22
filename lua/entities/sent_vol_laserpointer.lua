AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "WallNormal")
	self:NetworkVar("Float", 0, "ChargeScale")
	
	if ( SERVER ) then
		self:SetWallNormal(Vector(1,0,0))
		self:SetChargeScale(0)
	end
end

function ENT:Initialize()
	self:SetModel(Model("models/jaanus/dildo.mdl"))
	
	self:DrawShadow(false)
end

function ENT:Think()
	
end

if ( CLIENT ) then
	local MAT_LASER = Material("effects/vollaser")
	
	function ENT:DrawTranslucent()
		local normal = self:GetWallNormal()
		local charge = self:GetChargeScale()
		local pos = self:GetPos()
		
		local size = 8 + (charge * 18)
		
		render.SetMaterial(MAT_LASER)
		render.DrawQuadEasy( pos + (normal * 0.5), normal, size, size, Color(255, 255, 255, (192 * charge) + 63 ) )
	end
end