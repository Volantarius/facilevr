SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "Phantom"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/d5k/v_d5k.mdl")
SWEP.WorldModel = Model("models/weapons/d5k/w_d5k.mdl")

SWEP.Primary.ClipSize 		= 80
SWEP.Primary.DefaultClip 	= 80
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "SMG1"--"vdm_45acp"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vdm_cougar", "killicons/357", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = true
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/357" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 7
end

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 1
local vcssDamage = 25
local vcssRange = 4096
local vcssRangeModifier = 0.75
local vcssBullets = 1
local vcssCycleTime = 3/40

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

local sfxEmpty = Sound( "Vol_GE_Empty.Single" )

function SWEP:CanPrimaryAttack( clip )
	clip = clip || self:Clip1()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )
		
		return false
	end
	
	return true
end

function SWEP:CanSecondaryAttack( clip )
	clip = clip || self:Clip2()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )
		
		return false
	end
	
	return true
end

local sfxSingle = Sound( "Vol_GE_D5K.Single" )
--local sfxSingle = Sound( "Vol_GE_KF7.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.009, vcssRange, vcssPenetration, 1, 1, "tracer_vol_goldeneye" )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.15, -0.08 )
end

function SWEP:CanSecondaryAttack()
	return false
end