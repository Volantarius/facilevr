SWEP.Base = "weapon_vdm_base"

SWEP.PrintName 	= "Gravity Gun"
SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/v_superphyscannon.mdl" )
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

if CLIENT then
	killicon.Add( "weapon_vdmvr_grabbity", "killicons/gravitygun", Color(255, 255, 255, 255) )
	
	SWEP.WepSelectIconSquare = false
	
	SWEP.WepSelectIcon = surface.GetTextureID( "killicons/gravitygun" )
	
	-- 0 phys, 1 pistol, 2 rifles, 3 crossbow/shotty, 4 explosive, 5 toolgun
	SWEP.Slot = 0
	SWEP.SlotPos = 5
end

-- Going have to be networked I do believe
local bNWActive = false
local held_entity = nil

local held_old_mass = 0
local held_old_lin_damping = 0
local held_old_ang_damping = 0

function SWEP:SetupDataTables()
end

local function attach_object( wep, p, e )
	if ( bNWActive ) then return false end
	
	-- Can pickup check
	local e_physics = e:GetPhysicsObject()
	
	if ( !IsValid( e_physics ) ) then return end
	
	if ( !IsValid( p ) ) then return end
	
	--wep:StartMotionController()
	
	--wep:AddToMotionController( e_physics )
	
	held_old_lin_damping, held_old_ang_damping = e_physics:GetDamping()
	
	e_physics:SetDamping( held_old_lin_damping, 10 )
	
	e_physics:EnableDrag( false )
	
	bNWActive = true
	held_entity = e
end

local function detach_held_object( wep, p )
	if ( IsValid(held_entity) ) then
		local e_physics = held_entity:GetPhysicsObject()
		
		if ( IsValid( e_physics ) ) then
			wep:RemoveFromMotionController( e_physics )
			
			e_physics:SetDamping( held_old_lin_damping, held_old_ang_damping )
			
			e_physics:EnableDrag( true )
			
			e_physics:Wake()
		end
	end
	
	--wep:StopMotionController()
	
	bNWActive = false
	held_entity = nil
	
	if ( !IsValid( p ) ) then return end
end

local g_mask = bit.bor( MASK_SHOT, CONTENTS_GRATE )

function SWEP:OnDrop()
	detach_held_object( self, self.Owner )
end

function SWEP:Holster()
	detach_held_object( self, self.Owner )
	return true
end

function SWEP:OnRemove()
	detach_held_object( self, self.Owner )
end

function SWEP:OwnerChanged()
	detach_held_object( self, self.Owner )
end

function SWEP:Initialize()
	self:SetHoldType( "physgun" )
end

function SWEP:Think()
	local p = self.Owner
	
	if ( bNWActive and not IsValid(held_entity) ) then
		detach_held_object( self, p )
	end
	
	if ( bNWActive and IsValid(held_entity) ) then
		local shoot_position = p:GetShootPos()
		local aim_vector = p:GetAimVector()
		
		local radius = held_entity:BoundingRadius()
		
		local min_radius = ((radius * 1.5) + 16)
		
		local tr = util.TraceLine({
			start = shoot_position,
			endpos = shoot_position + (aim_vector * (128+radius)),
			filter = {p, held_entity},
			mask = MASK_SOLID_BRUSHONLY
		})
		
		local target_position = shoot_position + (aim_vector * (128+radius))
		
		if ( tr.Hit ) then
			target_position = tr.HitPos
		end
		
		if ( tr.Fraction < (min_radius / (128+radius)) ) then
			target_position = shoot_position + (aim_vector * min_radius)
		end
		
		local real_offset = held_entity:WorldSpaceCenter() - held_entity:GetPos()
		
		target_position = target_position - real_offset - (aim_vector * radius)
		
		local e_physics = held_entity:GetPhysicsObject()
		
		if ( IsValid(e_physics) ) then
			e_physics:Wake()
			
			local phys_pos = e_physics:GetPos()
			local phys_ang = e_physics:GetAngles()
			
			local lawl_ang = e_physics:AlignAngles( phys_ang, aim_vector:Angle() )
			
			local velocity_ang = e_physics:GetAngleVelocity()
			local velocity = e_physics:GetVelocity()
			
			--local output_velocity_ang = velocity_ang
			local output_velocity = velocity
			
			local snapshot = e_physics:GetFrictionSnapshot()
			
			if ( snapshot and #snapshot > 0 ) then
				
				for k,dat in ipairs( snapshot ) do
					if ( IsValid(dat.Other) and dat.Other:IsMoveable() ) then
						local snap_normal = dat.Normal
						
						-- I think lol
						--output_velocity_ang = snap_normal * ( output_velocity_ang:Dot( snap_normal ) )
						
						local proj = output_velocity:Dot( snap_normal )
						--local proj = snap_normal:Dot( output_velocity )
						
						if ( proj > 0 ) then
							output_velocity = output_velocity - (snap_normal * proj)
						end
					end
				end
			end
			
			local farts = phys_pos - target_position
			
			local off_velocity, off_velocity_ang = e_physics:CalculateVelocityOffset( farts * e_physics:GetMass() * -16, target_position )
			
			--e_physics:SetAngles( lawl_ang )
			--e_physics:SetPos( target_position, false )
			
			--e_physics:SetAngleVelocityInstantaneous( (output_velocity_ang * -1) + output_velocity_ang )
			e_physics:SetVelocityInstantaneous( (velocity * -1) + output_velocity )
			
			--e_physics:AddAngleVelocity( output_velocity_ang )
			e_physics:AddVelocity( off_velocity )
			
		end
	end
end

function SWEP:PrimaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 0.1 )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	if (CLIENT) then return end
	
	local p = self.Owner
	
	local pred = IsFirstTimePredicted()
	if ( not pred ) then return end
	
	if ( bNWActive ) then
		detach_held_object( self, p )
		
		self:EmitSound( sfx_drop )
		
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
		
		self:EmitSound( sfx_pickup )
	else
		self:EmitSound( sfx_dry )
	end
	
end