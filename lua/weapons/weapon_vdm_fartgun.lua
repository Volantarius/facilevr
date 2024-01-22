SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 17
SWEP.Primary.DefaultClip 	= 17
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "Pistol"
SWEP.Primary.FireDelay 		= 0.13

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"
SWEP.Secondary.FireDelay 	= 0.15

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Dysentery Gun"
	
	SWEP.VdmSecondaryName = "FART"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = true
	
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_fartgun", "killicons/glock", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/glock" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 128, 0, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:Think()
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootPrimaryEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	if ( self:Clip1() <= 0 ) then
		self:EmitSound( "Vol_TS_Dry.Single" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
		
		return false
	end
	
	return true
end

--local sfxSingle = Sound( "Weapon_Glock.Single" )
local sfxSingle = Sound( "Vol_GE_DD44.Single" )
local sfxFart = Sound( "Vol_Conker_Fart.Single" )

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self:EmitSound( sfxSingle )
	
	self:ShootBullet( 22, 1, 0.010, self.Primary.Ammo )
	
	self:TakePrimaryAmmo( 1 )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	self.Owner:VRecoil( -0.27, -0.02 )
	
	self:ShootPrimaryEffects()
end

function SWEP:SecondaryAttack()
	self.Owner:EmitSound( sfxFart )
	
	self:BlastFart()
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.FireDelay )
	
	if ( !IsValid(self.Owner) ) then return end
	
	if ( self.Owner:OnGround() and not self.Owner:KeyDown(IN_DUCK) ) then return end
	
	local newVelocity = (self.Owner:GetVelocity() * -1) + (self.Owner:GetAimVector() * 700)
	
	self.Owner:SetVelocity( newVelocity )-- Actually adds velocity so reverse it yo
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = force || 1
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_timesplit"
	
	self.Owner:FireBullets( bullet )
end

local fartOffset = Vector(0,0,20)

function SWEP:BlastFart()
	if ( !IsValid(self.Owner) ) then return end
	
	local aimVector = self.Owner:GetAimVector()
	
	local buttStartPos = self.Owner:GetPos() + fartOffset
	
	local buttDir = Vector(aimVector.x, aimVector.y, 0) * -1
	buttDir:Normalize()
	
	local dmg = DamageInfo()
	dmg:SetDamage(500)
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self.Weapon or self)
	dmg:SetDamageForce(buttDir * 24)
	dmg:SetDamagePosition(buttStartPos)
	dmg:SetDamageType(DMG_ALWAYSGIB)
	
	local data = EffectData()
	data:SetOrigin( (buttStartPos + Vector(0,0,20)) + (buttDir * 4) )
	data:SetNormal( buttDir )
	util.Effect( "eff_vdm_fart", data )
	
	local tr = util.TraceHull({
		start = buttStartPos,
		endpos = buttStartPos + (buttDir * 45), -- Inverted to face away from player
		filter = {self.Owner, self},
		maxs = Vector(1,1,1) * 10,
		mins = Vector(-1,-1,-1) * 10,
		mask = MASK_ALL
	})
	
	if (tr.Hit and IsValid(tr.Entity)) then
		if (!IsValid(self.Owner)) then return end
		self.Owner:LagCompensation( true )
		
		tr.Entity:DispatchTraceAttack( dmg, tr, buttDir )
		
		if (!IsValid(self.Owner)) then return end
		self.Owner:LagCompensation( false )
		
		if (!tr.Entity:IsPlayer()) then
			local phys = tr.Entity:GetPhysicsObject()
			
			if ( IsValid(phys) && phys:GetMass() < 500 ) then
				tr.Entity:EmitSound( Sound("Vol_Conker_BigRico.Single") )
				
				phys:Wake()
				
				phys:ApplyForceCenter( (buttDir + Vector(0,0,0.15)) * 9000 * (500 - phys:GetMass()) )
				
				if (SERVER) then
					tr.Entity:SetPhysicsAttacker(self.Owner, 5)
				end
				-- Also add phys attacker to the entity!
				-- Do this for shovel and anything that can launch shit
			end
		end
	end
end