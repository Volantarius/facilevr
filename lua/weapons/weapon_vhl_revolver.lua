SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "357 Magnum"
SWEP.Author = "Volantarius"
SWEP.Category = "VHL"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_357.mdl")
SWEP.WorldModel = Model("models/weapons/w_357.mdl")

SWEP.Primary.ClipSize 		= 6
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "357"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vhl_revolver", "killicons/357", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/357" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 2
end

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 2
local vcssDamage = 75
local vcssRange = 4096
local vcssRangeModifier = 0.81
local vcssBullets = 1
local vcssCycleTime = 0.75

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

local sfxSingle = Sound( "Weapon_357.Single" )

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

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

	ply:VRecoil( -3.90, 0.40 )
end

function SWEP:CanSecondaryAttack()
	return false
end