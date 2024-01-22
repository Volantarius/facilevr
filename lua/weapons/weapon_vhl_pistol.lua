SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "HK Match"
SWEP.Author = "Volantarius"
SWEP.Category = "VHL"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel = Model("models/weapons/w_pistol.mdl")

SWEP.Primary.ClipSize 		= 18
SWEP.Primary.DefaultClip 	= 18
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Pistol"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vhl_pistol", "killicons/hkmatch", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = true
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/hkmatch" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 1
local vcssDamage = 35
local vcssRange = 4096
local vcssRangeModifier = 0.79
local vcssBullets = 1
local vcssCycleTime = 0.1

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local sfxSingle = Sound( "Weapon_Pistol.Single" )
local sfxReload = Sound( "Weapon_Pistol.Reload" )

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
	
	self:EmitSound( sfxReload )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.01, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.30, -0.00 )
end

function SWEP:CanSecondaryAttack()
	return false
end