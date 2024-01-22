SWEP.Base = "weapon_vcss_m3"

SWEP.PrintName 	= "XM1014"
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_m1014.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_m1014.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_xm1014.mdl")

SWEP.Primary.ClipSize 		= 7
SWEP.Primary.DefaultClip 	= 7
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "Buckshot"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 20

if CLIENT then
	killicon.Add( "weapon_vcod_xm1014", "killicons/xm1014", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/xm1014" )
	
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
	SWEP.Slot = 3
	SWEP.SlotPos = 5
end

SWEP.vcssMaxPlayerSpeed = 240
SWEP.vcssWeaponPrice = 3000

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 0
local vcssDamage = 22
local vcssRange = 3000
local vcssRangeModifier = 0.70
local vcssBullets = 6
local vcssCycleTime = 0.25

function SWEP:IronSightChanged( name, old, new )
	if CLIENT then
		self.DrawCrosshair = (not new)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSights")
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Float", 0, "ReloadTimer")
	
	self:NetworkVarNotify("IronSights", self.IronSightChanged)

	if (SERVER) then
		self:SetIronSights(false)
	end
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Weapon_CoD4_M1014.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.04, vcssRange, vcssPenetration, 1, 0 )

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

	ply:VRecoil( -2.6, -0.2 )
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