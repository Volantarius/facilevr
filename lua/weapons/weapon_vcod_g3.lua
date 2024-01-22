SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "G3"-- Replaces AUG
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_g3_acog.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_g3_reflex.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_sg552.mdl")

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
	SWEP.VdmSecondaryName = "ZOOM"
	
	killicon.Add( "weapon_vcod_g3", "killicons/aug", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/aug" )
	
	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 2
	
	function SWEP:CalcViewModelView( view_model, old_eyepos, old_eyeang, eyepos, eyeang )
		local zoom = self:GetZoomLevel()
		
		if ( zoom > 0 ) then
			local diff = (eyepos - old_eyepos) * 0.02
			
			return old_eyepos + diff, eyeang
		end
		
		return eyepos, eyeang
	end

	-- ////////////////////////////////////////////////////////////////////
	local Zoom = 1.0
	local newZoom = 1.0
	local LastTime = UnPredictedCurTime()

	function SWEP:TranslateFOV( current_fov )
		local NowTime = UnPredictedCurTime()
		local delta = NowTime - LastTime
		LastTime = NowTime
		
		local zoom = self:GetZoomLevel()
		
		if ( zoom == 1 ) then
			newZoom = 0.66
		else
			newZoom = 1.00
		end

		Zoom = math.Approach( Zoom, newZoom, 1 * delta )

		return current_fov * Zoom
	end

	function SWEP:AdjustMouseSensitivity()
		return Zoom
	end
end

SWEP.vcssMaxPlayerSpeed = 221
SWEP.vcssWeaponPrice = 3500

local vcssWeaponArmorRatio = 1.4
local vcssPenetration = 2
local vcssDamage = 32
local vcssRange = 8192
local vcssRangeModifier = 0.96
local vcssBullets = 1
local vcssCycleTime = 0.09

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:IronSightChanged( name, old, new )
	if CLIENT then
		self.DrawCrosshair = (new == 0)
	end
	
	if ( new == 0 and old > 0 ) then
		self:SendWeaponAnim( ACT_VM_UNDEPLOY )
	else
		if ( new > 0 and old == 0 ) then
			self:SendWeaponAnim( ACT_VM_DEPLOY )
		end
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "ZoomLevel")
	
	self:NetworkVarNotify("ZoomLevel", self.IronSightChanged)
	
	if (SERVER) then
		self:SetZoomLevel(0)
	end
end

function SWEP:Reload()
	if ( self:GetOwner():KeyPressed(IN_RELOAD) ) then
		self:SetZoomLevel( 0 )
		return false
	end

	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:Deploy()
	if ( SERVER ) then
		self:SetZoomLevel(0)
	end
	
	return true
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_CoD4_G3.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	local zoom = self:GetZoomLevel()

	--[[
	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, zoom > 0 and 0.0003 or 0.2, vcssRange, vcssPenetration )
	]]

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.0006, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	if (zoom == 0) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.60, -0.10 )
end

function SWEP:SecondaryAttack()
	local zoom = self:GetZoomLevel() + 1

	self:SetZoomLevel( zoom > 1 and 0 or zoom )

	self:SetNextSecondaryFire( CurTime() + 0.12 )
end