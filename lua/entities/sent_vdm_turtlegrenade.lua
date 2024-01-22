AddCSLuaFile()

ENT.Type = "anim"

--ENT.Model = Model("models/props/de_tides/vending_turtle.mdl")
--ENT.Model = Model("models/weapons/w_eq_fraggrenade.mdl")
ENT.Model = Model("models/props_canal/mattpipe.mdl")

if ( CLIENT ) then
	killicon.Add( "sent_vdm_turtlegrenade", "killicons/explosive", Color(255,255,255,255) )
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "EnlargeTime")
	self:NetworkVar("Float", 1, "FuseScaler")
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if SERVER then
		--self:PhysicsInitSphere(3, "default")
		self:PhysicsInitBox(-2 * Vector(1,1,1), 2 * Vector(1,1,1))
		
		self:SetEnlargeTime(CurTime() + 2.0)
		self:SetFuseScaler(0.35)
		
		--local trailRes = 1 / (1 + 8) * 0.5
		
		--util.SpriteTrail(self, 0, Color(0,255,0), true, 24, 0, 0.8, trailRes, "trails/laser")
	end
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Explode()
	if ( not IsFirstTimePredicted() ) then return end
	local pos = self:GetPos()
	
	util.BlastDamage( self, self.Owner, pos, 550, 130--[[DAMAGE]] )
	
	util.ScreenShake( pos, 25, 30, 0.66, 1000 )
	
	self:EmitSound( Sound( "Vol_Laser3.Single" ) )
	--self:EmitSound( "Vol_Stinky.Explode" )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "Explosion", effectdata, true, true )
end

local FinalSize = 15.0

--local sfx_bounce = Sound( "Doll.Squeak" )
local sfx_bounce = Sound( "VDM_Laypipe.Single" )
--local sfx_bounce = Sound( "VDM_Fart.Diseased" )

function ENT:Think()
		if (self:GetEnlargeTime() < CurTime()) then
			
			local OldScale = self:GetModelScale()
			
			if (OldScale <= FinalSize) then
				local NewScale = OldScale * 1.5
				
				self:SetModelScale( NewScale, 0.2 )
				
				if SERVER then
					self:EmitSound( "volantarius/cbfd/fart10.wav", ((NewScale/FinalSize)*30)+90, ((NewScale/FinalSize)*100)+50, 1, CHAN_WEAPON )
				end
			else
				if SERVER then
					self:Explode()
					self:Remove()
				end
			end
			
			local OldScaler = self:GetFuseScaler()
			local NewScaler = OldScaler * 0.90
			
			self:SetEnlargeTime(CurTime() + NewScaler)
			
			self:SetFuseScaler( NewScaler )
		end
	end

if SERVER then
	function ENT:PhysicsCollide(data, phys)
		local hit_normal = data.HitNormal
		
		sound.Play( sfx_bounce, data.HitPos - hit_normal )
		
		if (self:GetEnlargeTime() < CurTime()) then return end
		
		local OldNormal = data.OurOldVelocity:GetNormalized()
		
		local bounceDot = OldNormal:Dot(hit_normal)
		
		local BounceNormal = (-2 * (bounceDot) * hit_normal) + OldNormal
		
		local NewVelocity = BounceNormal * ( data.OurOldVelocity:Length() * (1 - (bounceDot * bounceDot)) )
		
		phys:SetVelocityInstantaneous( NewVelocity )
	end
end