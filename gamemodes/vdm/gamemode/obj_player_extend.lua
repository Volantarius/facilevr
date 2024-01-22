AddCSLuaFile()

local meta = FindMetaTable( "Player" )
if ( !meta ) then return end

-- CS:S approx player scale and view offsets
-- @Note: This screws up all of the Half Life 2 Ducks..
local Orig_Hull		= {Vector(-16, -16, 0), Vector(16, 16, 67)}
local Orig_HullDuck	= {Vector(-16, -16, 0), Vector(16, 16, 45)}
local Orig_ViewOff	= Vector(0, 0, 64)
local Orig_ViewOffDuck	= Vector(0, 0, 42)

function meta:VDMSetupPlayer()
	
	if ( SERVER ) then
		net.Start("facile_playerstate")
			net.WriteUInt(66, 32)
		net.Send( self )
	end
	
	self:SetHull( Orig_Hull[1], Orig_Hull[2] )
	self:SetHullDuck( Orig_HullDuck[1], Orig_HullDuck[2] )
	self:SetViewOffset( Orig_ViewOff )
	self:SetViewOffsetDucked( Orig_ViewOffDuck )
end

-- For prop hunt
--[[function meta:SetPropHideModel( ent )
	local phys = ent:GetPhysicsObject()
	local newModel = ent:GetModel()
	
	if ( phys:IsValid() && IsValid(self.ph_prop) && self:Alive() && self.ph_prop:GetModel() ~= newModel ) then
		-- Calculate new health values based on prop
		local ent_health = math.Clamp( phys:GetVolume() / 250, 1, 200 )
		local new_health = math.Clamp( (self.ph_prop.health / self.ph_prop.maxhealth) * ent_health, 1, 200 )
		
		self.ph_prop.health    = new_health
		self.ph_prop.maxhealth = ent_health
		
		self.ph_prop:SetModel( newModel )
		self.ph_prop:SetSkin( ent:GetSkin() )
		self.ph_prop:SetSolid( SOLID_BSP )
		
		local hull_xy_max = math.Round(math.Max(ent:OBBMaxs().x, ent:OBBMaxs().y))
		local hull_xy_min = hull_xy_max * -1
		local hull_z = math.Round(ent:OBBMaxs().z)
		
		self:SetHull(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
		self:SetHullDuck(Vector(hull_xy_min, hull_xy_min, 0), Vector(hull_xy_max, hull_xy_max, hull_z))
		
		self:SetHealth(new_health)
	end
end]]