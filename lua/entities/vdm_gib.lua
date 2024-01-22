AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = false

function ENT:Initialize()
	self.Life = CurTime() + 60.0
	
	self:SetModel(Model("models/jaanus/dildo.mdl"))
	
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		
		local phys = self:GetPhysicsObject()
		
		if ( phys && phys:IsValid() ) then
			phys:Wake()
		end
	end
end

function ENT:Think()
	if (CLIENT) then return end
	
	self:NextThink( CurTime() + 10.0 )
	
	if (CurTime() > self.Life) then
		self:Remove()
	end
end

function ENT:PhysicsCollide( data, phys )
	if (IsFirstTimePredicted() && data.Speed > 75) then
		util.Decal( "Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
		self:EmitSound( "Vdm_Gore.Splat" )
		
		--[[if ( data.HitNormal.z < -0.75 ) then
			local ed = EffectData()
			ed:SetOrigin( data.HitPos )
			ed:SetNormal( data.HitNormal )
			util.Effect( "eff_vdm_blooddripper", ed )
		end]]
	end
end