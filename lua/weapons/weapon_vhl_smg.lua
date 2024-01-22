SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "HK MP7"
SWEP.Author = "Volantarius"
SWEP.Category = "VHL"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_smg1.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg1.mdl")

SWEP.Primary.ClipSize 		= 45
SWEP.Primary.DefaultClip 	= 45
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "SMG1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "SMG1_Grenade"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vhl_smg", "killicons/csgo_mp7", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = true
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/csgo_mp7" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 0
end

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 1
local vcssDamage = 30
local vcssRange = 4096
local vcssRangeModifier = 0.82
local vcssBullets = 1
local vcssCycleTime = 0.075

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("smg")
end

local sfxSingle = Sound( "Weapon_SMG1.Single" )
local sfxEmpty = Sound( "Weapon_SMG1.Empty" )
local sfxSecondary = Sound( "Weapon_SMG1.Double" )

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	self:SetNextSecondaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.017, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.70, -0.12 )
end

function SWEP:CanSecondaryAttack( clip )
	clip = clip || self:Ammo2()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )
		
		return false
	end

	return true
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 1.0 )--1.0
	
	local clip2 = self:Ammo2()

	if ( not self:CanSecondaryAttack( clip2 ) ) then return end
	
	self:TakeSecondaryAmmo( 1 )
	
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
	self:ShootEffects()
	
	self:EmitSound( sfxSecondary )
	
	local ply = self.Owner
	
	if ( IsValid(ply) ) then
		ply:VRecoil( -2.90, -0.90 )
		
		if ( SERVER ) then
			local gnade = ents.Create( "grenade_ar2" )
			
			local shoot_pos = ply:GetShootPos()
			local shoot_vec = ply:GetAimVector()
			
			gnade:SetPos( shoot_pos )
			gnade:SetAngles( shoot_vec:Angle() )
			
			gnade:SetOwner( ply )
			
			gnade:Spawn()
			
			gnade:SetVelocity( shoot_vec * 1000 )
		end
	end
end