SWEP.Base = "weapon_vdm_tool_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "XBowBolt"
SWEP.Primary.FireDelay 		= 0.15

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

if CLIENT then
	SWEP.PrintName 	= "(TOOL) NAIL"
	SWEP.ToolName = "Nail Tool"
	SWEP.Description = "Get nailed. Creates nails using crossbow ammo."
	SWEP.info = [[Creates nails that can break under force. Strong enough against the gravity gun.]]
	SWEP.info_left = "Nail an object to the world or another object!"
	
	SWEP.ViewModelFOV = 60
	
	SWEP.UseHands = true
	
	SWEP.DrawAmmo = true
	
	SWEP.Slot = 5
	SWEP.SlotPos = 9
end

--[[///////////////////////////////////////////////////////////]]

local toolmask = SWEP.FireMask

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	if ( self:Ammo1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		return false
	end
	
	local pl = self.Owner
	
	local tr = util.GetPlayerTrace( pl )
	tr.start = pl:GetShootPos()
	tr.mask = toolmask
	local trace = util.TraceLine( tr )
	
	if ( not trace.Hit ) then return end
	
	self:DoShootEffects( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
	
	local good = self:create_nail( trace )
	
	if ( good ) then
		self:ConfirmedShootEffects( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
		
		self:TakePrimaryAmmo( 1 )--Only take ammo if we created a nail
	end
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Reload()
	if ( CurTime() <= (self:GetNextPrimaryFire() + self.Primary.FireDelay) ) then return false end
	
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:create_nail( tr )
	if ( tr.HitSky ) then return false end
	if ( not IsValid(tr.Entity) and tr.Entity:IsPlayer() ) then return false end
	if ( SERVER and not util.IsValidPhysicsObject( tr.Entity, tr.PhysicsBone ) ) then return false end
	
	local trtwo = util.TraceLine({
		endpos = tr.HitPos + (tr.Normal * 16),
		start = tr.HitPos,
		filter = {tr.Entity, self.Owner}
	})
	
	-- Nail test
	if ( SERVER and trtwo.Hit and not trtwo.Entity:IsPlayer() ) then
		local vOrigin = tr.HitPos - (tr.Normal * 8.0)
		local vDirection = tr.Normal:Angle()
		
		vOrigin = tr.Entity:WorldToLocal( vOrigin )
		
		local constraint = constraint.Weld( tr.Entity, trtwo.Entity, tr.PhysicsBone, trtwo.PhysicsBone, 60000 )
		
		if ( not IsValid(constraint) ) then return false end
		
		constraint.Type = "Nail"
		constraint.Pos = vOrigin
		constraint.Ang = vDirection
		
		local Pos = tr.Entity:LocalToWorld( vOrigin )
		
		local nail = ents.Create( "gmod_nail" )
		nail:SetPos( Pos + (tr.Normal * 7) )
		nail:SetAngles( vDirection )
		nail:SetParentPhysNum( tr.PhysicsBone )
		nail:SetParent( tr.Entity )
		
		nail:Spawn()
		nail:Activate()
		
		tr.Entity.GravPickupDisabled = true
		
		if ( util.IsValidPhysicsObject( trtwo.Entity, trtwo.PhysicsBone ) ) then
			trtwo.Entity.GravPickupDisabled = true
		end
		
		constraint:DeleteOnRemove( nail )
		
		constraint:CallOnRemove( "nailbroken", function(ent, ent2)
			ent2:EmitSound( "Weapon_Crossbow.BoltHitWorld" )
			tr.Entity.GravPickupDisabled = false
			trtwo.Entity.GravPickupDisabled = false
		end, tr.Entity, trtwo.Entity )
	end
	
	return (trtwo.Hit and not trtwo.Entity:IsPlayer())
end