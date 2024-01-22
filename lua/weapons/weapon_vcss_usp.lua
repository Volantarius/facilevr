SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "USP TACTICAL"
SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/cstrike/c_pist_usp.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_pist_usp.mdl" )

SWEP.Primary.ClipSize 		= 12
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "SMG1"--"vdm_45acp"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vcss_usp", "killicons/usp", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/usp" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 4

	-- Silenced has no muzzleflash!
	function SWEP:FireAnimationEvent( pos, ang, event, options )
		if ( event == 5001 or event == 5011 or event == 5021 or event == 5031 ) then
			return self:GetSilenced()
		end
	end
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 500

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 1
local vcssDamage = 34
local vcssRange = 4096
local vcssRangeModifier = 0.79
local vcssBullets = 1
local vcssCycleTime = 0.15

function SWEP:Initialize()
	self:SetHoldType("pistol")
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

function SWEP:Deploy()
	if ( self:GetSilenced() ) then
		self:SendWeaponAnim( ACT_VM_DRAW_SILENCED )
	end

	return true
end

local sfxSingle = Sound( "Weapon_USP.Single" )
local sfxSilenced = Sound( "Weapon_USP.SilencedShot" )

local actPri = ACT_VM_PRIMARYATTACK
local actDry = ACT_VM_DRYFIRE
local actPriSil = ACT_VM_PRIMARYATTACK_SILENCED
local actDrySil = ACT_VM_DRYFIRE_SILENCED

function SWEP:PrimaryAttack()
	local dur = CurTime() + vcssCycleTime
	self:SetNextPrimaryFire( dur )
	self:SetNextSecondaryFire( dur )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	local sil = self:GetSilenced()

	self:EmitSound( sil and sfxSilenced or sfxSingle )
	
	self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	if ( clip1 > 1 ) then
		self:SendWeaponAnim( sil and actPriSil or actPri )
	else
		self:SendWeaponAnim( sil and actDrySil or actDry )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.70, -0.00 )
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