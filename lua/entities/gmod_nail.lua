AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = false

function ENT:Initialize()
	self:SetModel(Model("models/crossbow_bolt.mdl"))
end