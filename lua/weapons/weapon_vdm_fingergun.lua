SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/denry/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"--Somehow don't render the thirdperson model

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 3
SWEP.Primary.DefaultClip 	= 3
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "357"
SWEP.Primary.FireDelay 		= 0.35

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Finger Gun"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = false
	
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	
	--killicon.Add( "weapon_vol_pistol", "killicons/deagle", Color(255,255,255,255) )
end

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Reload()
	if ( self.Owner:KeyDown(IN_ATTACK) ) then return false end
	
	if ( self:Clip1() >= self.Primary.ClipSize || self:Ammo1() <= 0 ) then return false end
	
	self:EmitSound( "Vol_JB_Hand.Reload" )
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		self:EmitSound( "Vol_JB_Hand.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( "Vol_JB_Hand.Single" )
	
	self:ShootBullet( 999, 1, 0.0, self.Primary.Ammo )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	self:ShootPrimaryEffects()
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	--bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()):Forward()
	
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = 0
	bullet.Force = 3
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo

	bullet.Callback = function (attacker, tr, dmginfo)
		dmginfo:SetDamageCustom( 4 )
	end
	
	self.Owner:FireBullets( bullet )
end

-- TRUE to disable
function SWEP:DoImpactEffect( tr, nDamageType )
	return true
end