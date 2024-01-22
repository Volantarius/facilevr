SWEP.Base = "weapon_base"

SWEP.PrintName 	= "VDM Base Test"

SWEP.Category = "VDM"

SWEP.ViewModelFOV = 54

SWEP.ViewModel = Model("models/weapons/c_toolbow.mdl")
--SWEP.WorldModel = Model("models/weapons/w_toolbow.mdl")
SWEP.WorldModel = Model("models/weapons/w_toolgun.mdl")

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

SWEP.m_WeaponDeploySpeed = 1.0

-- USEFUL TOOL MASK
SWEP.FireMask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )

function SWEP:Initialize()
	self:SetHoldType("revolver")
end

function SWEP:SetupDataTables()
end

function SWEP:Think()
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:PrimaryAttack()
	
end

function SWEP:SecondaryAttack()
	
end

function SWEP:DoShootEffects( hitpos, hitnormal, entity, physbone, predicted )
	self:EmitSound( "Weapon_357.Single" )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( not predicted ) then return end
	
	local ed = EffectData()
	ed:SetOrigin( hitpos )
	ed:SetStart( self.Owner:GetShootPos() )
	ed:SetAttachment( 1 )
	ed:SetEntity( self )
	util.Effect( "ToolTracer", ed )
end

function SWEP:ConfirmedShootEffects( hitpos, hitnormal, entity, physbone, predicted )
	if ( not predicted ) then return end
	
	sound.Play( Sound( "FX_RicochetSound.Ricochet" ), hitpos )
	--sound.Play( "weapons/fx/rics/ric4.wav", hitpos, 90, 100, 1.0 )
	
	local ed = EffectData()
	ed:SetOrigin( hitpos + hitnormal )
	ed:SetNormal( hitnormal )
	util.Effect( "AR2Impact", ed )
end