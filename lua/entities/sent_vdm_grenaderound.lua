AddCSLuaFile()
-- Grenade Round for the Grenade Launcher

ENT.Type = "anim"

ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

if ( CLIENT ) then
	killicon.Add( "sent_vdm_grenaderound", "killicons/explosive", Color(255,255,255,255) )
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "PrimerTime")
	self:NetworkVar("Float", 1, "FuseTime")
	self:NetworkVar("Bool", 0, "FuseReady")
	self:NetworkVar("Bool", 1, "RemovePlease")
	self:NetworkVar("Int", 0, "BDamage")
	
	-- Defaults
	if ( SERVER ) then
		self:SetBDamage( 10 )
		self:SetPrimerTime(CurTime() + 0.55)
		self:SetFuseTime(CurTime() + 5.0)--Auto explode timer
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if CLIENT then
		self.OldPos = self:GetPos()
		self.OldPos:Div(64)
		self.OldPos = Vector( math.Round(self.OldPos.x), math.Round(self.OldPos.y), math.Round(self.OldPos.z) )
	end
	
	if SERVER then
		--self:PhysicsInit( SOLID_VPHYSICS )
		--self:SetSolid( SOLID_BBOX )
		--self:SetCollisionBounds(-1 * Vector(1,1,1), 1 * Vector(1,1,1))
		
		-- Above only seems to really change if movetype is different
		--self:SetMoveType( MOVETYPE_VPHYSICS ) --MOVETYPE_FLY awesome for no-gravity projectiles
		
		--self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		-- ////////////////////////////////////////////////////////////////////////////////////////
		
		self:PhysicsInitSphere(1, "default")
		
		--local trailRes = 1 / (1 + 8) * 0.5
		
		--util.SpriteTrail(self, 0, Color(255,255,255), false, 8, 0, 1.2, trailRes, "trails/smoke")
	end
	
	-- Always get phys object after creation
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Explode( data )
	local pos = self:GetPos()

	local dmg = DamageInfo()
	dmg:SetDamage( self:GetBDamage() )
	dmg:SetDamageCustom( 4 )
	dmg:SetAttacker( self.Owner )
	dmg:SetInflictor( self )
	
	if data then
		dmg:SetDamageForce( data.HitNormal * 1024 )
		
		util.BlastDamageInfo( dmg, data.HitPos, 450 )
		
		util.ScreenShake( data.HitPos, 25, 30, 0.66, 450 )

		util.Decal( "Scorch", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal, {self, self.Owner} )
	else
		util.BlastDamageInfo( dmg, pos, 450 )
		
		util.ScreenShake( pos, 25, 30, 0.66, 450 )
	end
	
	--self:EmitSound("Vol_MineTest.Explode")
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "Explosion", effectdata, true, true )
end

if SERVER then
	function ENT:Think()
		if (CurTime() > self:GetFuseTime()) then
			self:Explode()
			self:Remove()
			return
		end
		
		if (CurTime() > self:GetPrimerTime()) then
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
			self:Explode( data )
			return
		end
		
		local OldNormal = data.OurOldVelocity:GetNormalized()
		
		local bounceDot = OldNormal:Dot(data.HitNormal)
		
		local BounceNormal = (-2 * (bounceDot) * data.HitNormal) + OldNormal
		
		--local NewVelocity = BounceNormal * ( data.OurOldVelocity:Length() * (1 - (bounceDot * bounceDot)) )
		local NewVelocity = BounceNormal * ( data.OurOldVelocity:Length() * (1.12 - bounceDot) )
		
		phys:SetVelocityInstantaneous( NewVelocity )
		
		--self:EmitSound( Sound( "Flashbang.Bounce" ) )
		self:EmitSound( Sound( "Vol_Quake_Grenade.Hit" ) )
	end
end

if CLIENT then
	function ENT:Think()
		local Pos = self:GetPos()
		Pos:Div(64)
		Pos = Vector( math.Round(Pos.x), math.Round(Pos.y), math.Round(Pos.z) )
		
		-- Make the grenade only smoke in intervals of space, not time lol
		if (Pos ~= self.OldPos && not self:GetRemovePlease()) then
			local data = EffectData()
			data:SetOrigin( self:GetPos() )
			util.Effect( "nadesmoke", data )
			
			self.OldPos = Pos
		end
	end
end