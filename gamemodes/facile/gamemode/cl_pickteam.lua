
--[[---------------------------------------------------------
   Name: gamemode:ShowTeam()
   Desc:
-----------------------------------------------------------]]
function GM:ShowTeam()
	
	if ( VR_MODE ) then
		GAMEMODE:VRShowMapMenu( 2 )
		return
	end
	
	local faDsk = list.Get( "FacileDesktopWindows" )

	local newv = faDsk["FacileSelectTeam"]

	if ( newv ) then
		-- Make the window
		local window = vgui.Create( "DFrame" )

		window:SetBackgroundBlur( true )

		window:SetSize( newv.width, newv.height )
		window:SetTitle( newv.title )
		window:Center()

		newv.init( nil, window )

		window:MakePopup()
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ShowClass()
   Desc:
-----------------------------------------------------------]]
function GM:ShowClasses()

	if ( VR_MODE ) then
		GAMEMODE:VRShowMapMenu( 3 )
		return
	end

	local faDsk = list.Get( "FacileDesktopWindows" )

	local newv = faDsk["FacileSelectClass"]

	if ( newv ) then
		-- Make the window
		local window = vgui.Create( "DFrame" )

		window:SetBackgroundBlur( true )

		window:SetSize( newv.width, newv.height )
		window:SetTitle( newv.title )
		window:Center()

		newv.init( nil, window )

		window:MakePopup()
	end

end

concommand.Add( "fa_showclasses", function() hook.Call( "ShowClasses", GAMEMODE ) end )

net.Receive( "facile_showclasses", function( len, pl )
	timer.Simple( 0.1, function(len) hook.Call( "ShowClasses", GAMEMODE ) end )
end )