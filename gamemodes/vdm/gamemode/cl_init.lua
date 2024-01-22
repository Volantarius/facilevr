include( "shared.lua" )
include( "cl_notify.lua" )
include( "cl_music.lua" )

surface.CreateFont( "VDMHudSelection", {
	font	= "Rajdhani SemiBold",
	size	= 24,
	weight	= 400,
} )

surface.CreateFont( "VDMHudElement", {
	font	= "Rajdhani SemiBold",
	size	= 48,
	weight	= 400,
} )

surface.CreateFont( "VDM_Medium", {
	font	= "Rajdhani SemiBold",
	size	= 18,
	weight	= 400,
} )

include( "cl_hud.lua" )

-- Client-side setup player for VDM
hook.Add( "HUDNeedsUpdate", "VDMUpdateStuff", function( value )
	local pl = LocalPlayer()
	
	if ( not IsValid(pl) ) then return end
	
	if (value == 66) then
		pl:VDMSetupPlayer()
	end
end )