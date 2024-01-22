AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/props/cs_italy/orange.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "FuseTime")
	self:NetworkVar("Bool", 0, "FuseReady")
	self:NetworkVar("Bool", 1, "RemovePlease")
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	self.gColor = self:GetColor()
	self.gColor.a = 255
	
	if SERVER then
		self:PhysicsInitSphere(1, "default")
		
		local trailRes = 1 / (1 + 8) * 0.5
		
		util.SpriteTrail(self, 0, self.gColor, true, 12, 0, 0.3, trailRes, "trails/laser")
		
		self:SetFuseTime(CurTime() + 2.0)--Fuse till last collision to explode
	end
	
	-- Always get phys object after creation
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Explode(data)
	util.BlastDamage( self, self.Owner, self:GetPos(), 500, 16--[[DAMAGE]] )
	
	util.ScreenShake( data.HitPos, 50, 30, 0.66, 2000 )
	
	sound.Play("Vol_BouncyBall.Explode", data.HitPos + data.HitNormal)
	
	if data then
		util.Decal( "Scorch", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal, {self, self.Owner} )
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( data.HitPos + (data.HitNormal * 5) )
	effectdata:SetStart( Vector(self.gColor.r, self.gColor.g, self.gColor.b) )
	util.Effect( "eff_vdm_pop", effectdata )
end

if SERVER then
	function ENT:Think()
		if (CurTime() > self:GetFuseTime()) then
			self:SetFuseReady(true)
		end
		
		if (self:GetRemovePlease()) then
			self:Remove()
		end
	end
	
	function ENT:PhysicsCollide(data, phys)
		if (self:GetRemovePlease()) then
			return
		end
		
		if (self:GetFuseReady()) then
			self:SetRemovePlease(true)
			self:Explode(data)
			
			self:GetPhysicsObject():EnableMotion(false)
			
			return
		end
		
		local dotss = data.OurOldVelocity:Dot(data.HitNormal)
		
		local fanus = ((-2 * dotss) * data.HitNormal) + data.OurOldVelocity
		
		phys:SetVelocityInstantaneous( fanus )
		
		if ( IsFirstTimePredicted() ) then
			--util.ScreenShake( data.HitPos, 12.5, 15, 0.33, 700 )
			
			self:EmitSound( Sound( "Vol_BouncyBall.Cute" ) )
		end
	end
end

if CLIENT then
	function ENT:Think()
		if (self:GetRemovePlease()) then
			self:SetNoDraw( true )
		end
	end
	
	function ENT:Draw()
		--self:DrawModel()
	end
	
	local matBall = Material("sprites/sent_ball")
	
	function ENT:DrawTranslucent()
		render.SetMaterial( matBall )
		
		render.DrawSprite( self:GetPos(), 5, 5, self.gColor )
	end
end