SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel 	= "models/weapons/v_a35.mdl"
SWEP.WorldModel = "models/weapons/w_a35.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "grenade"
SWEP.Primary.FireDelay 		= 0.40

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.VdmSecondaryName = "LONG FUSE"
	
	SWEP.PrintName 	= "Grenade Launcher"
	
	SWEP.ViewModelFOV = 65
	
	SWEP.UseHands = false
	SWEP.ViewModelFlip = true
	
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/ff_grenadelauncher" )
	
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
	self:SetHoldType("smg")
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
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() )
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
	self:SetReloading(false)
	self:SetReloadTimer(0)
	
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
		self:EmitSound( "Vol_TS_Dry.Single" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( Sound( "Vol_Wep_GLauncher.Single" ) )
	
	self:ShootObject( 45, 0.50 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireDelay )
	
	self.Owner:ViewPunch( Angle(-1.77, 0, 0) )
	
	self:ShootPrimaryEffects()
end

function SWEP:SecondaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( Sound( "Vol_Wep_GLauncher.Single" ) )
	
	self:ShootObject( 105, 1.25 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + (self.Primary.FireDelay * 2) )
	self:SetNextSecondaryFire( CurTime() + (self.Primary.FireDelay * 2) )
	
	self.Owner:ViewPunch( Angle(-1.77, 0, 0) )
	
	self:ShootPrimaryEffects()
end

function SWEP:ShootObject( damage, fuse, aimcone )
	if CLIENT then return end
	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "sent_vdm_grenaderound" )
	if ( !IsValid(ent) ) then return end
	
	local finalAngles = self.Owner:GetAimVector():Angle() + self.Owner:GetViewPunchAngles()
	
	local forward = finalAngles:Forward()
	
	ent:SetPos( self.Owner:GetShootPos() + (forward * 32) + (finalAngles:Right() * 4) )
	ent:SetAngles( finalAngles )
	ent:SetOwner( self.Owner )
	
	ent:SetVelocity( ( forward * 1900 ) + self.Owner:GetVelocity() )
	
	ent:Spawn()
	ent:Activate()
	
	ent:SetPrimerTime( CurTime() + fuse )--Delay till last collision to explode
	ent:SetBDamage( damage )
	
	-- Always get phys object after creation
	local phys = ent:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:ApplyForceCenter(forward * 1900)--2500
	else
		ent:Remove()
	end
end