SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "SG 552 COMMANDO"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_sg552.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_sg552.mdl")

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_556mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vcss_sg552", "killicons/sig552", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/sig552" )

	--SWEP.vcssMuzzleFlashScale = 1.3
	--SWEP.CSMuzzleX = true

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 6
end

SWEP.vcssMaxPlayerSpeed = 235
SWEP.vcssWeaponPrice = 3500

local vcssWeaponArmorRatio = 1.4
local vcssPenetration = 2
local vcssDamage = 33
local vcssRange = 8192
local vcssRangeModifier = 0.955
local vcssBullets = 1
local vcssCycleTime = 0.09

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_SG552.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.006, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.85, -0.35 )
end

function SWEP:CanSecondaryAttack()
	return false
end