SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "Nail Gun"
SWEP.Category = "Volantarius"

SWEP.Spawnable = true

SWEP.ViewModel 	= Model("models/weapons/v_grease.mdl")
SWEP.WorldModel = Model("models/weapons/w_grease.mdl")

SWEP.Primary.ClipSize 		= 50
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "XBowBolt"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 20

if CLIENT then
	killicon.Add( "weapon_vdm_nailgun", "killicons/csgo_mp7", Color(255, 255, 255, 255) )

	SWEP.WepSelectIconSquare = true

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/csgo_mp7" )

	SWEP.Category 	= "VDM"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = false
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 3
	SWEP.SlotPos = 4
end

local vdmCycleTime = 0.12

function SWEP:Initialize()
	self:SetHoldType("smg")
end

local sfxSingle = Sound( "Vol_TFC_Nailgun.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vdmCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )
	
	self:ShootObject( 16, 0.4 )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.20, -0.05 )
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:ShootObject( damage, aimcone )
	local ply = self:GetOwner()

	if CLIENT then return end

	SuppressHostEvents( NULL )
	
	local ent = ents.Create( "crossbow_bolt" )
	if ( !IsValid(ent) ) then return end
	
	local finalAngles = ply:GetAimVector():Angle() + ply:GetViewPunchAngles()
	finalAngles = finalAngles + Angle( math.Rand(-1 * aimcone, aimcone), math.Rand(-1 * aimcone, aimcone), 0 )
	
	local Forward = finalAngles:Forward()
	
	ent:SetVelocity( Forward * 2000 )
	
	--ent:SetPos( ply:GetShootPos() + Forward * 32 )
	ent:SetPos( ply:GetShootPos() )
	ent:SetAngles( finalAngles )
	ent:SetOwner( ply )
	ent:Fire( "SetDamage", tostring(damage) )
	
	ent:Spawn()
	ent:Activate()
end