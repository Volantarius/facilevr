SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "MAC-10"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_smg_mac10.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg_mac10.mdl")

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "SMG1"--"vdm_45acp"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vcss_mac10", "killicons/mac10", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/mac10" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 12
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 1400

local vcssWeaponArmorRatio = 0.95
local vcssPenetration = 1
local vcssDamage = 29
local vcssRange = 4096
local vcssRangeModifier = 0.82
local vcssBullets = 1
local vcssCycleTime = 0.075

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_MAC10.Single" )

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

	ply:VRecoil( -0.70, -0.20 )
end

function SWEP:CanSecondaryAttack()
	return false
end