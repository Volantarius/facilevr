SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "M4A1"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_m4a1.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_m4a1.mdl")

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
	killicon.Add( "weapon_vcss_m4a1", "killicons/m4a1", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/m4a1" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 1

	-- Silenced has no muzzleflash!
	function SWEP:FireAnimationEvent( pos, ang, event, options )
		if ( event == 5001 or event == 5011 or event == 5021 or event == 5031 ) then
			return self:GetSilenced()
		end
	end
end

SWEP.vcssMaxPlayerSpeed = 230
SWEP.vcssWeaponPrice = 3100

local vcssWeaponArmorRatio = 1.4
local vcssPenetration = 2
local vcssDamage = 33
local vcssRange = 8192
local vcssRangeModifier = 0.97
local vcssBullets = 1
local vcssCycleTime = 0.09

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Silenced")

	if (SERVER) then
		self:SetSilenced(false)
	end
end

function SWEP:Reload()
	if ( self:GetSilenced() ) then
		self:DefaultReload( ACT_VM_RELOAD_SILENCED )
	else
		self:DefaultReload( ACT_VM_RELOAD )
	end
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:ShootEffects()
	local ply = self:GetOwner()

	if ( not self:GetSilenced() ) then
		ply:MuzzleFlash()
	end
	
	ply:SetAnimation( PLAYER_ATTACK1 )
end

-- There is no dry deploy for this model!
function SWEP:Deploy()
	if ( self:GetSilenced() ) then
		self:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	end

	return true
end

local sfxSingle = Sound( "Weapon_M4A1.Single" )
local sfxSilenced = Sound( "Weapon_M4A1.Silenced" )

local actPri = ACT_VM_PRIMARYATTACK
local actPriSil = ACT_VM_PRIMARYATTACK_SILENCED

function SWEP:PrimaryAttack()
	local dur = CurTime() + vcssCycleTime
	self:SetNextPrimaryFire( dur )
	self:SetNextSecondaryFire( dur )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	local sil = self:GetSilenced()

	self:EmitSound( sil and sfxSilenced or sfxSingle )
	
	self:ShootBullet( vcssDamage, vcssBullets, sil and 0.00054 or 0.0006, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( sil and actPriSil or actPri )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.45, -0.20 )
end

function SWEP:SecondaryAttack()
	local sil = not self:GetSilenced()

	if ( sil ) then
		self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
	else
		self:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
	end

	self:SetSilenced( sil )

	local dur = CurTime() + self:SequenceDuration() + 0.1

	self:SetNextPrimaryFire( dur )
	self:SetNextSecondaryFire( dur )
end