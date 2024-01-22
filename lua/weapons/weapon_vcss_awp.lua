SWEP.Base = "weapon_vcss_scout"
--SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "AWP"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_snip_awp.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_awp.mdl")

SWEP.Primary.ClipSize 		= 10
SWEP.Primary.DefaultClip 	= 10
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "vdm_338mag"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 30

if CLIENT then
	killicon.Add( "weapon_vcss_awp", "killicons/awp", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/awp" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 3
	SWEP.SlotPos = 1
end

SWEP.vcssMaxPlayerSpeed = 210
SWEP.vcssWeaponPrice = 4750

local vcssWeaponArmorRatio = 1.95
local vcssPenetration = 3
local vcssDamage = 115
local vcssRange = 8192
local vcssRangeModifier = 0.99
local vcssBullets = 1
local vcssCycleTime = 1.5

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_AWP.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	local zoom = self:GetZoomLevel()

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, zoom > 0 and 0.0002 or 0.09, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -1.30, -0.50 )
end