SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "VR Pistol"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_pistol.mdl" )
SWEP.WorldModel = Model( "" )
SWEP.VRModel = Model( "models/ugc/76561197995159516/mickyan/w_hdpistol.mdl" )

SWEP.Primary.ClipSize 		= 80
SWEP.Primary.DefaultClip 	= 80
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_45acp"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vdmvr_pistol", "killicons/hkmatch", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = true
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/hkmatch" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 7
end

local vcssBullets = 1
local vcssCycleTime = 3/40

function SWEP:Initialize()
	self:SetHoldType( "rpg" )-- FIX
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

--local sfxSingle = Sound( "Vol_GE_D5K.Single" )
local sfxSingle = Sound( "Vol_GE_KF7.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	self:SetNextSecondaryFire( CurTime() + vcssCycleTime )
	
	local clip1 = self:Clip1()
	
	if ( not self:CanPrimaryAttack( clip1 ) ) then return end
	
	self:EmitSound( sfxSingle )
	
	self:ShootBullet( 34, vcssBullets, 0.009 )
	
	--self:TakePrimaryAmmo( 1 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:ShootEffects()
	
	local ply = self:GetOwner()
	
	ply:VRecoil( -0.15, -0.08 )
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	self:SetNextSecondaryFire( CurTime() + vcssCycleTime )
	
	self:EmitSound( sfxSingle )
	
	self:ShootBullet( 34, vcssBullets, 0.009 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:ShootEffects()
end