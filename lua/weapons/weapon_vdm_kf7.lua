SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "KF7 Soviet"
SWEP.Author = "Volantarius"
SWEP.Category = "VDM"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/kf7/v_kf7.mdl")
SWEP.WorldModel = Model("models/weapons/kf7/w_kf7.mdl")

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_762mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	SWEP.VdmSecondaryName = "ZOOM"
	
	killicon.Add( "weapon_vdm_kf72", "killicons/ak47", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/ak47" )

	SWEP.UseHands = false

	SWEP.DrawCrosshair = false

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 1

	local Zoom = 1.0
	local LastTime = UnPredictedCurTime()
	
	function SWEP:TranslateFOV( current_fov )
		local NowTime = UnPredictedCurTime()
		local delta = NowTime - LastTime
		LastTime = NowTime
		
		if (self.Owner:KeyDown( IN_ATTACK2 )) then
			Zoom = math.Approach(Zoom, 0.55, 1.66 * delta)
		else
			Zoom = math.Approach(Zoom, 1.00, 1.66 * delta)
		end
		
		return current_fov * Zoom
	end
	
	function SWEP:AdjustMouseSensitivity()
		return Zoom
	end
	
	local crosshair = Material( "vdm/gecross" )
	local cr_size = 32
	local cr_scale = 3
	local crosshair_size = cr_size * cr_scale
	
	local midPointX = ScrW()*0.5
	local midPointY = ScrH()*0.5
	
	function SWEP:DrawHUDBackground()
		if (Zoom >= 1.0) then return end
		
		surface.SetDrawColor( 255, 255, 255, 128 )
		surface.SetMaterial( crosshair )
		
		surface.DrawTexturedRect( midPointX - (crosshair_size/2), midPointY - (crosshair_size/2), crosshair_size, crosshair_size )
	end
end

SWEP.vcssMaxPlayerSpeed = 221
SWEP.vcssWeaponPrice = 2500

local vcssWeaponArmorRatio = 1.55
local vcssPenetration = 2
local vcssDamage = 16
local vcssRange = 8192

local vcssBullets = 1
--local vcssCycleTime = 3/20
local vcssCycleTime = 1.5/20

-- I don't think Goldeneye has damage fall off from distance
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Burst")

	if (SERVER) then
		self:SetBurst( 0 )
	end
end

local vcssBurstAmount = 3

function SWEP:Think()
	local burstCount = self:GetBurst()
	
	if ( not self:GetOwner():KeyDown(IN_ATTACK) and burstCount < vcssBurstAmount and burstCount > 0 and CurTime() > self:GetNextPrimaryFire() ) then
		
		if ( self:Clip1() > 0 and not (CLIENT and game.SinglePlayer()) ) then
			self:PrimaryAttack( true )
		end

		self:SetBurst( burstCount + 1 )
		
		if ( (burstCount + 1) >= vcssBurstAmount ) then
			self:SetBurst( 0 )
		end
	end
end

local sfxDeploy = Sound("Vol_GoldenEye_Weapon.Switch")
local sfxReload = Sound("Vol_GoldenEye.Reload")

function SWEP:Deploy()
	self:EmitSound( sfxDeploy )

	if ( SERVER ) then
		self:SetBurst( 0 )
	end
	
	return true
end

function SWEP:Reload()
	if ( self:Clip1() >= self.Primary.ClipSize || self:Ammo1() <= 0 ) then return false end
	
	if ( CurTime() <= self:GetNextPrimaryFire() ) then return false end
	
	self:SetBurst( 0 )
	
	self:EmitSound( sfxReload )

	self:DefaultReload( ACT_VM_RELOAD )
end

local sfxEmpty = Sound( "Vol_GE_Empty.Single" )

function SWEP:CanPrimaryAttack( clip )
	clip = clip || self:Clip1()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )
		
		self:SetBurst( 0 )

		return false
	end
	
	return true
end

local sfxSingle = Sound( "Vol_GE_KF7.Single" )

function SWEP:PrimaryAttack( called )
	local ply = self:GetOwner()
	local aiming = ply:KeyDown( IN_ATTACK2 )
	
	local cycle = vcssCycleTime
	
	--if (aiming) then cycle = cycle * 2 end
	
	self:SetNextPrimaryFire( CurTime() + cycle )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	local spread = aiming and 0.008 or 0.025

	self:ShootBullet( vcssDamage, vcssBullets, spread, vcssRange, vcssPenetration, 1, 1, "tracer_vol_goldeneye" )

	self:TakePrimaryAmmo( vcssBullets )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	if ( not called and not aiming ) then
		self:SetBurst( 1 )
	end

	ply:VRecoil( -0.30, -0.00 )
end

function SWEP:CanSecondaryAttack()
	return false
end