SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "Volantarius"

SWEP.ViewModel = "models/weapons/v_sword.mdl"
SWEP.WorldModel = "models/weapons/w_sword.mdl"

--[[
	ACT_VM_MISSCENTER
	ACT_VM_HITCENTER
	ACT_VM_HITKILL
]]

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
	SWEP.PrintName 	= "Sword"
	
	SWEP.ViewModelFOV = 45
	SWEP.ViewModelFlip = false
	
	SWEP.UseHands = false
	
	SWEP.DrawCrosshair = false
	
	SWEP.Slot = 0
	SWEP.SlotPos = 2
	
	--[[killicon.Add( "weapon_vdm_drilldo", "killicons/drilldo", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/drilldo" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 60 + 16
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	end]]
end

function SWEP:Initialize()
	self:SetHoldType("melee2")
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	self:EmitSound( "Vol_Sword.Miss" )
	
	self:SetNextPrimaryFire( CurTime() + 0.55 )
	
	self:ShootEffects()
	
	self:ShootBullet( 32 )
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	dmginfo:SetDamageType( DMG_SLASH )
	
	if ( not tr.Hit ) then return end
	
	self:EmitSound( "Vol_Sword.Hit" )
	
	if ( tr.MatType == MAT_FLESH || tr.MatType == MAT_BLOODYFLESH ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		
		if ( IsValid(tr.Entity) && (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
			effectdata:SetEntity( tr.Entity )
		end
		
		util.Effect( "eff_vdm_bloodspout", effectdata, true, true )
	end
end

function SWEP:ShootBullet( damage )
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
	
	bullet.Distance = 67
	bullet.HullSize = 6
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	
	return false
	--[[if ( tr.MatType == MAT_FLESH || tr.MatType == MAT_BLOODYFLESH ) then
		return false
	end
	
	util.Decal( "ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal )
	return true]]
end