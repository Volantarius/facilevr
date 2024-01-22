SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "Base Test"

SWEP.Author = "Volantarius"
SWEP.Category = "VCSS"

SWEP.ViewModelFOV = 54

SWEP.ViewModel = Model( "models/weapons/cstrike/c_rif_aug.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_rif_aug.mdl" )

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

--[[
	TODO:
	Add idle times
	Try to setup shotgun, burst fire, etc... in a functional way like think will only need to be changed??
]]

function SWEP:Initialize()
	self:SetHoldType("smg")
end

function SWEP:SetupDataTables()
end

function SWEP:Think()
end

SWEP.vcssMaxPlayerSpeed = 221
SWEP.vcssWeaponPrice = 2500

local vcssWeaponArmorRatio = 1.55
local vcssPenetration = 2
local vcssDamage = 36
local vcssRange = 8192
local vcssRangeModifier = 0.98
local vcssBullets = 1
local vcssCycleTime = 0.1

--[[
	currentDistance = Engine units
	currentDamage = bullet.Damage
	dmginfo = Current bullet damage phase

	This MUST be in each weapon that uses vcss_base! This is to avoid having a big variable table!
	This is called throughout the bullet phases of wallbangs or ricochets.

	Don't change anything unless you know what you are doing!
]]
local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

local sfxEmpty = Sound( "Vol_CSS_Dry" )

function SWEP:CanPrimaryAttack( clip )
	clip = clip || self:Clip1()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )

		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	--self:EmitSound( "Weapon_AK47.Single" )
	self:EmitSound( "Weapon_USP.SilencedShot" )

	self:ShootBullet( vcssDamage, vcssBullets, 0.009, vcssRange, vcssPenetration )

	--self:TakePrimaryAmmo( 1 )

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
	self:SetNextSecondaryFire( CurTime() + vcssCycleTime )

	local clip2 = self:Clip2()

	if ( not self:CanSecondaryAttack( clip2 ) ) then return end

	self:EmitSound( "Weapon_AK47.Single" )

	self:ShootBullet( vcssDamage, vcssBullets, 0.012, vcssRange, vcssPenetration )

	self:TakeSecondaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -1.27, -0.26 )
end

--[[	VCSS BULLETS	]]

local PenMatTable = {
	[MAT_ANTLION] = 8,
	[MAT_BLOODYFLESH] = 8,
	[MAT_CONCRETE] = 8,
	[MAT_DIRT] = 16,
	[MAT_FLESH] = 8,
	[MAT_GRATE] = 32,
	[MAT_ALIENFLESH] = 8,
	[MAT_SNOW] = 16,
	[MAT_PLASTIC] = 32,
	[MAT_METAL] = 32,
	[MAT_SAND] = 16,
	[MAT_FOLIAGE] = 16,
	[MAT_COMPUTER] = 16,
	[MAT_TILE] = 16,
	[MAT_GRASS] = 16,
	[MAT_VENT] = 32,
	[MAT_WOOD] = 64,
	[MAT_GLASS] = 32
}

local vecblank = Vector(0,0,0)

local function setupPenBullet(self, attacker, tr, dmginfo, bullet, oldDistance, maxDist, penNumber, penLimit)
	if ( penNumber >= penLimit or PenMatTable[tr.MatType] == nil ) then return end

	-- Place Holder, these do allow penetration!
	if ( tr.HitTexture == "studio" or tr.HitTexture == "displacement" ) then return end--print("FUCK") return end

	local penetrateDist = PenMatTable[tr.MatType]

	local penbullet = bullet
	penbullet.Tracer = 0
	penbullet.Force = 0
	penbullet.Spread = vecblank
	penbullet.Src = tr.HitPos + (tr.Normal * (penetrateDist + 1))
	penbullet.Dir = tr.Normal * -1
	
	penbullet.Distance = penetrateDist

	penbullet.Callback = function (attacker2, reverseTrace, reverseDmg)
		if ( not reverseTrace.Hit or reverseTrace.HitSky or reverseTrace.StartSolid ) then return end

		if ( PenMatTable[reverseTrace.MatType] == nil ) then
			reverseDmg:SetDamage( 0 )
			return
		end

		reverseDmg:SetDamageForce( dmginfo:GetDamageForce() )
		reverseDmg:SetDamagePosition( dmginfo:GetDamagePosition() )
		reverseDmg:SetDamageCustom( 8 )

		local distance = (1 - reverseTrace.Fraction) * penetrateDist

		self:HandleDamageBonus( distance + oldDistance, bullet.Damage, reverseDmg )

		-- If we hit the same entity before penetration, DO not apply damage again!
		if ( tr.Entity ~= nil and reverseTrace.Entity ~= nil and tr.Entity == reverseTrace.Entity ) then
			reverseDmg:SetDamage( 0 )
		end

		-- Prevent exiting a different surface that doesn't allow this distance
		if ( tr.MatType ~= reverseTrace.MatType and distance > PenMatTable[reverseTrace.MatType] ) then return end

		local penbullet2 = penbullet
		penbullet2.Src = tr.HitPos + (tr.Normal * penetrateDist)
		penbullet2.Dir = tr.Normal
		--penbullet2.Force = bullet.Force
		
		--penbullet2.TracerName = "tracer_vol_lazer_blue"
		--penbullet2.Tracer = 1

		local currentDistance = penetrateDist + oldDistance

		penbullet2.Distance = maxDist - currentDistance

		penbullet2.Callback = function(attacker3, afterPenTrace, afterPenDmg)
			afterPenDmg:SetDamageCustom( 8 )

			local newCurrentDist = (afterPenTrace.Fraction * penbullet2.Distance) + currentDistance

			self:HandleDamageBonus( newCurrentDist, bullet.Damage, afterPenDmg )

			setupPenBullet(self, attacker, afterPenTrace, dmginfo, penbullet2, newCurrentDist, maxDist, penNumber + 1, penLimit)
		end

		self:GetOwner():FireBullets(penbullet2, false)
	end

	self:GetOwner():FireBullets(penbullet, false)
end

local ricoSfx, utilParticleTracer, soundPlay = Sound("Vol_New_Ricochet.Single"), util.ParticleTracer, sound.Play

local function BulletBack(self, attacker, tr, dmginfo, bullet, pen_limit)
	if ( not tr.Hit or tr.HitSky or tr.StartSolid ) then return end

	local currentDistance = tr.Fraction * bullet.Distance

	self:HandleDamageBonus( currentDistance, bullet.Damage, dmginfo )

	local dot = tr.Normal:Dot(tr.HitNormal)

	local shRand = util.SharedRandom( "vdmRicoRand", 0, 1 )

	if ( bullet.Num == 1 and shRand < 0.5 and not IsValid(tr.Entity) and dot > -0.3 and dot < 0 ) then
		local reflection = (-2 * dot * tr.HitNormal) + tr.Normal

		soundPlay( ricoSfx, tr.HitPos + tr.Normal )

		local bullet2 = bullet

		bullet2.Callback = function (attacker2, tr2, dmginfo2)
			dmginfo2:SetDamageCustom( 2 )--Ricochet info

			self:HandleDamageBonus( (tr.Fraction + tr2.Fraction) * bullet.Distance, bullet.Damage, dmginfo2 )

			utilParticleTracer(bullet2.TracerName, tr.HitPos, tr2.HitPos, false)
		end

		bullet2.Src = tr.HitPos
		bullet2.Dir = reflection
		bullet2.Tracer = 0
		bullet2.Spread = Vector( 0.04, 0.04, 0 )
		
		self:GetOwner():FireBullets( bullet2, false )

		return
	end

	if ( pen_limit < 1 or bullet.Num > 1 ) then return end

	setupPenBullet(self, attacker, tr, dmginfo, bullet, currentDistance, bullet.Distance, 0, pen_limit)
end

local mathClamp = math.Clamp

--[[
	Try to avoid overriding! This uses local functions that have to be copied over! This is to help rewritting a lot of shit!
]]
function SWEP:ShootBullet( damage, num_bullets, aimcone, distance, pen_limit, force, tracer, tracername, ammo_type )
	local p = self:GetOwner()
	local pen_limit = mathClamp( pen_limit || 0, 0, 5 )

	local bullet = {}
	bullet.Num = num_bullets

	bullet.Src = p:GetShootPos()
	bullet.Dir = p:GetAimVector()

	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo

	bullet.Distance = distance || 8192

	--bullet.TracerName = tracername || "tracer_vcss_new"
	bullet.TracerName = tracername || "tracer_vol_goldeneye"

	bullet.Callback = function (attacker, tr, dmginfo)
		BulletBack(self, attacker, tr, dmginfo, bullet, pen_limit)
	end

	p:FireBullets( bullet )
end
