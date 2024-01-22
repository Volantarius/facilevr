AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.PrintName = "Testin TWO"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Instructions = [[<color=230,230,150,255>Primary:</color> Possess an object.

<color=230,230,150,255>Reload:</color> Return to last object you possessed.

<color=230,230,150,255>USE:</color> Stop possessing.]]

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if CLIENT then
	SWEP.DrawAmmo = false
	SWEP.ViewModelFOV = 54
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 0
	SWEP.SlotPos = 3
	
	function SWEP:PrintWeaponInfo( x, y, alpha )
		if ( self.InfoMarkup == nil ) then
			local str
			
			str = "<font=HudSelectionText>"
			str = str .. self.Instructions
			str = str .. "</font>"
			
			self.InfoMarkup = markup.Parse( str, 250 )
		end
		
		surface.SetDrawColor( 60, 60, 60, alpha )
		surface.SetTexture( self.SpeechBubbleLid )
		
		surface.DrawTexturedRect( x, y-64-5, 128, 64 )
		draw.RoundedBox( 8, x-5, y-6, 260, self.InfoMarkup:GetHeight() + 18, Color( 60, 60, 60, alpha ) )
		
		self.InfoMarkup:Draw( x+5, y+5, nil, nil, alpha )
	end
	
	--function SWEP:DrawWorldModel() end
	--function SWEP:DrawWorldModelTranslucent() end
end

SWEP.SndSelectDeny = Sound( "HL2Player.UseDeny" )
SWEP.SndSelectOk = Sound( "weapons/physgun_off.wav" )

function SWEP:SetupDataTables()
end

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

local fartPoint = Vector(0,0,0)
local fartDist = 128
local lastVelocity = Vector(0,0,0)

function SWEP:Think()
	
	if ( self.Owner:KeyPressed( IN_ATTACK ) ) then
		local tr = self.Owner:GetEyeTrace()
		
		if ( tr.HitPos ) then
			fartPoint = tr.HitPos - Vector(0,0,63)
			
			local oldPos = self.Owner:GetPos()
			
			fartDist = oldPos:Distance( fartPoint )
			
			fartDistMul = math.max(0, 1 - (fartDist / 512))
		end
	end
	
	if ( self.Owner:KeyDown( IN_ATTACK ) ) then
		local origVelocity = self.Owner:GetVelocity()
		local cancelVelocity = origVelocity * -1
		
		local newVelocity = Vector(0,0,0)
		
		if (fartPoint) then
			local oldPos = self.Owner:GetPos()
			
			local aimVec = self.Owner:GetAimVector()
			
			local newPos = fartPoint - ( fartDist * aimVec )
			
			local newNew = newPos - oldPos
			
			local newNorm = newNew:GetNormalized()
			
			newNew = newNorm * math.min(newNew:Length(), 400)
			
			newVelocity = newNew * (fartDistMul * 5)
		end
		
		self.Owner:SetVelocity( (origVelocity * 1 * (1 - fartDistMul)) + cancelVelocity + newVelocity )
		
		lastVelocity = newVelocity
	end
	
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 0.1 )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.25 )
	
	self.Owner:EmitSound(self.SndSelectDeny)
	
	return false
end

function SWEP:Reload()
	-- Make this function semi-automatic
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end
	
	self.Owner:EmitSound(self.SndSelectDeny)
	
	return false
end