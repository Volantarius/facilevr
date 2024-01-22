SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "DESERT EAGLE"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_pist_deagle.mdl")
SWEP.WorldModel = Model("models/weapons/w_pist_deagle.mdl")

SWEP.Primary.ClipSize 		= 7
SWEP.Primary.DefaultClip 	= 7
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "vdm_50ae"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 7

if CLIENT then
	killicon.Add( "weapon_vcss_deagle", "killicons/deagle", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/deagle" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 650

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 2
local vcssDamage = 54
local vcssRange = 4096
local vcssRangeModifier = 0.81
local vcssBullets = 1
local vcssCycleTime = 0.225

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

-- There is no dry deploy for this model!
--[[function SWEP:Deploy()

	print( self:Clip1() )

	if ( self:Clip1() <= 0 ) then
		self:SendWeaponAnim( ACT_VM_DRYFIRE_LEFT )
	end

	return true
end]]

local sfxSingle = Sound( "Weapon_DEagle.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	if ( clip1 > 1 ) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.60, -0.20 )
end

function SWEP:CanSecondaryAttack()
	return false
end