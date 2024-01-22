SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "P90"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_smg_p90.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg_p90.mdl")

SWEP.Primary.ClipSize 		= 50
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_57mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 26

if CLIENT then
	killicon.Add( "weapon_vcss_p90", "killicons/p90", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/p90" )

	--SWEP.vcssMuzzleFlashScale = 1.2
	--SWEP.CSMuzzleX = true

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 5
end

SWEP.vcssMaxPlayerSpeed = 245
SWEP.vcssWeaponPrice = 2350

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 1
local vcssDamage = 26
local vcssRange = 4096
local vcssRangeModifier = 0.84
local vcssBullets = 1
local vcssCycleTime = 0.07

function SWEP:Initialize()
	self:SetHoldType("smg")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_P90.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.001, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.95, -0.25 )
end

function SWEP:CanSecondaryAttack()
	return false
end