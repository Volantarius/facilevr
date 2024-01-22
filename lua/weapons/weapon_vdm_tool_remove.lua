SWEP.Base = "weapon_vdm_tool_base"

SWEP.Author 	= "Volantarius"
SWEP.Category 	= "VDM"

SWEP.Spawnable = false-- Ehh too overpowered, shouldn't be deleting entities
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "XBowBolt"
SWEP.Primary.FireDelay 		= 0.15

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

if CLIENT then
	SWEP.PrintName 	= "(TOOL) REMOVE"
	SWEP.ToolName = "Remove Tool"
	SWEP.Description = "Get rekt."
	SWEP.info = [[Remove objects for crossbow ammo!]]
	SWEP.info_left = "Remove an object!"
	
	killicon.Add( "weapon_vdm_tool_remove", "killicons/swep_default", Color(255, 255, 255, 255) )
	
	SWEP.ViewModelFOV = 60
	
	SWEP.UseHands = true
	
	SWEP.DrawAmmo = true
	
	SWEP.Slot = 5
	SWEP.SlotPos = 9
end

--[[///////////////////////////////////////////////////////////]]

local toolmask = SWEP.FireMask

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireDelay )
	
	--[[if ( self:Ammo1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		return false
	end]]
	
	local pl = self.Owner
	
	local tr = util.GetPlayerTrace( pl )
	tr.start = pl:GetShootPos()
	tr.mask = toolmask
	local trace = util.TraceLine( tr )
	
	if ( not trace.Hit ) then return end
	
	local pred = IsFirstTimePredicted()
	
	self:DoShootEffects( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, pred )
	
	local good = self:do_remove( trace, pred )
	
	if ( good ) then
		self:ConfirmedShootEffects( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, pred )
		
		--self:TakePrimaryAmmo( 1 )
		-- We get ammo from this lol
		if ( SERVER ) then
			pl:GiveAmmo( 1, "XBowBolt", true )
		end
	end
end

function SWEP:SecondaryAttack()
	--
end

function SWEP:Reload()
	if ( CurTime() <= (self:GetNextPrimaryFire() + self.Primary.FireDelay) ) then return false end
	
	self:DefaultReload( ACT_VM_RELOAD )
end

function SWEP:do_remove( tr, predicted )
	local ent = tr.Entity
	
	if ( tr.HitSky ) then return false end
	if ( not IsValid(ent) ) then return false end
	
	-- Nail test
	if ( SERVER ) then
		local vOrigin = tr.HitPos - (tr.Normal * 8.0)
		local vDirection = tr.Normal:Angle()
		
		vOrigin = ent:WorldToLocal( vOrigin )
		
		local Pos = ent:LocalToWorld( vOrigin )
		
		if ( ent:IsPlayer() or ent:IsNPC() ) then
			local dmg = DamageInfo()
			dmg:SetDamage( 9999999 )
			dmg:SetAttacker( self.Owner )
			dmg:SetInflictor( self.Weapon or self )
			dmg:SetDamageForce( tr.Normal * 34 )
			dmg:SetDamagePosition( tr.StartPos )
			dmg:SetDamageType( bit.bor(DMG_ALWAYSGIB, DMG_DISSOLVE ) )
			
			ent:DispatchTraceAttack(dmg, tr, tr.Normal)
		else
			if (not util.IsValidPhysicsObject( ent, tr.PhysicsBone )) then return false end
			
			if ( predicted ) then-- So thing like that, this aint workin
				local ed = EffectData()
					ed:SetOrigin( ent:GetPos() )
					ed:SetEntity( ent )
				util.Effect( "vdm_entity_remove", ed, true, true )
			end
			
			constraint.RemoveAll( ent )
			
			ent:Remove()
		end
		
	end
	
	return true
end