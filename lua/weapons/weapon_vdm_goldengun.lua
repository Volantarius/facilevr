SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/goldengun/v_goldengun.mdl"
SWEP.WorldModel = "models/weapons/goldengun/w_goldengun.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 1
SWEP.Primary.DefaultClip 	= 3
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "357"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Golden Gun"
	
	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = false
	
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_goldengun", "killicons/swep_default", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/swep_default" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:Deploy()
	self:EmitSound( Sound("Vol_GoldenEye_Weapon.Switch") )
	return true
end

function SWEP:Initialize()
	self:SetHoldType("pistol")--revolver
end

function SWEP:Reload()
	if ( self:Clip1() > 0 || self:Ammo1() <= 0 ) then return false end
	
	if ( CurTime() < self:GetNextPrimaryFire() ) then return false end
	
	self:EmitSound( "Vol_GoldenEye.Reload" )
	self:DefaultReload( ACT_VM_RELOAD )
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		--self:SetNextPrimaryFire( CurTime() + 0.15 )
		
		self:Reload()
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( "Vol_GE_D5K.Single" )
	
	self:ShootBullet( 999, 1, 0 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	
	self:ShootPrimaryEffects()
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	if ( not tr.HitSky ) then
		sound.Play( Sound("Vol_GE_Ricochet.Single"), tr.HitPos )
	end
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_goldeneye"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end