SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "TFC Sniper"
SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/cod4/weapons/v_dragunov.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_snip_g3sg1.mdl" )

SWEP.Primary.ClipSize 		= 20
SWEP.Primary.DefaultClip 	= 20
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "vdm_762mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.PullMaxTime = 1.0
SWEP.Weight = 30

if CLIENT then
	SWEP.Slot = 3
	SWEP.SlotPos = 7
	
	killicon.Add( "weapon_vdm_tfcsniper", "killicons/g3", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/g3" )
	
	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60
	
	SWEP.DrawCrosshair = true
	
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
			newZoom = 0.45
		elseif ( zoom == 2 ) then
			newZoom = 0.20
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

	local crosshair = Material( "vdm/scopeblank" )

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
		local amount = -100 * (1 - newZoom)
		
		return eyepos + (old_eyeang:Forward() * amount), eyeang
	end
end

-- Scout's settings
SWEP.vcssMaxPlayerSpeed = 260
SWEP.vcssWeaponPrice = 2750

local vcssWeaponArmorRatio = 1.7
local vcssPenetration = 3
local vcssDamage = 75
local vcssRange = 8192
local vcssRangeModifier = 0.98
local vcssBullets = 1
local vcssCycleTime = 0.18

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
	self:NetworkVar("Bool", 0, "PulledBack")
	self:NetworkVar("Float", 0, "PulledTime")
	
	self:NetworkVar("Int", 0, "ZoomLevel")

	self:NetworkVarNotify("ZoomLevel", self.IronSightChanged)

	if ( SERVER ) then
		self:SetZoomLevel(0)
	end
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType( "crossbow" )
end

function SWEP:Think()
	if ( self:GetPulledBack() ) then
		local PulledTime = self:GetPulledTime()
		
		if ( not self.Owner:KeyDown(IN_ATTACK) and CurTime() > PulledTime ) then
			self:SetPulledBack( false )
			
			self:Release( CurTime() - PulledTime )
		end
	end
end

--[[function SWEP:Reload()
	if ( self:GetOwner():KeyPressed(IN_RELOAD) ) then
		self:SetZoomLevel( 0 )
	end

	self:DefaultReload( ACT_VM_RELOAD )
end]]

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
		self:SetZoomLevel( 0 )
		self:SetPulledBack( false )
		self:SetPulledTime( 0 )
	end
	
	return true
end

--[[///////////////////////////////////////////////////////////]]

local sfx_single = Sound( "Vol_MaxPayne_SSG.Single" )

local math_min = math.min

-- New pull and release mechanics
function SWEP:Release( heldtime )
	if ( CLIENT and game.SinglePlayer() ) then return end
	
	local ChargeTime = math_min( heldtime, self.PullMaxTime ) / self.PullMaxTime
	
	local zoom = self:GetZoomLevel()
	
	self:EmitSound( sfx_single )
	
	if (zoom == 0) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		-- lol no deployed empty
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end
	
	self:ShootEffects()
	
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	
	self:ShootBullet( (ChargeTime * 80) + 24, vcssBullets, 0.002, vcssRange, vcssPenetration )
	
	self:TakePrimaryAmmo( vcssBullets )
	
	if ( IsValid(self.Owner) ) then
		self.Owner:VRecoil( -1.6 - (ChargeTime * 10.0), -1.37 )
	end
end

function SWEP:PullBack()
	self:SetPulledBack( true )
	
	self:SetPulledTime( CurTime() + 0.0 )
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	
	local clip1 = self:Clip1()
	
	if ( not self:CanPrimaryAttack( clip1 ) ) then return end
	
	self:PullBack()
end

local sfxZoom = Sound( "Default.Zoom" )

function SWEP:SecondaryAttack()
	local zoom = self:GetZoomLevel() + 1

	self:EmitSound( sfxZoom )

	self:SetZoomLevel( zoom > 2 and 0 or zoom )

	self:SetNextSecondaryFire( CurTime() + 0.12 )
end