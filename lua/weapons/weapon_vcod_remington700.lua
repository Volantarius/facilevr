SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "REMINGTON 700"
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_remington700.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_remington700.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_scout.mdl")

SWEP.Primary.ClipSize 		= 10
SWEP.Primary.DefaultClip 	= 10
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "vdm_762mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 30

if CLIENT then
	killicon.Add( "weapon_vcod_remington700", "killicons/scout", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/scout" )
	
	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60
	
	--SWEP.DrawCrosshair = false

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 3
	SWEP.SlotPos = 2

	-- ////////////////////////////////////////////////////////////////////
	local Zoom = 1.0
	local newZoom = 1.0
	local LastTime = UnPredictedCurTime()

	function SWEP:TranslateFOV( current_fov )
		local NowTime = UnPredictedCurTime()
		local delta = NowTime - LastTime
		LastTime = NowTime
		
		local zoom = self:GetZoomLevel()
		
		--[[if ( CurTime() > self:GetNextPrimaryFire() ) then
			if ( zoom == 1 ) then
				newZoom = 0.50
			elseif ( zoom == 2 ) then
				newZoom = 0.25
			else
				newZoom = 1.00
				--delta = 100
			end

			Zoom = math.Approach( Zoom, newZoom, 5 * delta )
		else
			Zoom = 1.0
		end]]
		
		if ( zoom == 1 ) then
			newZoom = 0.50
		elseif ( zoom == 2 ) then
			newZoom = 0.25
		else
			newZoom = 1.00
			delta = 100
		end

		Zoom = math.Approach( Zoom, newZoom, 3 * delta )

		return current_fov * Zoom
	end

	function SWEP:AdjustMouseSensitivity()
		return Zoom
	end

	local crosshair = Material( "vdm/scopeblank2" )--superscope, scope, scopeblank

	function SWEP:DrawHUDBackground()
		if (Zoom >= 1.0) then return end
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( crosshair )

		local height = ScrH()
		local width = ScrW()

		local midPointX = width * 0.5
		local midPointY = height * 0.5

		local sX = height * (3 + (1 - Zoom))
		
		surface.DrawTexturedRectUV( midPointX - (sX*0.5), midPointY - (sX*0.5), sX, sX, -1, -1, 2, 2 )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		
		surface.DrawLine( 0, midPointY, width, midPointY )
		surface.DrawLine( midPointX, 0, midPointX, height )
	end
	
	function SWEP:CalcViewModelView( viewmodel, old_eyepos, old_eyeang, eyepos, eyeang )
		local amount = -64 * (1 - newZoom)
		
		return eyepos + (old_eyeang:Forward() * amount), eyeang
	end
end

SWEP.vcssMaxPlayerSpeed = 260
SWEP.vcssWeaponPrice = 2750

local vcssWeaponArmorRatio = 1.7
local vcssPenetration = 3
local vcssDamage = 75
local vcssRange = 8192
local vcssRangeModifier = 0.98
local vcssBullets = 1
local vcssCycleTime = 1.25

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

--function SWEP:Think()
--end

function SWEP:Reload()
	if ( self:GetOwner():KeyPressed(IN_RELOAD) ) then
		self:SetZoomLevel( 0 )
	end

	local clip1 = self:Clip1()
	
	if ( clip1 > 1 ) then
		self:DefaultReload( ACT_VM_RELOAD )
	else
		self:DefaultReload( ACT_VM_RELOAD_EMPTY )
	end
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

local sfxSingle = Sound( "Weapon_CoD4_Remington700.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	local zoom = self:GetZoomLevel()

	self:EmitSound( sfxSingle )

	--self:ShootBullet( vcssDamage, vcssBullets, zoom > 0 and 0.0003 or 0.09, vcssRange, vcssPenetration )
	self:ShootBullet( vcssDamage, vcssBullets, 0.0003, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )
	
	if (zoom == 0) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		-- lol no deployed empty
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.50, -0.10 )
end

local sfxZoom = Sound( "Default.Zoom" )

function SWEP:SecondaryAttack()
	local zoom = self:GetZoomLevel() + 1

	self:EmitSound( sfxZoom )

	self:SetZoomLevel( zoom > 2 and 0 or zoom )

	self:SetNextSecondaryFire( CurTime() + 0.12 )
end