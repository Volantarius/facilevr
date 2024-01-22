SWEP.Base = "weapon_vdm_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = Model("models/weapons/v_sythe.mdl")
SWEP.WorldModel = Model("models/weapons/w_sythe.mdl")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.m_WeaponDeploySpeed = 1.0

if CLIENT then
	SWEP.PrintName 	= "Sythe"
	
	SWEP.ViewModelFOV = 45
	
	SWEP.UseHands = true
	
	SWEP.DrawCrosshair = false
	
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vcss_knife", "killicons/knife", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/knife" )
	SWEP.WepSelectIconSquare = true
end

function SWEP:Initialize()
	self:SetHoldType("melee")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "IdleTime")
	self:NetworkVar("Float", 1, "SwingTime")
	self:NetworkVar("Int", 0, "SwingType")-- 0 none, 1 slash, 2 stab
end

function SWEP:Deploy()
	self:SetIdleTime( CurTime() + 2 )
	self:SetSwingTime( 0 )
	self:SetSwingType( 0 )
	
	return true
end

function SWEP:Think()
	if ( CurTime() > self:GetIdleTime() ) then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetIdleTime( CurTime() + 35 )-- Need to verify this idle time
	end
	
	local swingType = self:GetSwingType()
	
	-- Use zero as a off switch basically
	if ( swingType > 0 and CurTime() > self:GetSwingTime() ) then
		self:Swing( swingType )
		
		self:SetSwingType( 0 )
	end
end

function SWEP:Reload()
	return false
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:Swing( swingType )
	if ( CLIENT and game.SinglePlayer() ) then return end
	
	self.Owner:LagCompensation( true )
	
	self:ShootBullet( 40, swingType )
	
	self.Owner:LagCompensation( false )
end

-- Same as below
local swingDistance = 75

function SWEP:CheckMiss()
	local eyePos = self.Owner:GetShootPos()
	
	local tr = util.TraceHull({
		start = eyePos,
		endpos = eyePos + (self.Owner:GetAimVector() * swingDistance),
		mask = MASK_SHOT,
		filter = self.Owner,
		mins = Vector(-1,-1,-1) * 6,
		maxs = Vector(1,1,1) * 6
	})
	
	return ( not tr.Hit or tr.HitSky )
end

function SWEP:PrimaryAttack()
	self:EmitSound( "Weapon_Knife.Slash" )
	
	local miss = self:CheckMiss()
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( miss ) then
		self:SendWeaponAnim( ACT_VM_MISSCENTER )
		self:SetNextPrimaryFire( CurTime() + 0.4333 )
		self:SetNextSecondaryFire( CurTime() + 0.4333 )
	else
		self:SendWeaponAnim( ACT_VM_HITCENTER )
		self:SetNextPrimaryFire( CurTime() + 0.5166 )
		self:SetNextSecondaryFire( CurTime() + 0.5166 )
	end
	
	self:SetSwingTime( CurTime() + 0.1166 )-- Add the delay to finally fire the attack trace
	self:SetSwingType( 1 )
	
	self:SetIdleTime( CurTime() + 2 )
end

function SWEP:SecondaryAttack()
	-- Claim button
	return false
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet, swingType)
	dmginfo:SetDamageType( DMG_SLASH )
	dmginfo:SetAmmoType( -1 )
	
	if ( not tr.Hit ) then return end
	
	if ( tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ALIENFLESH ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		
		if ( IsValid(tr.Entity) && (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
			effectdata:SetEntity( tr.Entity )
		end
		
		util.Effect( "eff_vdm_bloodspout", effectdata, true, true )
		
		self:EmitSound( "Weapon_Knife.Hit" )
	else
		self:EmitSound( "Weapon_Knife.HitWall" )
	end
end

function SWEP:ShootBullet( damage, swingType )
	-- Made to have a melee style attack, don't need super crazy stuff
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( 0, 0, 0 )
	bullet.Tracer = 0
	bullet.Force = 15
	bullet.Damage = damage
	bullet.AmmoType = self.Primary.Ammo
	
	bullet.Distance = swingDistance
	
	bullet.HullSize = 8
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet, swingType)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.MatType == MAT_FLESH or tr.MatType == MAT_BLOODYFLESH or tr.MatType == MAT_ALIENFLESH ) then
		return false
	end
	
	return true
end