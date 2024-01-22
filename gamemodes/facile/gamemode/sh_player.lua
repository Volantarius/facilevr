AddCSLuaFile()

function GM:PlayerNoClip( pl, on )
	if ( !on ) then return true end

	return (( GAMEMODE.PlayerCanNoClip || game.SinglePlayer() || GetConVar( "sv_cheats" ):GetBool() || pl:IsAdmin() ) && ( IsValid(pl) && pl:Alive() ))
end

-- Limited by default
function GM:PhysgunPickup( ply, ent )

	local EntClass = ent:GetClass()

	-- Never pick up players
	if ( EntClass == "player" ) then return false end

	if ( string.find( EntClass, "prop_dynamic" ) ) then return false end
	if ( string.find( EntClass, "prop_door" ) ) then return false end

	-- Don't move physboxes if the mapper logic says no
	if ( EntClass == "func_physbox" && ent:HasSpawnFlags( SF_PHYSBOX_MOTIONDISABLED ) ) then return false  end

	-- If the physics object is frozen by the mapper, don't allow us to move it.
	if ( string.find( EntClass, "prop_" ) && ( ent:HasSpawnFlags( SF_PHYSPROP_MOTIONDISABLED ) || ent:HasSpawnFlags( SF_PHYSPROP_PREVENT_PICKUP ) ) ) then return false end

	-- Allow physboxes, but get rid of all other func_'s (ladder etc)
	if ( EntClass != "func_physbox" && string.find( EntClass, "func_" ) ) then return false end

	return true

end

local util_TraceLine, ents_FindInSphere = util.TraceLine, ents.FindInSphere

local function find_main_use_entity( p, start_position, start_forward )
	
	local closest_distance = 9999999
	--local closest_dot      = 9999999
	local found_entity = nil
	
	-- 8 is good, but test and see if it needs to be less or more
	for k, the_entity in ipairs( ents_FindInSphere( start_position, 8 ) ) do
		
		if ( the_entity == p ) then continue end
		
		if ( the_entity:GetOwner() == p ) then continue end
		
		if ( the_entity:IsNPC() || the_entity:IsPlayer() ) then continue end
		
		local the_entity_movetype = the_entity:GetMoveType()
		
		-- NONE and Not Solid are usually triggers..
		if ( the_entity_movetype < 1 && !the_entity:IsSolid() ) then continue end
		
		local the_entity_pos = the_entity:WorldSpaceCenter()
		
		-- what why reversed...
		local entity_difference = the_entity_pos - start_position
		
		local entity_dot = entity_difference:Dot( start_forward )
		
		if ( entity_dot < 0 ) then continue end
		
		local perpendicular_cast_vector = the_entity_pos - ( ( entity_dot * start_forward ) + start_position )
		
		local distance = perpendicular_cast_vector:LengthSqr()
		
		if ( distance < closest_distance ) then
			found_entity = the_entity
			
			closest_distance = distance
			--closest_dot = entity_dot
		end
		
	end
	
	return found_entity
end

-- Now with VR support!
-- While in VR we should actually not fallback to the normal use... WE want to prevent accidental use, especially if its un seen!
function GM:FindUseEntity( p, e )

	if ( SERVER && p.vr_mode ) then
		
		local vrfire_pos_info = p:GetInfo( "favr_fire_pos" )
		local vrfire_vec_info = p:GetInfo( "favr_fire_vec" )
		
		local rhand = p:GetPos()
		local rhand_vec = p:GetAimVector()
		
		if ( vrfire_pos_info ) then
			rhand = rhand + Vector( vrfire_pos_info )
		end
		
		if ( vrfire_vec_info ) then
			rhand_vec = Vector( vrfire_vec_info )
		end
		
		local found_entity = find_main_use_entity( p, rhand, rhand_vec )
		
		if ( IsValid( found_entity ) ) then
			return found_entity
		else
			return nil
		end
		-- FOR VR WE DO NOT DEFAULT TO THE NORMAL USE!! fuck accidental using

	elseif ( CLIENT && VR_MODE ) then
		
		local found_entity = find_main_use_entity( p, p.mainhand_pos, p.mainhand_vec )
		
		if ( IsValid( found_entity ) ) then
			return found_entity
		else
			return nil
		end

	end
	
	return e
end