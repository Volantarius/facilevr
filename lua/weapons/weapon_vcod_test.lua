SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "test"
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_g36c.mdl")
SWEP.WorldModel = Model("models/weapons/svencoop/w_9mmhandgun.mdl")

SWEP.Primary.ClipSize 		= 45
SWEP.Primary.DefaultClip 	= 45
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Pistol"--"vdm_9mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vcod_test", "killicons/p228", Color(255, 255, 255, 255) )-- SHIT need duplicates

	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60--75

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/p228" )

	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	
	-- Wow no events for the svencoop guns.... 
	--[[function SWEP:FireAnimationEvent( pos, ang, event, options )
		print("penis", event)
	end]]
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSights")

	if (SERVER) then
		self:SetIronSights(false)
	end
end

function SWEP:Reload()
	local clip1 = self:Clip1()
	
	if ( clip1 > 1 ) then
		self:DefaultReload( ACT_VM_RELOAD )
	else
		self:DefaultReload( ACT_VM_RELOAD_EMPTY )
	end
	
	self:SetIronSights( false )
end

SWEP.vcssMaxPlayerSpeed = 250
SWEP.vcssWeaponPrice = 600

local vcssWeaponArmorRatio = 1.25
local vcssPenetration = 1
local vcssDamage = 40
local vcssRange = 4096
local vcssRangeModifier = 0.8
local vcssBullets = 1
local vcssCycleTime = 0.1

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_CoD4_MP5.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.004, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	--[[if ( clip1 > 1 ) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_EMPTY )
	end]]

	local irons = not self:GetIronSights()
	
	if (irons) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.70, -0.00 )
end

function SWEP:CanSecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.4 )
	
	local irons = not self:GetIronSights()
	
	self:SetIronSights( irons )
	
	if ( irons ) then
		self:SendWeaponAnim( ACT_VM_DEPLOY )
	else
		self:SendWeaponAnim( ACT_VM_UNDEPLOY )
	end
	
	--return false
end