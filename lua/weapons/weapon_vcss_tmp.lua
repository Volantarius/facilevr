SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "TMP"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_smg_tmp.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg_tmp.mdl")

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Pistol"--"vdm_9mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vcss_tmp", "killicons/tmp", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/tmp" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 9

	-- Silenced has no muzzleflash!
	function SWEP:FireAnimationEvent( pos, ang, event, options )
		if ( event == 5001 or event == 5011 or event == 5021 or event == 5031 ) then
			return true
		end
	end
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 1250

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 1
local vcssDamage = 26
local vcssRange = 4096
local vcssRangeModifier = 0.84
local vcssBullets = 1
local vcssCycleTime = 0.07

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:ShootEffects()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
end

local sfxSingle = Sound( "Weapon_TMP.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.001, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.97, -0.12 )
end

function SWEP:CanSecondaryAttack()
	return false
end