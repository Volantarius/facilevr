SWEP.Base = "weapon_vcss_base"

SWEP.PrintName 	= "FN P90"
SWEP.Author = "Volantarius"
SWEP.Category = "VCOD"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/cod4/weapons/v_p90_reflex.mdl")
--SWEP.WorldModel = Model("models/cod4/weapons/w_p90.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg_p90.mdl")

SWEP.Primary.ClipSize 		= 50
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "vdm_57mm"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 26

local lastSeq = 0-- Used for the laser

if CLIENT then
	killicon.Add( "weapon_vcod_p90", "killicons/p90", Color(255, 255, 255, 255) )

	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/p90" )
	
	SWEP.UseHands = false
	SWEP.ViewModelFOV = 60
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 2
	SWEP.SlotPos = 5
	
	function SWEP:CalcViewModelView( view_model, old_eyepos, old_eyeang, eyepos, eyeang )
		local irons = self:GetIronSights()
		
		if ( irons ) then
			local diff = (eyepos - old_eyepos) * 0.04
			
			return old_eyepos + diff, eyeang
		end
		
		return eyepos, eyeang
	end
	
	local MATglow = Material("effects/vollaser")
	local MATglow2 = Material( "sprites/physg_glow1" )
	local MATlaser = Material( "effects/playerlaser" )
	
	local seqTime = CurTime()
	local skipSequences = { --Which sequences to switch from, and time delay offset
		[6] = true,
		[7] = true,
		[2] = true,
		[3] = true
	}
	
	local MASK_LASER, util_TraceLine = bit.bxor( MASK_SHOT, CONTENTS_WINDOW ), util.TraceLine
	
	local laser_trace = {
		mask = MASK_LASER
	}
	
	function SWEP:PostDrawViewModel( vm, wep, ply )
		local seq = vm:GetSequence()
		
		if (seq ~= lastSeq) then
			lastSeq = seq
			
			if (not skipSequences[seq]) then
				local dur = vm:SequenceDuration(seq)
				
				seqTime = CurTime() + dur - 0.12
			end
		end
		
		local att = vm:GetAttachment(1)
		
		local att2 = vm:GetAttachment(2)
		
		local forward = att.Ang:Forward()
		local up = att2.Ang:Right()
		local right = up:Cross(forward)
		
		local fixedPos = self:FormatViewModelFov(self.ViewModelFOV, att.Pos, true)
		
		local startPos = fixedPos + (up * -1.1) + (forward * -1.2) + (right * 2.52)
		
		local endPos = startPos
		
		local frac = 4
		
		if (CurTime() < seqTime) then
			laser_trace.start = startPos - (forward * 15)
			laser_trace.endpos = startPos + (forward * 4000)
			laser_trace.filter = {vm,wep,ply}
			
			local tr = util_TraceLine(laser_trace)
			
			frac = tr.Fraction
			
			endPos = tr.HitPos
		else
			local aa = ply:GetShootPos()
			
			laser_trace.start = aa
			laser_trace.endpos = aa + (ply:GetAimVector() * 4000)
			laser_trace.filter = {vm,wep,ply}
			
			local ptr = util_TraceLine(laser_trace)
			
			frac = ptr.Fraction
			
			endPos = ptr.HitPos
		end
		
		render.SetMaterial( MATglow )
		
		render.DrawSprite( endPos, 4, 4, Color( 255, 255, 255, 192 ) )
		
		render.SetMaterial( MATlaser )
		
		local scrolltime = UnPredictedCurTime() * 0.07
		local scroll = math.ceil(scrolltime) - scrolltime
		
		render.DrawBeam( startPos, endPos, 0.4, scroll, scroll + frac, Color( 255, 0, 0, 64 ) )
		
		return false
	end
	
	SWEP.righthand_bone = -1
	
	function SWEP:DrawWorldModel( flags )
		self:DrawModel( flags )
		
		local p = self:GetOwner()
		
		if ( IsValid(p) ) then
			local eye_pos = p:EyePos()
			local aim_vec = p:GetAimVector()
			
			local start_pos = eye_pos
			local end_pos = eye_pos + (aim_vec * 4000)
			
			laser_trace.start = eye_pos
			laser_trace.endpos = end_pos
			laser_trace.filter = {self, p}
			
			local ptr = util_TraceLine( laser_trace )
			
			local laser_pos, frac = end_pos, 4
			
			if ( ptr.Hit ) then
				laser_pos = ptr.HitPos
				
				frac = ptr.Fraction
			end
			
			if ( self.righthand_bone == nil || self.righthand_bone < 0 ) then
				local bone_id = p:LookupBone( "ValveBiped.Bip01_R_Hand" )
				
				local matrix = p:GetBoneMatrix( bone_id )
				
				if ( matrix ) then
					start_pos = matrix:GetTranslation()
					
					self.righthand_bone = bone_id
				else
					self.righthand_bone = -1
				end
			else
				local matrix = p:GetBoneMatrix( self.righthand_bone )
				
				if ( matrix ) then
					start_pos = matrix:GetTranslation()
				else
					self.righthand_bone = -1
				end
			end
			
			render.SetMaterial( MATglow )
			
			render.DrawSprite( laser_pos, 4, 4, Color( 255, 255, 255, 192 ) )
			
			render.SetMaterial( MATlaser )
			
			local scrolltime = UnPredictedCurTime() * 0.07
			local scroll = math.ceil(scrolltime) - scrolltime
			
			render.DrawBeam( start_pos, laser_pos, 0.4, scroll, scroll + frac, Color( 255, 0, 0, 64 ) )
		end
	end
end

function SWEP:Deploy()
	if CLIENT then
		lastSeq = -1
		self.righthand_bone = -1
	end
	
	return true
end

function SWEP:OwnerChanged()
	if CLIENT then
		lastSeq = -1
		self.righthand_bone = -1
	end
end

function SWEP:Holster()
	if CLIENT then
		lastSeq = -1
		self.righthand_bone = -1
	end
	
	return true
end

function SWEP:IronSightChanged( name, old, new )
	if CLIENT then
		self.DrawCrosshair = (not new)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IronSights")
	
	self:NetworkVarNotify("IronSights", self.IronSightChanged)

	if (SERVER) then
		self:SetIronSights(false)
	end
end

function SWEP:Reload()
	local clip1 = self:Clip1()
	
	if ( clip1 > 1 ) then
		self:DefaultReload( ACT_VM_RELOAD )
	else
		self:DefaultReload( ACT_VM_RELOAD_EMPTY )
	end
	
	self:SetIronSights( false )
end

SWEP.vcssMaxPlayerSpeed = 245
SWEP.vcssWeaponPrice = 2350

local vcssWeaponArmorRatio = 1.5
local vcssPenetration = 1
local vcssDamage = 26
local vcssRange = 4096
local vcssRangeModifier = 0.84
local vcssBullets = 1
local vcssCycleTime = 0.07

function SWEP:Initialize()
	self:SetHoldType( "smg" )
end

local mathPow = math.pow
function SWEP:HandleDamageBonus( currentDistance, currentDamage, dmginfo )
	local newDamage = currentDamage * mathPow( vcssRangeModifier, (currentDistance / 500) )

	dmginfo:SetDamage( newDamage )

	dmginfo:SetDamageBonus( vcssWeaponArmorRatio )
end

local sfxSingle = Sound( "Vol_GE_AR33.Single" )--"Weapon_CoD4_P90.Single" )

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + vcssCycleTime )

	local clip1 = self:Clip1()

	if ( not self:CanPrimaryAttack( clip1 ) ) then return end

	self:EmitSound( sfxSingle )

	self:ShootBullet( vcssDamage, vcssBullets, 0.001, vcssRange, vcssPenetration )

	self:TakePrimaryAmmo( vcssBullets )

	local irons = not self:GetIronSights()
	
	if (irons) then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		-- lol no deployed empty
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_DEPLOYED )
	end

	self:ShootEffects()

	local ply = self:GetOwner()

	ply:VRecoil( -0.75, -0.25 )
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