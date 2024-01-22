SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "M249"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_mach_m249para.mdl")
SWEP.WorldModel = Model("models/weapons/w_mach_m249para.mdl")

SWEP.Primary.ClipSize 		= 100
SWEP.Primary.DefaultClip 	= 100
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_556box"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vcss_m249", "killicons/m249", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/m249" )

	--SWEP.vcssMuzzleFlashScale = 1.5
	--SWEP.CSMuzzleX = true

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 3
	SWEP.SlotPos = 3
end

SWEP.vcssMaxPlayerSpeed = 220
SWEP.vcssWeaponPrice = 5750

local vcssWeaponArmorRatio = 1.6
local vcssPenetration = 2
local vcssDamage = 35
local vcssRange = 8192
local vcssRangeModifier = 0.97
local vcssBullets = 1
local vcssCycleTime = 0.08

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_M249.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.002, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -2.50, -0.60 )
end

function SWEP:CanSecondaryAttack()
	return false
end