SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel 	= "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 12
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Buckshot"
SWEP.Primary.FireDelay 		= 0.30

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Auto Shotgun"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = true
	
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_shotty", "killicons/xm1014", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/xm1014" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 30
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Reloading")
	self:NetworkVar("Float", 0, "ReloadTimer")
end

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:Reload()
	if self:GetReloading() then return end
	
	if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		if self:StartReload() then
			return
		end
	end
end

function SWEP:StartReload()
	if self:GetReloading() then
		return false
	end
	
	if not self.Owner or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		return false
	end
	
	if self:Clip1() >= self.Primary.ClipSize then
		return false
	end
	
	self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
	
	self:SetReloading(true)
	
	return true
end

function SWEP:PerformReload()
	if not self.Owner or self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	
	if self:Clip1() >= self.Primary.ClipSize then return end
	
	self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
	self:SetClip1(self:Clip1() + 1)
	
	self:SendWeaponAnim( ACT_VM_RELOAD )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() - 0.25 )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() )
end

function SWEP:Think()
	if (self:GetReloading()) then
		if (self.Owner:KeyDown(IN_ATTACK)) then
			self:FinishReload()
			return
		end
		
		if (self:GetReloadTimer() <= CurTime()) then
			if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
				self:FinishReload()
			elseif (self:Clip1() < self.Primary.ClipSize) then
				self:PerformReload()
			else
				self:FinishReload()
			end
			return
		end
	end
end

function SWEP:Deploy()
	if SERVER then
		self:SetReloading(false)
		self:SetReloadTimer(0)
	end
	
	return true
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	if ( self:Clip2() <= 0 ) then
		self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

--local sfxSingle = Sound("Vol_MaxPayne_PumpShot.Single")
local sfxSingle = Sound("Vol_GE_AutoShotgun.Single")

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( sfxSingle )
	
	self:ShootBullet( 32, 6, 0.04, self.Primary.Ammo, 1.8 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	self.Owner:VRecoil( -1.7, -0.2 )
	
	self:ShootPrimaryEffects()
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = (self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()):Forward()
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 3
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_timesplit"
	
	self.Owner:FireBullets( bullet )
end