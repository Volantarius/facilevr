AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_bullet.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "FuseTime")
	self:NetworkVar("Bool", 0, "RemovePlease")
	self:NetworkVar("Vector", 0, "HitNormal")
end

local farts = Color(255, 255, 255, 255)

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if SERVER then
		self:PhysicsInitSphere(1, "default")
	end
	
	-- Always get phys object after creation
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity( false )
	end
end

if SERVER then
	function ENT:Think()
		if (self:GetRemovePlease() and CurTime() > self:GetFuseTime()) then
			if ( IsFirstTimePredicted() ) then
				local pos = self:GetPos()
				local hit_normal = self:GetHitNormal()
				
				util.ScreenShake( pos + hit_normal, 50, 30, 0.66, 2000 )
				
				util.BlastDamage( self, self.Owner, pos + (hit_normal * -4), 550, 130--[[DAMAGE]] )
				
				--sound.Play( "Vol_Laser3.Single", pos + hit_normal )
				--sound.Play( "Vol_Stinky.Explode", pos + hit_normal )
				sound.Play( "Vol_MineTest.Explode", pos + hit_normal )
				
				local effectdata = EffectData()
				effectdata:SetOrigin( pos + (hit_normal * 8) )
				util.Effect( "HelicopterMegaBomb", effectdata, true, true )
				
				self:Remove()
			end
		end
	end
	
	function ENT:PhysicsCollide(data, phys)
		if ( self:GetRemovePlease() ) then
			return
		end
		
		if ( IsFirstTimePredicted() ) then
			local pos = self:GetPos()
			local owner = self:GetOwner()
			local forward = data.OurOldVelocity
			
			self:SetRemovePlease( true )
			--self:Explode()
			self:SetFuseTime( CurTime() + 1.3 )-- Set a fuse to explode our bullet
			
			self:SetNoDraw( true )-- Or in the think
			
			sound.Play( "Vol_BouncyBall.Explode", pos )
			sound.Play( "Vol_Bullettime.End", pos )
			
			self:SetHitNormal( data.HitNormal )
			
			self:GetPhysicsObject():EnableMotion( false )
			
			self:FireBullets({
				Attacker = owner,
				Num = 1,
				Src = pos,
				Dir = forward,
				Damage = 200,
				Force = 50,
				Distance = 4,
				Tracer = 0,
				AmmoType = "357",
				IgnoreEntity = self
			})
		end
	end
end

if CLIENT then
	
	
	function ENT:Draw()
		self:DrawModel()
	end
	
	local MAT_BLUR  = Material( "effects/bullettrail" )
	
	function ENT:DrawTranslucent()
		local angles = self:GetAngles()
		local forward = angles:Forward()
		local pos = self:GetPos()
		
		render.SetMaterial( MAT_BLUR )
		
		render.DrawBeam( pos, pos + (forward * -100),
					5, -- W
					0, -- ST
					1, -- EN
					Color(255, 255, 255, 255) )
	end
end