SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "VR Gloves Fixed Angles"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_physcannon.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_physics.mdl" )
SWEP.VRModel = Model( "models/weapons/w_physics.mdl" )

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.Weight = 5

local sfx_launch = Sound("Weapon_PhysCannon.Launch")
local sfx_dry = Sound("Weapon_PhysCannon.DryFire")
local sfx_pickup = Sound("Weapon_PhysCannon.Pickup")
local sfx_claws_open = Sound("Weapon_PhysCannon.OpenClaws")
local sfx_claws_close = Sound("Weapon_PhysCannon.CloseClaws")
local sfx_drop = Sound("Weapon_PhysCannon.Drop")
local sfx_hold = Sound("Weapon_PhysCannon.HoldSound")

--local bNWActive = false
--local held_entity = nil

local held_old_mass = 0
local held_old_lin_damping = 0
local held_old_ang_damping = 0
local held_old_owner = nil

function SWEP:HeldEntityChanged( name, old, new )
	if ( old ~= new ) then
		--[[if ( not new ) then
			self:EmitSound( sfx_drop )
		end]]
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "HeldEntity")
	
	self:NetworkVarNotify("HeldEntity", self.HeldEntityChanged)
end

if CLIENT then
	killicon.Add( "weapon_vdmvr_grabgloves", "killicons/gravitygun", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = false
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/gravitygun" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	
	--local BLAHFormatViewModelFov = SWEP.FormatViewModelFov
	
	--local MAT_GLOW = Material("effects/vollaser")
	local MAT_GLOW = Material( "sprites/physg_glow1" )
	local MAT_LASER = Material( "effects/fadelaser_1" )
	
	function SWEP:PostDrawViewModel( vm, wep, p )
		local att = vm:GetAttachment( 1 )
		
		local fixed_pos = self:FormatViewModelFov( self.ViewModelFOV, att.Pos, true )
		
		render.SetMaterial( MAT_GLOW )
		
		render.DrawSprite( fixed_pos, 38, 38, Color( 255, 120, 0, 192 ) )
		
		local held_entity = self:GetHeldEntity()
		
		if ( IsValid( held_entity ) ) then
			local end_pos = held_entity:WorldSpaceCenter()
			
			render.SetMaterial( MAT_LASER )
			
			--local scrolltime = UnPredictedCurTime() * 2.0
			--local scroll = math.ceil(scrolltime) - scrolltime
			
			--render.DrawBeam( fixed_pos, end_pos, 4, scroll, scroll + 1, Color( 255, 120, 0, 120 ) )
			
			render.DrawBeam( fixed_pos, end_pos, 4, 0, 1, Color( 255, 120, 0, 120 ) )
		end
		
		return false
	end
end

local function attach_object( wep, p, e )
	--if ( bNWActive ) then return false end
	
	local held_entity = wep:GetHeldEntity()
	
	-- If already holding an entity then don't attach more
	if ( IsValid( held_entity ) ) then return end
	
	-- Can pickup check
	local e_physics = e:GetPhysicsObject()
	
	if ( !IsValid( e_physics ) ) then return end
	
	if ( !IsValid( p ) ) then return end
	
	--wep:StartMotionController()
	
	--wep:AddToMotionController( e_physics )
	
	held_old_lin_damping, held_old_ang_damping = e_physics:GetDamping()
	
	e_physics:SetDamping( held_old_lin_damping, 10 )
	
	e_physics:EnableMotion( true )
	
	e_physics:EnableDrag( false )
	
	held_old_owner = e:GetOwner()
	
	p:SimulateGravGunPickup( e, true )
	
	--bNWActive = true
	--held_entity = e
	wep:SetHeldEntity( e )
	
	e:SetOwner( p )
	
	wep:EmitSound( sfx_pickup )
end

local function detach_held_object( wep, p )
	local held_entity = wep:GetHeldEntity()
	
	if ( IsValid( held_entity ) ) then
		--held_entity:SetOwner( nil )
		held_entity:SetOwner( held_old_owner )
		
		local e_physics = held_entity:GetPhysicsObject()
		
		if ( IsValid( e_physics ) ) then
			--wep:RemoveFromMotionController( e_physics )
			
			e_physics:SetDamping( held_old_lin_damping, held_old_ang_damping )
			
			e_physics:EnableDrag( true )
			
			e_physics:Wake()
		end
	end
	
	--wep:StopMotionController()
	
	wep:SetHeldEntity( nil )
	
	--if ( !IsValid( p ) ) then return end
end

local g_mask = bit.bor( MASK_SHOT, CONTENTS_GRATE )

function SWEP:OnDrop()
	detach_held_object( self, self:GetOwner() )
end

function SWEP:Holster()
	detach_held_object( self, self:GetOwner() )
	return true
end

function SWEP:OnRemove()
	detach_held_object( self, self:GetOwner() )
end

function SWEP:OwnerChanged()
	detach_held_object( self, self:GetOwner() )
end

function SWEP:Initialize()
	self:SetHoldType( "physgun" )
end

function SWEP:Think()
	local p = self:GetOwner()
	
	local held_entity = self:GetHeldEntity()
	local holding_entity = IsValid( held_entity )
	
	if ( not holding_entity ) then
		detach_held_object( self, p )
	end
	
	if ( holding_entity ) then
		local shoot_position = p:GetShootPos()
		local aim_vector = p:GetAimVector()
		
		local radius = held_entity:BoundingRadius()
		
		local tr = util.TraceLine({
			start = shoot_position,
			endpos = shoot_position + (aim_vector * (48 + radius)),
			filter = {p, held_entity},
			mask = MASK_SOLID_BRUSHONLY
		})
		
		local target_position = shoot_position + (aim_vector * (48 + radius))
		
		if ( tr.Hit ) then
			target_position = tr.HitPos
		end
		
		local real_offset = held_entity:WorldSpaceCenter() - held_entity:GetPos()
		
		target_position = target_position - real_offset - (aim_vector * radius)
		
		local e_physics = held_entity:GetPhysicsObject()
		
		if ( IsValid(e_physics) ) then
			e_physics:Wake()
			
			local phys_pos = e_physics:GetPos()
			local phys_ang = e_physics:GetAngles()
			
			local velocity_ang = e_physics:GetAngleVelocity()
			local velocity = e_physics:GetVelocity()
			
			local output_velocity_ang = velocity_ang
			local output_velocity = velocity
			
			local snapshot = e_physics:GetFrictionSnapshot()
			
			if ( snapshot and #snapshot > 0 ) then
				for k,dat in ipairs( snapshot ) do
					if ( IsValid(dat.Other) and dat.Other:IsMoveable() ) then
						local snap_normal = dat.Normal
						
						output_velocity_ang = snap_normal * ( output_velocity_ang:Dot( snap_normal ) )
						
						local proj = output_velocity:Dot( snap_normal )
						--local proj = snap_normal:Dot( output_velocity )
						
						if ( proj > 0 ) then
							output_velocity = output_velocity - ( snap_normal * proj )
						end
					end
				end
			end
			
			local farts = phys_pos - target_position
			
			local off_velocity, off_velocity_ang = e_physics:CalculateVelocityOffset( farts * e_physics:GetMass() * -16, target_position )
			
			local phys_up = phys_ang:Up()
			local phys_ri = phys_ang:Right()
			
			local pp = held_entity:GetPos()
			
			debugoverlay.Line( pp, pp + (phys_up * 16), 0.03, Color(0, 0, 255), true )
			
			debugoverlay.Line( pp, pp + (velocity_ang * 16), 0.03, Color(255, 0, 0), true )
			
			local sas = velocity_ang - phys_up
			sas:Normalize()
			
			-- Okay so yeah this is rotating around the already rotated axis...
			local lerp_angular = LerpVector( FrameTime() * 9000, phys_up, Vector(0, 0, 1) )
			
			local jj, kk = LocalToWorld( sas, Angle(), lerp_angular, Angle() )
			
			-- (2023) Okay totally confirmed for being around the upward axis of the object!!
			e_physics:SetAngleVelocityInstantaneous( jj )
			
			e_physics:SetVelocityInstantaneous( (velocity * -1) + output_velocity )
			
			e_physics:AddVelocity( off_velocity )
			
		end
	end
end

function SWEP:PrimaryAttack()
	local p = self:GetOwner()
	
	local shoot_position = p:GetShootPos()
	local aim_vector = p:GetAimVector()
	
	local tr = util.TraceLine({
		start = shoot_position,
		endpos = shoot_position + (aim_vector * 256),
		filter = p,
		mask = g_mask
	})
	
	local held_entity = self:GetHeldEntity()
	
	local e = tr.Entity
	local holding_entity = IsValid( held_entity )
	local force_position = tr.HitPos
	
	if ( holding_entity ) then
		force_position = held_entity:WorldSpaceCenter()
		
		e = held_entity
		
		detach_held_object( self, p )
	end
	
	if ( IsValid( e ) ) then
		local e_phys = e:GetPhysicsObject()
		
		if ( IsValid( e_phys ) ) then
			-- LAUNCH
			e_phys:EnableMotion( true )
			
			local damage = DamageInfo()
			damage:SetAttacker( p )
			damage:SetInflictor( self )
			damage:SetDamage( 0 )
			damage:SetDamageType( DMG_PHYSGUN )
			
			e:DispatchTraceAttack( damage, tr, aim_vector )
			
			e_phys:ApplyForceOffset( aim_vector * 1200 * e_phys:GetMass(), force_position )
			
			p:VRecoil( -17.00, -0.50 )
			
			self:EmitSound( sfx_launch )
			
			self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
			self:SetNextSecondaryFire( CurTime() + 0.2 )
			self:SetNextSecondaryFire( CurTime() + 0.2 )
		end
		
		return true
	end
	
	self:SetNextSecondaryFire( CurTime() + 0.2 )
	self:SetNextSecondaryFire( CurTime() + 0.2 )
	
	return false
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 0.1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	if ( CLIENT ) then return end
	
	local p = self:GetOwner()
	
	local pred = IsFirstTimePredicted()
	if ( not pred ) then return end
	
	local held_entity = self:GetHeldEntity()
	local holding_entity = IsValid( held_entity )
	
	if ( holding_entity ) then
		detach_held_object( self, p )
		
		return
	end
	
	local startpos = p:GetShootPos()
	
	local tr = util.TraceLine({
		start = startpos,
		endpos = startpos + (p:GetAimVector() * 256),
		filter = p,
		mask = g_mask,
		mins = Vector(-4, -4, -4),
		maxs = Vector(4, 4, 4)
	})
	
	--if ( tr.Hit ) then
	local test_pos = tr.HitPos
	--end
	
	-- 200^2
	local nearest_distance = 40000 + 1
	
	local base_hull = Vector( 1, 1, 1 ) * 200
	local mins = test_pos - base_hull
	local maxs = test_pos + base_hull
	
	local nearest = nil
	
	local list = ents.FindInBox( mins, maxs )
	
	local trace = {
		start = startpos,
		endpos = startpos + (p:GetAimVector() * 256),
		filter = p,
		mask = g_mask
	}
	
	-- check for closest lol
	for k, e in ipairs( list ) do
		if ( e == p ) then continue end
		
		local e_phys = e:GetPhysicsObject()
		
		if ( !IsValid( e_phys ) or e:GetMoveType() ~= MOVETYPE_VPHYSICS ) then
			continue
		end
		
		-- too heavy then fuck off lol
		if ( e_phys:GetMass() > 200 ) then
			continue
		end
		
		local e_pos = e:WorldSpaceCenter()
		
		local los = e_pos - test_pos
		
		local dist = los:LengthSqr()
		
		--los:Normalize()
		
		if (dist < nearest_distance) then
			trace.filter = {p, e}
			trace.start = test_pos
			trace.endpos = e_pos
			
			local tr_los = util.TraceLine(trace)
			
			if ( not tr_los.Hit ) then
				nearest = e
				nearest_distance = dist
			end
		else
			continue
		end
	end
	
	if ( IsValid(nearest) ) then
		local e_phys = nearest:GetPhysicsObject()
		
		e_phys:Wake()
		
		attach_object( self, p, nearest )
	else
		self:EmitSound( sfx_dry )
	end
	
end