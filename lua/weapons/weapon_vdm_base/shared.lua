SWEP.Base = "weapon_base"

SWEP.PrintName 	= "VDM Base Test"

SWEP.Category = "VDM"

SWEP.ViewModelFOV = 54

SWEP.ViewModel = Model( "models/weapons/c_357.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_357.mdl" )

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 90
SWEP.Primary.DefaultClip 	= 90
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "AR2"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

-- VR TIME
-- So check and see if we can change the hold type on VR, and set to RPG
-- We need to do this override though

-- VR_MODE, for CLIENT
-- player.vr_mode for SERVER, or player:GetNWBool( "VR", false )
--

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

function SWEP:SetupDataTables()
end

function SWEP:Think()
end

local vdmDamage = 36
local vdmBullets = 1
local vdmCycleTime = 0.1

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

local game_SinglePlayer = game.SinglePlayer

function SWEP:ShootEffects()
	local ply = self:GetOwner()
	--ply:MuzzleFlash()
	ply:SetAnimation( PLAYER_ATTACK1 )
	
	if ( SERVER && game_SinglePlayer() ) then
		-- YAY
		self:CallOnClient( "PrimaryHaptic" )
	elseif ( CLIENT ) then
		self:PrimaryHaptic()
	end
end

--local sfxEmpty = Sound( "Weapon_Pistol.Empty" )
local sfxEmpty = Sound("Vol_TS_Dry.Single")

function SWEP:CanPrimaryAttack( clip )
	clip = clip || self:Clip1()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )

		return false
	end

	return true
end

--[[
	This is the sort of framework I want, try to leave as much inside the primary attack function!
	This makes it easy to swap the fire animations and shit without overriding too much stuff!
]]
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vdmCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	--self:EmitSound( "Weapon_AK47.Single" )
	self:EmitSound( "Weapon_USP.SilencedShot" )-- local sfx = Sound("blah") will precache on creation!

	self:ShootBullet( vdmDamage, vdmBullets, 0.009 )

	--self:TakePrimaryAmmo( vdmBullets )

	--[[if ( clip1 > 1 ) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		--ACT_VM_DRYFIRE_LEFT
		--ACT_VM_DRYFIRE
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
	end]]

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.87, -0.26 )
end

--[[	SECONDARY	]]

function SWEP:CanSecondaryAttack( clip )
	clip = clip || self:Clip2()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )

		return false
	end

	return true
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + vdmCycleTime )

	local clip2 = self:Clip2()

	if ( not self:CanSecondaryAttack( clip2 ) ) then return end

	self:EmitSound( "Weapon_AK47.Single" )

	self:ShootBullet( vdmDamage, vdmBullets, 0.012 )

	self:TakeSecondaryAmmo( vdmBullets )

	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -1.27, -0.26 )
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, force, tracer, tracername, ammo_type )

	local p = self:GetOwner()

	local bullet = {}
	bullet.Num = num_bullets
	
	bullet.Src = p:GetShootPos()
	bullet.Dir = p:GetAimVector()
	
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo

	bullet.TracerName = tracername || "tracer_vol_goldeneye"

	--[[bullet.Callback = function (attacker, tr, dmginfo)
		BulletBack(self, attacker, tr, dmginfo, bullet, pen_limit)
	end]]

	p:FireBullets( bullet )
end
