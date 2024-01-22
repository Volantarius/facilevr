SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "Pulse Rifle"
SWEP.Author = "Volantarius"
SWEP.Category = "VHL"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_irifle.mdl")
SWEP.WorldModel = Model("models/weapons/w_irifle.mdl")

SWEP.Primary.ClipSize 		= 30
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "AR2"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "AR2AltFire"

SWEP.Weight = 5

if CLIENT then
	killicon.Add( "weapon_vhl_ar2", "killicons/ar2", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/ar2" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 1
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "PulledBack")
	self:NetworkVar("Bool", 1, "Releasing")
	
	--self:NetworkVar("Bool", 2, "PulledLoop")
	
	self:NetworkVar("Float", 0, "PulledTime")
	self:NetworkVar("Float", 1, "ReleasedTime")
end

local sfxSpecial1 = Sound( "Weapon_CombineGuard.Special1" )
local sfxSingle = Sound( "Weapon_AR2.Single" )
local sfxSecondary = Sound( "Weapon_IRifle.Single" )
local sfxEmpty = Sound( "Weapon_AR2.Empty" )

function SWEP:PullBack()
	self:SendWeaponAnim( ACT_VM_FIDGET )
	
	self:SetPulledBack( true )
	
	self:EmitSound( sfxSpecial1 )
	
	local t = CurTime()
	
	self:SetPulledTime( t + 0.9 )
	self:SetNextPrimaryFire( t + 0.9 )
	self:SetNextSecondaryFire( t + 0.9 )
end

function SWEP:Release( heldtime )
	if ( CLIENT and game.SinglePlayer() ) then return end
	
	--local ChargeTime = math.min( heldtime, 1 ) / 1
	
	self:EmitSound( sfxSecondary )
	
	local t = CurTime()
	
	self:SetNextPrimaryFire( t + 0.50 )
	self:SetNextSecondaryFire( t + 1.0 )
	
	--self:ShootBullet( (ChargeTime*90)+16, 1, 0.0, self.Primary.Ammo, (ChargeTime*50.0) + 10.0, ChargeTime )
	
	self:TakeSecondaryAmmo( 1 )
	
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
	self:ShootEffects()
	
	local ply = self.Owner
	
	if ( IsValid(ply) ) then
		ply:VRecoil( -5.90, 0.40 )
		
		if ( SERVER ) then
			local combine_ball = ents.Create( "prop_combine_ball" )
			
			local shoot_pos = ply:GetShootPos()
			local shoot_vec = ply:GetAimVector()
			
			combine_ball:SetPos( shoot_pos )
			
			combine_ball:SetOwner( ply )
			
			combine_ball:SetSaveValue( "m_flRadius", 10 )
			combine_ball:SetSaveValue( "m_flDuration", 2 )
			
			combine_ball:Spawn()
			
			combine_ball:SetSaveValue( "m_flSpeed", 1000 )
			
			combine_ball:SetSaveValue( "m_nState", 2 )
			
			local phys = combine_ball:GetPhysicsObject()
			
			if ( IsValid(phys) ) then
				phys:SetVelocityInstantaneous( shoot_vec * 1000 )
				phys:SetMass( 150 )
				phys:AddGameFlag( FVPHYSICS_WAS_THROWN )
			end
			
			combine_ball:SetSaveValue( "m_flDuration", 2 )
			
			combine_ball:SetSaveValue( "m_bWeaponLaunched", true )
			
			combine_ball:SetSaveValue( "m_flRadius", 10 )
		end
	end
end

function SWEP:Think()
	local t = CurTime()
	
	if ( self:GetPulledBack() ) then
		if ( not self.Owner:KeyDown(IN_ATTACK2) and t > self:GetPulledTime() ) then
			self:SetReleasedTime( t )
			
			self:SetPulledBack( false )
			
			self:SetReleasing( true )
		end
	end
	
	if ( self:GetReleasing() and not self:GetPulledBack() and t > (self:GetReleasedTime() + 0.0) ) then
		self:Release( t - self:GetPulledTime() )
		
		self:SetReleasing( false )
	end
end

function SWEP:Deploy()
	if SERVER then
		self:SetPulledBack( false )
		self:SetReleasing( false )
		self:SetPulledTime( 0 )
		self:SetReleasedTime( 0 )
	end
	
	return true
end

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 2
local vcssDamage = 24
local vcssRange = 4096
local vcssRangeModifier = 0.81
local vcssBullets = 1
local vcssCycleTime = 0.1

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

function SWEP:Initialize()
	self:SetHoldType("ar2")
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )
	self:SetNextSecondaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.013, vcssRange, vcssPenetration, 1, 1, "tracer_vol_ar2" )

	self:TakePrimaryAmmo( 1 )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootEffects()

	local ply = self:GetOwner()
	
	if ( ply:IsPlayer() ) then
		ply:VRecoil( -0.90, -0.40 )
	end
end

function SWEP:CanSecondaryAttack( clip )
	clip = clip || self:Ammo2()

	if ( clip <= 0 ) then
		self:EmitSound( sfxEmpty )

		return false
	end

	return true
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire( CurTime() + 1.0 )
	self:SetNextSecondaryFire( CurTime() + 1.0 )
	
	local clip2 = self:Ammo2()

	if ( not self:CanSecondaryAttack( clip2 ) ) then return end
	
	self:PullBack()
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.HitSky ) then return false end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "AR2Impact", effectdata )
	
	return false
end