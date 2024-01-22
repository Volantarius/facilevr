AddCSLuaFile()

ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "FuseTime")
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if CLIENT then
		self.OldPos = self:GetPos()
		self.OldPos:Div(128)
		self.OldPos = Vector( math.Round(self.OldPos.x), math.Round(self.OldPos.y), math.Round(self.OldPos.z) )
	end
	
	if SERVER then
		self:PhysicsInitSphere(3, "default")
		
		self:SetFuseTime(CurTime() + 4.0)
		
		local trailRes = 1 / (1 + 8) * 0.5
		
		util.SpriteTrail(self, 0, Color(0,255,0), true, 12, 0, 0.8, trailRes, "trails/laser")
	end
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Explode()
	util.BlastDamage( self, self.Owner, self:GetPos(), 256, 130--[[DAMAGE]] )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "Explosion", effectdata, true, true )
end

function ENT:Think()
	if (SERVER and CurTime() > self:GetFuseTime()) then
		self:Explode()
		self:Remove()
	end
	
	--[[if CLIENT then
		local Pos = self:GetPos()
		Pos:Div(128)
		Pos = Vector( math.Round(Pos.x), math.Round(Pos.y), math.Round(Pos.z) )
		
		-- Make the grenade only smoke in intervals of space, not time lol
		if (Pos ~= self.OldPos) then
			local data = EffectData()
			data:SetOrigin( self:GetPos() )
			util.Effect( "nadesmoke", data )
			
			self.OldPos = Pos
		end
	end]]
end

if SERVER then
	function ENT:PhysicsCollide(data, phys)
		local OldNormal = data.OurOldVelocity:GetNormalized()
		
		local bounceDot = OldNormal:Dot(data.HitNormal)
		
		local BounceNormal = (-2 * (bounceDot) * data.HitNormal) + OldNormal
		
		--local NewVelocity = BounceNormal * ( data.OurOldVelocity:Length() * (1 - (bounceDot * bounceDot)) )
		local NewVelocity = BounceNormal * ( data.OurOldVelocity:Length() * (1.34 - bounceDot) )
		
		phys:SetVelocityInstantaneous( NewVelocity )
		
		self:EmitSound( Sound( "Flashbang.Bounce" ) )
	end
end