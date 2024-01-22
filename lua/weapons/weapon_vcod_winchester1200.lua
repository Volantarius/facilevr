SWEP.Base = "weapon_vcss_m3"

SWEP.PrintName 	= "WINCHESTER 1200"--Replaces M3
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_winchester1200.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_winchester1200.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_m3super90.mdl")

SWEP.Primary.ClipSize 		= 8
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Buckshot"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 20

if CLIENT then
	killicon.Add( "weapon_vcod_winchester1200", "killicons/m3super", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/m3super" )
	
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
	SWEP.SlotPos = 6
end

SWEP.vcssMaxPlayerSpeed = 220
SWEP.vcssWeaponPrice = 1700

local vcssWeaponArmorRatio = 1.0
local vcssPenetration = 0
local vcssDamage = 26
local vcssRange = 3000
local vcssRangeModifier = 0.70
local vcssBullets = 9
local vcssCycleTime = 0.88--0.25

function SWEP:IronSightChanged( name, old, new )
	if CLIENT then
		self.DrawCrosshair = (not new)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSights")
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Bool", 2, "Pumping")
	self:NetworkVar("Float", 0, "ReloadTimer")
	
	self:NetworkVarNotify("IronSights", self.IronSightChanged)

	if (SERVER) then
		self:SetIronSights(false)
	end
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	
	self:SetReloadTimer( CurTime() + self:SequenceDuration() )
	
	self:SetPumping(false)
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Vol_MaxPayne_PumpShot.Single" )--"Weapon_CoD4_Winchester1200.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.14 )
	
	local irons = not self:GetIronSights()
	
	if (self:GetPumping()) then
		self:SetNextPrimaryFire( CurTime() + 0.32 )
		
		if (irons) then
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
		else
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED_1 )
		end
		
		self:SetPumping(false)
		
		return true
	end

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.04, vcssRange, vcssPenetration, 1, 0 )

	self:TakePrimaryAmmo( 1 )
	
	if (irons) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		-- lol no deployed empty
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.80, -0.35 )
	
	self:SetPumping(true)
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