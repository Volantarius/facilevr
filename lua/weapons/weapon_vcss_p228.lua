SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "P228"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_pist_p228.mdl")
SWEP.WorldModel = Model("models/weapons/w_pist_p228.mdl")

SWEP.Primary.ClipSize 		= 13
SWEP.Primary.DefaultClip 	= 13
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Pistol"--"vdm_9mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vcss_p228", "killicons/p228", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/p228" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 7
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 600

local vcssWeaponArmorRatio = 1.25
local vcssPenetration = 1
local vcssDamage = 40
local vcssRange = 4096
local vcssRangeModifier = 0.8
local vcssBullets = 1
local vcssCycleTime = 0.15

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_P228.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.70, -0.00 )
end

function SWEP:CanSecondaryAttack()
	return false
end