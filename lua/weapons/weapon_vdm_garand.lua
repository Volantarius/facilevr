SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "M1 Garand"
SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = Model("models/weapons/v_m1garand.mdl")
SWEP.WorldModel = Model("models/weapons/w_m1garand.mdl")

SWEP.Spawnable = true

SWEP.Primary.ClipSize 		= 8
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "SMG1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

if CLIENT then
	SWEP.Category 	= "VDM"

	SWEP.ViewModelFOV = 75
	
	SWEP.UseHands = false
	
	killicon.Add( "weapon_vdm_garand", "killicons/csgo_nova", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/csgo_nova" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 5
end

local vcssWeaponArmorRatio = 1.7
local vcssPenetration = 3
local vcssDamage = 43
local vcssRange = 8192
local vcssRangeModifier = 0.98
local vcssBullets = 1
local vcssCycleTime = 0.10

function SWEP:Initialize()
	self:SetHoldType( "ar2" )
end

function SWEP:Reload()
	if ( self:Clip1() > 0 ) then
		return false
	else
		self:DefaultReload( ACT_VM_RELOAD )
	end
end

local sfxSingle = Sound("Weapon_Garand.Fire")
local sfxDing = Sound("Weapon_Garand.ClipDing")

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.003, vcssRange, vcssPenetration, 3 )--, 1, "tracer_vol_incin"

	self:TakePrimaryAmmo( vcssBullets )

	if ( clip1 > 1 ) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
		self:EmitSound( sfxDing )
	end
	
	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -2.00, -0.15 )
end

function SWEP:CanSecondaryAttack()
	-- MELEE!!!
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
end