AddCSLuaFile()

ENT.Type = "anim"

--ENT.Model = Model("models/maxofs2d/hover_plate.mdl")
ENT.Model = Model("models/weapons/mines/w_proximitymine.mdl")

if ( CLIENT ) then
	killicon.Add( "sent_vdm_proxmine", "killicons/proximitymine", Color(255,255,255,255) )
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "RemovePlease")
	self:NetworkVar("Float", 0, "PlantTimer")
	self:NetworkVar("Float", 1, "FuseTimer")
	self:NetworkVar("Vector", 0, "WallNormal")
end

function ENT:Initialize()
	self:SetModel(self.Model)
	
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_BBOX )
		self:SetMoveType( MOVETYPE_NONE )
		
		self:SetSolidFlags( bit.bor( FSOLID_TRIGGER, FSOLID_NOT_SOLID ) )
		
		--May need to use the wall placement normal to offset!
		self:SetCollisionBounds(-100 * Vector(1,1,0.5), 100 * Vector(1,1,0.5))
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:EnableMotion(false)
			phys:EnableGravity(false)
		end
		
		self:SetRemovePlease(false)
		self:SetFuseTimer(0)
		self:SetPlantTimer(CurTime() + 2.5)--Delay before waiting to blow up!
	end
end

function ENT:Explode()
	local wallNormal = self:GetWallNormal() || Vector(0,1,0)
	local pos = self:GetPos()
	local explodePos = pos + (wallNormal * 16)
	
	util.Decal( "Scorch", pos - wallNormal, pos + wallNormal, {self, self.Owner} )
	
	util.BlastDamage( self, self.Owner, explodePos, 400, 160--[[DAMAGE]] )
	
	util.ScreenShake( pos + wallNormal, 2000, 2, 1.0, 1024 )
	
	self:EmitSound("Vol_MineTest.Explode")
	
	local effectdata = EffectData()
	effectdata:SetOrigin( explodePos )
	util.Effect( "HelicopterMegaBomb", effectdata, true, true )
end

if SERVER then
	function ENT:Think()
		if ( self:GetRemovePlease() and CurTime() >= self:GetFuseTimer() ) then
			self:Explode()
			self:Remove()
		end
	end
	
	function ENT:Touch(entity)
		if (CurTime() <= self:GetPlantTimer()) then return end
		if (self:GetRemovePlease()) then return end
		
		self:SetRemovePlease(true)
		self:SetFuseTimer( CurTime() + 0.20 )
		
		--self:EmitSound( Sound( "Weapon_StunStick.Activate" ) )
		--self:EmitSound( Sound( "Weapon_Crowbar.Melee_HitWorld" ) )
		--self:EmitSound( Sound( "Weapon_IRifle.Empty" ) )
		self:EmitSound( Sound( "Vol_Mine.Ding" ) )
	end
end