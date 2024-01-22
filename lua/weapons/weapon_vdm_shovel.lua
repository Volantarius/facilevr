SWEP.Base = "weapon_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.ViewModel = "models/weapons/v_shovel.mdl"
SWEP.WorldModel = "models/weapons/w_shovel.mdl"

--[[
	ACT_VM_PRIMARYATTACK_1 -- Backhand
	ACT_VM_PRIMARYATTACK_2 -- To left
	ACT_VM_PRIMARYATTACK_3 -- STAB
	ACT_VM_PRIMARYATTACK_4 -- FAST BACKHAND
	ACT_VM_PRIMARYATTACK_5 -- FAST LEFT
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
	SWEP.PrintName 	= "Shovel"
	
	SWEP.ViewModelFOV = 54
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

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "SwingTime")
	self:NetworkVar("Bool", 0, "Swinging")
	self:NetworkVar("Bool", 1, "SwingToggle")
end

function SWEP:Deploy()
	if SERVER then
		self:SetSwingTime(0)
		self:SetSwinging(false)
	end
	
	return true
end

function SWEP:Initialize()
	self:SetHoldType("melee")
end

function SWEP:Think()
	if ( self:GetSwinging() && CurTime() > self:GetSwingTime() ) then
		local tgl = self:GetSwingToggle()
		self:Swing(tgl)
		self:SetSwinging(false)
		
		self:SetSwingToggle(not tgl)
	end
end

--[[///////////////////////////////////////////////////////////]]

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Swing(swingDir)
	if ( CLIENT and game.SinglePlayer() ) then return end
	
	self.Owner:LagCompensation( true )
	
	self:ShootBullet( 58, swingDir )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:LagCompensation( false )
end

function SWEP:PrimaryAttack()
	self:EmitSound( "Vol_Shovel.Miss" )
	
	if (self:GetSwingToggle()) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_4 )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_5 )
	end
	
	self:SetSwingTime(CurTime() + 0.045)
	self:SetSwinging(true)
	
	self:SetNextPrimaryFire( CurTime() + 0.35 )
end

function SWEP:BulletBack(attacker, tr, dmginfo, bullet)
	dmginfo:SetDamageType( DMG_SLASH )
	
	if ( not tr.Hit ) then return end
	
	if ( tr.MatType == MAT_FLESH || tr.MatType == MAT_BLOODYFLESH ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		
		if ( IsValid(tr.Entity) && (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) ) then
			effectdata:SetEntity( tr.Entity )
		end
		
		self:EmitSound( "Vol_Shovel.HitHard" )
		
		util.Effect( "eff_vdm_bloodspout", effectdata, true, true )
		
		--util.ScreenShake( tr.HitPos, 25, 30, 0.66, 250 )
	else
		self:EmitSound( "Vol_Shovel.HitMed" )
	end
end

function SWEP:ShootBullet( damage, swingDir )
	-- Made to have a melee style attack, don't need super crazy stuff
	local dir = self.Owner:GetAimVector()
	
	local smackDir = (self.Owner:EyeAngles()):Right()
	
	if (not swingDir) then
		smackDir = smackDir * -1
	end
	
	smackDir = smackDir + dir
	smackDir:Normalize()
	
	local bullet = {}
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos() - (smackDir * 16) + (dir * 36)
	bullet.Dir = smackDir
	bullet.Spread = Vector( 0, 0, 0 )
	bullet.Tracer = 0
	bullet.Force = 67
	bullet.Damage = damage
	bullet.AmmoType = self.Primary.Ammo
	
	bullet.Distance = 32
	bullet.HullSize = 16
	
	--bullet.TracerName = "tracer_vol_lazer_green"
	
	bullet.Callback = function (attacker, tr, dmginfo)
		self:BulletBack(attacker, tr, dmginfo, bullet)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.MatType == MAT_FLESH || tr.MatType == MAT_BLOODYFLESH ) then
		return false
	end
	
	return true
end