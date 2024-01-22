
local PANEL = {}

AccessorFunc( PANEL, "m_bHangOpen", "HangOpen" )

function PANEL:Init()

	--
	-- This makes it so that when you're hovering over this panel
	-- you can `click` on the world. Your viewmodel will aim etc.
	--
	self:SetWorldClicker( false )-- true

	self.m_bHangOpen = false

	self:Dock( FILL )

end

function PANEL:Open()

	self:SetHangOpen( false )

	if ( self:IsVisible() ) then return end

	CloseDermaMenus()

	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )

	RestoreCursorPosition()

	self:InvalidateLayout( true )

end

function PANEL:Close( bSkipAnim )

	if ( self:GetHangOpen() ) then
		self:SetHangOpen( false )
		return
	end

	RememberCursorPosition()

	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )

	self:SetAlpha( 255 )
	self:SetVisible( false )

end

function PANEL:PerformLayout()
end

function PANEL:StartKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( true )
	self:SetHangOpen( true )

end

function PANEL:EndKeyFocus( pPanel )

	self:SetKeyboardInputEnabled( false )

end

--
-- Note here: EditablePanel is important! Child panels won't be able to get
-- keyboard input if it's a DPanel or a Panel. You need to either have an EditablePanel
-- or a DFrame (which is derived from EditablePanel) as your first panel attached to the system.
--
vgui.Register( "FacileContextMenu", PANEL, "EditablePanel" )

function CreateContextMenu()

	if ( !hook.Run( "ContextMenuEnabled" ) ) then return end

	if ( IsValid( g_ContextMenu ) ) then
		g_ContextMenu:Remove()
		g_ContextMenu = nil
	end

	g_ContextMenu = vgui.Create( "FacileContextMenu" )

	if ( !IsValid( g_ContextMenu ) ) then return end

	g_ContextMenu:SetVisible( false )

	--
	-- We're blocking clicks to the world - but we don't want to
	-- so feed clicks to the proper functions..
	--
	g_ContextMenu.OnMousePressed = function( p, code )
		hook.Run( "GUIMousePressed", code, gui.ScreenToVector( gui.MousePos() ) )
	end
	g_ContextMenu.OnMouseReleased = function( p, code )
		hook.Run( "GUIMouseReleased", code, gui.ScreenToVector( gui.MousePos() ) )
	end

	hook.Run( "ContextMenuCreated", g_ContextMenu )

	local IconLayout = g_ContextMenu:Add( "DIconLayout" )
	IconLayout:SetBorder( 8 )
	IconLayout:SetSpaceX( 8 )
	IconLayout:SetSpaceY( 8 )
	IconLayout:SetLayoutDir( LEFT )
	IconLayout:SetWorldClicker( false )-- true
	IconLayout:SetStretchWidth( true )
	IconLayout:SetStretchHeight( false ) -- No infinite re-layouts
	IconLayout:Dock( LEFT )

	-- This overrides DIconLayout's OnMousePressed (which is inherited from DPanel), but we don't care about that in this case
	IconLayout.OnMousePressed = function( s, ... ) s:GetParent():OnMousePressed( ... ) end

	for k, v in pairs( list.Get( "FacileDesktopWindows" ) ) do
		
		if ( !game.SinglePlayer() && (v.vr || v.singleplayer) && !LocalPlayer():IsAdmin() ) then continue end
		
		local icon = IconLayout:Add( "DButton" )
		icon:SetText( "" )
		icon:SetSize( 80, 82 )
		icon.Paint = function() end

		local image = icon:Add( "DImage" )
		image:SetImage( v.icon )
		image:SetSize( 64, 64 )
		image:Dock( TOP )
		image:DockMargin( 8, 0, 8, 0 )

		local label = icon:Add( "DLabel" )
		label:Dock( BOTTOM )
		label:SetText( v.title )
		label:SetContentAlignment( 5 )
		label:SetTextColor( Color( 255, 255, 255, 255 ) )
		label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )

		icon.DoClick = function()

			--
			-- v might have changed using autorefresh so grab it again
			--
			local newv = list.Get( "FacileDesktopWindows" )[ k ]

			if ( v.onewindow and IsValid( icon.Window ) ) then
				icon.Window:Center()
				return
			end

			-- Make the window
			icon.Window = g_ContextMenu:Add( "DFrame" )
			icon.Window:SetSize( newv.width, newv.height )
			icon.Window:SetTitle( newv.title )
			icon.Window:SetMinWidth( 528 )
			icon.Window:SetMinHeight( 528 )
			icon.Window:Center()

			newv.init( icon, icon.Window )

		end

	end

end

function GM:OnContextMenuOpen()

	-- Let the gamemode decide whether we should open or not..
	if ( !hook.Call( "ContextMenuOpen", self ) ) then return end

	if ( IsValid( g_ContextMenu ) && !g_ContextMenu:IsVisible() ) then
		g_ContextMenu:Open()
		interactmenubar.ParentTo( g_ContextMenu )
	end

	hook.Call( "ContextMenuOpened", self )

end

function GM:OnContextMenuClose()

	if ( IsValid( g_ContextMenu ) ) then g_ContextMenu:Close() end
	hook.Call( "ContextMenuClosed", self )

end
