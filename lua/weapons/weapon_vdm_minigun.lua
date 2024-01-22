SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel 	= "models/weapons/v_minigun.mdl"
SWEP.WorldModel = "models/weapons/w_minigun.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 200
SWEP.Primary.DefaultClip 	= 200
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "AR2"
SWEP.Primary.FireDelay 		= 0.0725

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

if CLIENT then
	SWEP.PrintName 	= "Edge Machine"
	
	SWEP.ViewModelFOV = 54
	
	SWEP.UseHands = false
	
	SWEP.Slot = 4
	SWEP.SlotPos = 1
	
	killicon.Add( "weapon_vdm_minigun", "killicons/ff_minigun", Color(255,255,255,255) )
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/ff_minigun" )
	
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		surface.SetDrawColor( 255, 236, 12, alpha )
		surface.SetTexture( self.WepSelectIcon )
		
		y = y + 30
		x = x + 30
		wide = wide - 60
		
		surface.DrawTexturedRectUV( x, y, wide, wide * 0.5, 1, 0, 0, 1 )
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FireTimer")
	self:NetworkVar("Float", 1, "FiredTime")
	self:NetworkVar("Bool", 0, "Firing")
end

function SWEP:Initialize()
	self:SetHoldType("physgun")
end

function SWEP:OnDrop()
	self:StopSound( "Vol_ByMySelf.Single" )
end

function SWEP:Holster()
	self:StopSound( "Vol_ByMySelf.Single" )
	return true
end

function SWEP:OnRemove()
	self:StopSound( "Vol_ByMySelf.Single" )
end

function SWEP:OwnerChanged()
	self:StopSound( "Vol_ByMySelf.Single" )
end

function SWEP:Think()
	if ( self:GetFiring() && (not self.Owner:KeyDown(IN_ATTACK) || not self:CanPrimaryAttack() ) ) then
		self:SetFiring(false)
		self:StopSound( "Vol_ByMySelf.Single" )
		self:SetNextPrimaryFire( CurTime() + 0.25 )
	end
	
	if ( self:GetFiring() && CurTime() > (self:GetFireTimer() + 0.85) ) then
		if ( CurTime() > self:GetFiredTime() ) then
			
			if ( self:CanPrimaryAttack() and not (CLIENT and game.SinglePlayer()) ) then
				self:EmitSound( "Weapon_M249.Single" )
				
				--self:ShootBullet( 32, 1, 0.012 )
				self:ShootBullet( 32, 1, 0.035 )
				
				self:TakePrimaryAmmo( 1 )
				
				--self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
				
				if ( IsValid(self.Owner) ) then
					--self.Owner:VRecoil( -1.55, -0.2 )
					self.Owner:VRecoil( -2.55, -0.7 )
					--self.Owner:VRecoil( math.Rand(-7, 0), math.Rand(-7, 7) )
				end
				
				self:ShootPrimaryEffects()
				
				self:SetFiredTime( CurTime() + self.Primary.FireDelay )
			else
				
			end
		end
	end
end

function SWEP:Deploy()
	self:SetFireTimer(0)
	self:SetFiredTime(0)
	self:SetFiring(false)
	
	return true
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

function SWEP:PrimaryAttack()
	if ( not self:CanPrimaryAttack() ) then return end
	
	self:SendWeaponAnim( ACT_VM_RECOIL3 )
	
	self:SetNextPrimaryFire( CurTime() + 0.25 )
	
	self:EmitSound( "Vol_ByMySelf.Single" )
	
	self:SetFiring(true)
	self:SetFireTimer(CurTime())
end

function SWEP:SecondaryAttack()-- TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEST
	--if ( not self:CanSecondaryAttack() ) then return end
	
	self:SetNextSecondaryFire( CurTime() + 0.25 )
	
	self:ShootBullet( 32, 1, 0 )
end

--[[function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	if ( CLIENT ) then return end -- SP is fine
	if ( not tr.Hit or tr.HitSky or tr.StartSolid ) then return end
	
	local dot = tr.Normal:Dot(tr.HitNormal)
	
	if ( dot > -0.65 and dot < 0 ) then
		local reflection = (-2 * dot * tr.HitNormal) + tr.Normal
		
		local bullet2 = bullet
		
		bullet2.Callback = nil
		
		bullet2.Src = tr.HitPos
		bullet2.Dir = reflection
		bullet2.Tracer = 1
		bullet2.Spread = Vector( 0.04, 0.04, 0 )
		bullet2.TracerName = "tracer_vol_incin_drop"
		
		timer.Simple( (tr.Fraction * 4096) / 900, function()
			self:FireBullets( bullet2, false )
			
			sound.Play( Sound("Vol_TS_RicochetNew.Single"), tr.HitPos + tr.HitNormal )
			
			local ed = EffectData()
			ed:SetOrigin( tr.HitPos )
			ed:SetNormal( tr.HitNormal )
			ed:SetScale( 1.0 )
			ed:SetMagnitude( 1.0 )
			util.Effect( "StunstickImpact", ed )
		end )
		
		return
	end
end]]

function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector( aimcone, aimcone, 0 )
	bullet.Tracer = tracer || 1
	bullet.Force = 50
	bullet.Damage = damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	bullet.TracerName = "tracer_vol_incin"
	
	--[[bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end]]
	
	self.Owner:FireBullets( bullet )
end