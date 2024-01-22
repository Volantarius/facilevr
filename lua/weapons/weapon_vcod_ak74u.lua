SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "AK-74u"-- REPLACES GALIL
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_ak74u.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_skorpion.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_galil.mdl")

SWEP.Primary.ClipSize 		= 35
SWEP.Primary.DefaultClip 	= 35
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_762mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 25

if CLIENT then
	killicon.Add( "weapon_vcod_ak74u", "killicons/csgo_bizon", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/csgo_bizon" )
	
	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60
	
	function SWEP:CalcViewModelView( view_model, old_eyepos, old_eyeang, eyepos, eyeang )
		local irons = self:GetIronSights()
		
		if ( irons ) then
			local diff = (eyepos - old_eyepos) * 0.04
			
			return old_eyepos + diff, eyeang
		end
		
		return eyepos, eyeang
	end
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 4
end

SWEP.vcssMaxPlayerSpeed = 215
SWEP.vcssWeaponPrice = 2000

local vcssWeaponArmorRatio = 1.55
local vcssPenetration = 2
local vcssDamage = 30
local vcssRange = 8192
local vcssRangeModifier = 0.98
local vcssBullets = 1
local vcssCycleTime = 0.09

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:IronSightChanged( name, old, new )
	if CLIENT then
		self.DrawCrosshair = (not new)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSights")
	
	self:NetworkVarNotify("IronSights", self.IronSightChanged)
	
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

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_CoD4_AK74u.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )
	
	self:ShootBullet( vcssDamage, vcssBullets, 0.0006, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( 1 )

	local irons = not self:GetIronSights()
	
	if (irons) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		-- lol no deployed empty
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.90, -0.40 )
end

function SWEP:CanSecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.2 )
	
	local irons = not self:GetIronSights()
	
	self:SetIronSights( irons )
	
	if ( irons ) then
		self:SendWeaponAnim( ACT_VM_DEPLOY )
	else
		self:SendWeaponAnim( ACT_VM_UNDEPLOY )
	end
end