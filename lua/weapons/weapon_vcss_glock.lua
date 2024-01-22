SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "GLOCK 18"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_pist_glock18.mdl")
SWEP.WorldModel = Model("models/weapons/w_pist_glock18.mdl")

SWEP.Primary.ClipSize 		= 20
SWEP.Primary.DefaultClip 	= 20
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Pistol"--"vdm_9mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vcss_glock", "killicons/glock", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/glock" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 4
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 400

local vcssWeaponArmorRatio = 1.05
local vcssPenetration = 1
local vcssDamage = 25
local vcssRange = 4096
local vcssRangeModifier = 0.75
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

local sfxSingle = Sound( "Weapon_Glock.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	--self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )
	-- Gotta fucking add movement to the bullet spread....
	self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	--local ply = self:GetOwner()

	--ply:VRecoil( -0.10, -0.05 )
end

function SWEP:CanSecondaryAttack()
	return false
end