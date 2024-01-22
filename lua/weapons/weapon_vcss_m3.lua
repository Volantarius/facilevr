SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "M3 SUPER 90"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_shot_m3super90.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_m3super90.mdl")

SWEP.Primary.ClipSize 		= 8
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Buckshot"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 20

if CLIENT then
	killicon.Add( "weapon_vcss_m3", "killicons/m3super", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/m3super" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 3
	SWEP.SlotPos = 6
end

SWEP.vcssMaxPlayerSpeed = 220
SWEP.vcssWeaponPrice = 1700

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 0
local vcssDamage = 26
local vcssRange = 3000
local vcssRangeModifier = 0.70
local vcssBullets = 9
local vcssCycleTime = 0.88

function SWEP:Initialize()
	self:SetHoldType("shotgun")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Reloading")
	self:NetworkVar("Float", 0, "ReloadTimer")
end

function SWEP:Reload()
	if self:GetReloading() then return end
	
	if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
		if self:StartReload() then
			return
		end
	end
end

function SWEP:StartReload()
	if self:GetReloading() then
		return false
	end
	
	local ply = self:GetOwner()

	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
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
	local ply = self:GetOwner()

	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	
	if self:Clip1() >= self.Primary.ClipSize then return end
	
	ply:RemoveAmmo(1, self.Primary.Ammo, false)
	self:SetClip1(self:Clip1() + 1)
	
	self:SendWeaponAnim( ACT_VM_RELOAD )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() - 0.05 )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() )
end

function SWEP:Think()
	local ply = self:GetOwner()

	if (self:GetReloading()) then
		if (ply:KeyDown(IN_ATTACK)) then
			self:FinishReload()
			return
		end
		
		if (self:GetReloadTimer() <= CurTime()) then
			if (ply:GetAmmoCount(self.Primary.Ammo) <= 0) then
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

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_M3.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.04, vcssRange, vcssPenetration, 1, 0 )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.80, -0.35 )
end

function SWEP:CanSecondaryAttack()
	return false
end