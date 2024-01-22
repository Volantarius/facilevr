AddCSLuaFile()

if SERVER then return end

local function useless_flex( name )
	if ( name == "eyes_rightleft" ) then return true end
	if ( name == "eyes_updown" ) then return true end
end

local main_prop = nil

-- sit_zen <-- best sequence for starting lol

local animation_name = "idle_all_01"

local function play_preview_animation()
	local iSeq = main_prop:LookupSequence( animation_name )
	
	if ( iSeq > 0 ) then main_prop:ResetSequence( iSeq ) end
end

local function create_clientside_preview( modelname, pos, ang )
	util.PrecacheModel( modelname )
	
	if ( IsValid( main_prop ) ) then
		main_prop:Remove()
	end
	
	main_prop = ents.CreateClientProp()
	
	main_prop:SetPos( pos )
	main_prop:SetModel( modelname )
	main_prop:SetAngles( ang )
	main_prop:SetIK( false )
	
	main_prop:Spawn()
	
	play_preview_animation()
end

local function start_self_inspection()
	local pl = LocalPlayer()
	
	-- Make a way of telling the server we want to inspect our thing... And limit the shit out of it
	-- A Concommand is a good way
	
	local pl_ang = pl:GetAngles()
	
	create_clientside_preview( "models/cyanblue/kof/diabla/diabla.mdl", pl:GetPos(), Angle( 0, pl_ang.y, 0 ) )
end

local function end_self_inspection()
	local pl = LocalPlayer()
	
	if ( IsValid( main_prop ) ) then
		main_prop:Remove()
		main_prop = nil
	end
end

local function UpdatePreviewModel( new_modelname )
	local pl = LocalPlayer()
	local pl_ang = pl:GetAngles()
	
	local old_pos = pl:GetPos()
	local old_ang = pl:GetAngles()
	
	old_ang = Angle( 0, old_ang.y, 0 )
	
	-- Have to rebuild, game cleans up our model
	if ( IsValid(main_prop) ) then
		old_pos = main_prop:GetPos()
		old_ang = main_prop:GetAngles()
		
		main_prop:Remove()
		main_prop = nil
	end
	
	create_clientside_preview( new_modelname, old_pos, old_ang )
	
	--RebuildBodygroupTab()
end

-- Hopfully we replace a good chunk of this and setup json templates
-- And network all the flexs, materials, etc.
local function UpdatePlayerConvars()
	--local modelname = player_manager.TranslatePlayerModel( model )
	--plycol:SetVector( Vector( GetConVarString( "cl_facile_playercolor" ) ) )
	--wepcol:SetVector( Vector( GetConVarString( "cl_facile_weaponcolor" ) ) )
	-- BODY GROUPS
end

local selectedModelIcon = nil
local oldSelectedPaintOver = nil

local function editor_shutdown()
	selectedModelIcon = nil
	oldSelectedPaintOver = nil
	
	end_self_inspection()
end

local function rebuild_flexs( pnl )
	pnl:Clear()
	
	local flexs_count = main_prop:GetFlexNum()
	
	if ( flexs_count <= 0 ) then return end
	
	for i = 0, flexs_count - 1 do
		
		local flex_name = main_prop:GetFlexName( i )
		
		-- Add skip for useless flexs
		
		local flex_ctrl = vgui.Create( "DNumSlider" )
		flex_ctrl:Dock( TOP )
		flex_ctrl:SetText( flex_name )
		flex_ctrl:SetDark( true )
		flex_ctrl:SetTall( 25 )-- 50
		flex_ctrl:SetDecimals( 3 )
		flex_ctrl:SetMinMax( main_prop:GetFlexBounds( i ) )
		flex_ctrl:SetValue( 0 )
		flex_ctrl.type = "flex"
		flex_ctrl.id = i
		
		-- Maybe make a single function that goes over the panel's settings
		flex_ctrl.OnValueChanged = function( pnl, value )
			main_prop:SetFlexWeight( i, value )
		end
		
		pnl:AddItem( flex_ctrl )
		
	end
end

-- Rebuild all the shiz
local function rebuild_preview( sheet_flexs )
	rebuild_flexs( sheet_flexs )
	
end

-- Run console vars here
--[[
>>>>>>> FRETTA <<<<<<<<

local icon = vgui.Create( "SpawnIcon" )

icon.DoClick = function()
	surface.PlaySound( "ui/buttonclickrelease.wav" )
	RunConsoleCommand( "cl_vretta_playermodel", name )
end
]]
--[[function PanelSelect:OnActivePanelChanged( old, new )
	
	--if ( old != new ) then -- Only reset if we changed the model
	--	RunConsoleCommand( "cl_facile_playerbodygroups", "0" )
	--	RunConsoleCommand( "cl_facile_playerskin", "0" )
	--end
	
	timer.Simple( 0.1, function() UpdatePreviewModel() end )
	
end]]

--[[====	====	====	====	====]]
--[[	  GUI   						]]
--[[====	====	====	====	====]]

local border = 0
local border_w = 8
local matHover = Material( "gui/ps_hover.png", "nocull" )
local boxHover = GWEN.CreateTextureBorder( border, border, 64 - border * 2, 64 - border * 2, border_w, border_w, border_w, border_w, matHover )

-- Our custom draw selected
local function DIconDrawSelected( pnl )
	local w, h = pnl:GetSize()
	
	boxHover( 0, 0, w, h, Color( 255, 210 + math.sin( RealTime() * 10 ) * 40, 0 ) )
end

local function controls_setup_flexs( window, sheet )
	local controls = window:Add( "DPanel" )
	controls:DockPadding( 8, 8, 8, 8 )
	
	local controls_list = controls:Add( "DPanelList" )
	controls_list:EnableVerticalScrollbar( true )
	controls_list:Dock( FILL )
	
	return sheet:AddSheet( "Flexs", controls, "icon16/shape_group.png" ), controls_list
end

local function controls_setup_transformation( window, sheet )
	local controls = window:Add( "DPanel" )
	controls:DockPadding( 8, 8, 8, 8 )
	
	local controls_list = controls:Add( "DPanelList" )
	controls_list:EnableVerticalScrollbar( true )
	controls_list:Dock( FILL )
	
	local prop_angles = main_prop:GetAngles()
	
	local yaw = vgui.Create( "DNumSlider" )
	yaw:Dock( TOP )
	yaw:SetText( "Yaw" )
	yaw:SetDark( true )
	yaw:SetTall( 50 )
	yaw:SetDecimals( 3 )
	yaw:SetMinMax( 0, 360 )
	yaw:SetValue( prop_angles.y )
	yaw.type = "yaw"
	
	yaw.OnValueChanged = function( pnl, value )
		main_prop:SetAngles( Angle( 0, value, 0 ) )
	end
	
	controls_list:AddItem( yaw )
	
	--mdl.Entity:SetSkin( GetConVarNumber( "cl_facile_playerskin" ) )
	
	local eye_target = vgui.Create( "DButton" )
	eye_target:Dock( TOP )
	eye_target:SetText( "Look at player" )
	eye_target:SetDark( true )
	eye_target:SetTall( 50 )
	
	eye_target.DoClick = function()
		print( "uuh doesn't work" )
		
		local eyeattachment = main_prop:LookupAttachment( "eyes" )
		
		if ( eyeattachment == 0 ) then return end
		
		local attachment = main_prop:GetAttachment( eyeattachment )
		
		if ( !attachment ) then return end
		
		local pl = LocalPlayer()
		local pos = pl:EyePos()
		
		local LocalPos = WorldToLocal( pos, angle_zero, attachment.Pos, attachment.Ang )
		
		main_prop:SetEyeTarget( LocalPos )
	end
	
	controls_list:AddItem( eye_target )
	
	return sheet:AddSheet( "Transform", controls, "icon16/arrow_rotate_anticlockwise.png" ), controls_list
end

--layers.png
--vector.png

local function init_editor( icon, window )
	
	start_self_inspection()
	
	local client_width = ScrW()
	local window_width = math.min( client_width - 16, window:GetWide() )
	
	window:SetTitle( "Character Editor" )
	window:SetSize( window_width, math.max( ScrH() - 64, window:GetTall() ) )
	window:SetSizable( true )
	window:SetMinWidth( window:GetWide() )
	window:SetMinHeight( window:GetTall() )
	window:Center()
	
	window:SetX( client_width - window_width )
	
	window.OnClose = editor_shutdown
	window.OnRemove = editor_shutdown
	
	local sheet = window:Add( "DPropertySheet" )
	sheet:Dock( FILL )
	--sheet:SetSize( 430, 0 )
	
	-- Model Select
	local modelListPnl = window:Add( "DPanel" )
	modelListPnl:DockPadding( 8, 8, 8, 8 )
	
	local SearchBar = modelListPnl:Add( "DTextEntry" )
	SearchBar:Dock( TOP )
	SearchBar:DockMargin( 0, 0, 0, 8 )
	SearchBar:SetUpdateOnType( true )
	SearchBar:SetPlaceholderText( "#spawnmenu.quick_filter" )
	
	local PanelSelectScroll = modelListPnl:Add( "DScrollPanel" )
	PanelSelectScroll:Dock( FILL )
	
	local PanelSelect = PanelSelectScroll:Add( "DIconLayout" )--DPanelSelect
	PanelSelect:Dock( FILL )
	PanelSelect:SetSpaceY( 3 )
	PanelSelect:SetSpaceX( 3 )
	
	sheet:AddSheet( "Model", modelListPnl, "icon16/user.png" )
	
	local sheet_transform = controls_setup_transformation( window, sheet )
	
	local sheet_flexs, list_flexs = controls_setup_flexs( window, sheet )
	
	-- This is here to get a reference of the sheets..
	local function rebuild_attributes( pnl )
		UpdatePreviewModel( pnl:GetModelName() )-- Update our model with the new one
		
		rebuild_preview( list_flexs )
	end
	
	-- Continue building the player model panel
	--
	for name, model in SortedPairs( player_manager.AllValidModels() ) do
		
		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name
		icon.model_path = model
		icon.OpenMenu = function( button )
			local menu = DermaMenu()
			menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( model ) end ):SetIcon( "icon16/page_copy.png" )
			menu:Open()
		end
		
		icon.DoClick = function( pnl )
			rebuild_attributes( pnl )
			
			if ( selectedModelIcon ) then
				selectedModelIcon.PaintOver = oldSelectedPaintOver
				selectedModelIcon = nil
			end
			
			selectedModelIcon = pnl
			
			if ( selectedModelIcon ) then
				oldSelectedPaintOver = selectedModelIcon.PaintOver
				selectedModelIcon.PaintOver = DIconDrawSelected
			end
		end
		
		--PanelSelect:AddItem( icon, { cl_facile_playermodel = name } )
		
		-- Uhh gotta auto select our player model?? Still unsure
		PanelSelect:Add( icon )
		
	end
	
	SearchBar.OnValueChange = function( s, str )
		for id, pnl in pairs( PanelSelect:GetChildren() ) do
			if ( !pnl.playermodel:find( str, 1, true ) && !pnl.model_path:find( str, 1, true ) ) then
				pnl:SetVisible( false )
			else
				pnl:SetVisible( true )
			end
		end
		PanelSelect:Layout()
	end
	
end

list.Set( "FacileDesktopWindows", "PlayerEditorVol", {

	title		= "Character Editor",
	icon		= "icon64/playermodel.png",
	width		= 860,--960
	height		= 700,
	onewindow	= true,
	singleplayer = true,
	init		= init_editor
} )