SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/jaanus/v_drilldo.mdl"
SWEP.WorldModel = "models/jaanus/w_drilldo.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"
SWEP.Primary.FireDelay 		= 0.15

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.m_WeaponDeploySpeed = 1.0

if CLIENT then
	SWEP.PrintName 	= "Drilldo"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = false
	
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_drilldo", "killicons/drilldo", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/drilldo" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

-- Remove self on drop!!
function SWEP:OnDrop()
	self:Remove()
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Reload()
	if ( self.Owner:KeyPressed(IN_RELOAD) ) then
		--self:EmitSound( "Vol_Dick.Reload" )
		
		local dir = self.Owner:GetAimVector()
		
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetShootPos() + (dir * 12) )
		effectdata:SetNormal( dir )
		util.Effect( "eff_vdm_cumspout", effectdata )
		
		return true
	end
	
	return false
end

function SWEP:PrimaryAttack()
	self:EmitSound( "Vol_Dick.Spin" )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
	
	self:ShootPrimaryEffects()
	
	self:ShootBullet( 500 )
end

function SWEP:SecondaryAttack()
	--self:EmitSound( "Vol_Dick.Spin" )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
	
	self:ShootPrimaryEffects()
	
	self:ShootObject( 16 )
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	dmginfo:SetDamageType( DMG_SLASH )
	
	if ( not tr.Hit ) then return end
	
	if ( tr.MatType == MAT_FLESH || tr.MatType == MAT_BLOODYFLESH ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		
		if ( IsValid(tr.Entity) && (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
			effectdata:SetEntity( tr.Entity )
		end
		
		util.Effect( "eff_vdm_bloodspout", effectdata, true, true )
	end
	
	self:EmitSound( "Vol_Dick.Grind" )
end

function SWEP:ShootBullet( damage )
	-- Made to have a melee style attack, don't need super crazy stuff
	
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( 0, 0, 0 )
	bullet.Tracer = 0
	bullet.Force = 5--67
	bullet.Damage = damage
	bullet.AmmoType = self.Primary.Ammo
	--bullet.AmmoType = "SMG1"
	
	bullet.Distance = 36
	bullet.HullSize = 16
	
	--bullet.TracerName = "tracer_vol_lazer_green"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	return true
end

function SWEP:ShootObject( damage )
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "vdm_gib_dildonv" )
	if ( !IsValid(ent) ) then return end
	
	local finalAngles = self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()
	
	local forward = finalAngles:Forward()
	
	ent:SetPos( self.Owner:GetShootPos() + (forward * 32) + (finalAngles:Right() * 4) )
	ent:SetAngles( finalAngles )
	
	ent:Spawn()
	ent:Activate()
	
	-- Always get phys object after creation
	local phys = ent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:ApplyForceCenter(forward * 45000)--1500
	else
		ent:Remove()
	end
end