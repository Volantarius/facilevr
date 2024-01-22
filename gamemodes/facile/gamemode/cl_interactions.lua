include( "interactions/interactions.lua" )

function GM:ContextMenuEnabled()
	return true
end

function GM:ContextMenuOpen()
	return true
end

-- Overridden to allow shorter properties menu
function properties.GetHovered( eyepos, eyevec )

	local pl = LocalPlayer()
	local filter = pl:GetViewEntity()

	if ( filter == pl ) then
		local veh = pl:GetVehicle()

		if ( veh:IsValid() && ( !veh:IsVehicle() || !veh:GetThirdPersonMode() ) ) then
			-- A dirty hack for prop_vehicle_crane. util.TraceLine returns the vehicle but it hits phys_bone_follower - something that needs looking into
			filter = { filter, veh, unpack( ents.FindByClass( "phys_bone_follower" ) ) }
		end
	end

	local trace = util.TraceLine( {
		start = eyepos,
		endpos = eyepos + eyevec * 75,
		filter = filter
	} )

	-- Hit COLLISION_GROUP_DEBRIS and stuff
	if ( !trace.Hit || !IsValid( trace.Entity ) ) then
		trace = util.TraceLine( {
			start = eyepos,
			endpos = eyepos + eyevec * 75,
			filter = filter,
			mask = MASK_ALL
		} )
	end

	if ( !trace.Hit || !IsValid( trace.Entity ) ) then return end

	return trace.Entity, trace

end

hook.Add( "PopulateInteractMenuBar", "DisplayOptions_MenuBar", function( menubar )

	local m = menubar:AddOrGetMenu( "General" )

	-- Add Facile commands here!

	m:AddCVar( "#menubar.drawing.physgun_beam", "physgun_drawbeams", "1", "0" )
	m:AddCVar( "#menubar.drawing.physgun_halo", "physgun_halo", "1", "0" )
	m:AddCVar( "#menubar.drawing.freeze", "effects_freeze", "1", "0" )
	m:AddCVar( "#menubar.drawing.unfreeze", "effects_unfreeze", "1", "0" )

	m:AddSpacer()

end )