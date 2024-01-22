AddCSLuaFile()

if SERVER then return end

list.Set( "FacileDesktopWindows", "VRSettings", {

	title		= "Virtual Reality",
	icon		= "icon64/vr.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )
		
		window:SetSkin( "VRDefault" )

		window:SetTitle( "VR Settings" )
		window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
		window:SetSizable( true )
		window:SetMinWidth( window:GetWide() )
		window:SetMinHeight( window:GetTall() )
		window:Center()
		
		local bg = window:Add( "DPanel" )
		bg:Dock( FILL )
		bg:DockPadding( 16, 8, 16, 8 )
		
		local settingspanel = bg:Add( "DPanelList" )
		settingspanel:EnableVerticalScrollbar( true )
		settingspanel:Dock( FILL )
		
		-- Add all VR settings here
		local button_enable = settingspanel:Add( "DButton" )
		button_enable:Dock( TOP )
		button_enable:SetText( "Enable" )
		button_enable.DoClick = function()
			RunConsoleCommand( "vr_enable" )
		end
		
		local button_disable = settingspanel:Add( "DButton" )
		button_disable:Dock( TOP )
		button_disable:SetText( "Disable" )
		button_disable.DoClick = function()
			RunConsoleCommand( "vr_disable" )
		end
		
	end
})

local bsize = 158
local bsizeh = 79

local convar_gravity = GetConVar( "sv_gravity" )
local convar_cooprespawn = GetConVar( "sv_vdm_coop_respawn" )

list.Set( "FacileDesktopWindows", "testvr", {

	title		= "VR Testing",
	icon		= "icon64/facile.png",
	width		= 528,
	height		= 528,
	onewindow	= true,
	vr          = true,
	init		= function( icon, window )
		
		window:SetSkin( "VRDefault" )-- This changes all the panels below
		
		local sheet = window:Add( "DPropertySheet" )
		sheet:Dock( FILL )
		
		local panel_general = window:Add( "DPanel" )
		panel_general:DockPadding( 8, 8, 8, 8 )
		
		local panel_general_icons = panel_general:Add( "DIconLayout" )
		panel_general_icons:Dock( FILL )
		panel_general_icons:SetSpaceY( 3 )
		panel_general_icons:SetSpaceX( 3 )
		
		-- Add all VR settings here
		local button_maps = panel_general_icons:Add( "DButton" )
		button_maps:SetText( "Maps" )
		button_maps.DoClick = function() GAMEMODE:VRShowMapMenu( 1 ) end
		button_maps:SetFont( "DermaVRDefault" )
		button_maps:SetSize( bsize, bsize )
		
		local button_re = panel_general_icons:Add( "DButton" )
		button_re:SetText( "Respawn" )
		button_re.DoClick = function() RunConsoleCommand( "kill" ) end
		button_re:SetFont( "DermaVRDefault" )
		button_re:SetSize( bsize, bsize )
		
		--[[local button_seating = panel_general_icons:Add( "DButton" )
		button_seating:SetText( "Standing" )
		button_seating.DoClick = function()  end
		button_seating:SetFont( "DermaVRDefault" )
		button_seating:SetSize( bsize, bsize )]]
		
		local button_noclip = panel_general_icons:Add( "DButton" )
		button_noclip:SetText( "Noclip" )
		button_noclip.DoClick = function() RunConsoleCommand("noclip") end
		button_noclip:SetFont( "DermaVRDefault" )
		button_noclip:SetSize( bsize, bsize )
		
		sheet:AddSheet( "Primary", panel_general, "icon16/cog.png", false, false )
		
		--//////////
		local panel_settings_base = window:Add( "DPanel" )
		panel_settings_base:Dock( FILL )
		panel_settings_base:DockPadding( 8, 8, 8, 8 )
		panel_settings_base:SetSkin( "VRDefault" )
		
		local panel_settings = panel_settings_base:Add( "DPanelList" )
		panel_settings:EnableVerticalScrollbar( true )
		panel_settings:Dock( FILL )
		panel_settings:DockPadding( 8, 8, 8, 8 )
		
		local b_laser = vgui.Create( "DCheckBoxLabel" )
		b_laser:SetConVar( "cl_vrlaser" )
		b_laser:Dock( TOP )
		b_laser:SetText( "Weapon Laser" )
		b_laser:SetFont( "DermaVRDefault" )
		b_laser.Button:SetSize( 32, 32 )
		b_laser:SetSkin( "VRDefault" )
		panel_settings:AddItem( b_laser )
		
		local b_autobhop = vgui.Create( "DCheckBoxLabel" )
		b_autobhop:SetConVar( "cl_bhopauto" )
		b_autobhop:Dock( TOP )
		b_autobhop:SetText( "Auto Bunny Hop" )
		b_autobhop:SetFont( "DermaVRDefault" )
		b_autobhop.Button:SetSize( 32, 32 )
		b_autobhop:SetSkin( "VRDefault" )
		panel_settings:AddItem( b_autobhop )
		
		local b_bhoptrain = vgui.Create( "DCheckBoxLabel" )
		b_bhoptrain:SetConVar( "cl_bhoptraining" )
		b_bhoptrain:Dock( TOP )
		b_bhoptrain:SetText( "Bunny Hop Training" )
		b_bhoptrain:SetFont( "DermaVRDefault" )
		b_bhoptrain.Button:SetSize( 32, 32 )
		b_bhoptrain:SetSkin( "VRDefault" )
		panel_settings:AddItem( b_bhoptrain )
		
		local b_bhoptrainvr = vgui.Create( "DCheckBoxLabel" )
		b_bhoptrainvr:SetConVar( "cl_bhopvr" )
		b_bhoptrainvr:Dock( TOP )
		b_bhoptrainvr:SetText( "Bunny Hop VR Training" )
		b_bhoptrainvr:SetFont( "DermaVRDefault" )
		b_bhoptrainvr.Button:SetSize( 32, 32 )
		b_bhoptrainvr:SetSkin( "VRDefault" )
		panel_settings:AddItem( b_bhoptrainvr )
		
		sheet:AddSheet( "Settings", panel_settings_base, "icon16/cog.png", false, false )
		
		-- // ADMIN
		local panel_admin_base = window:Add( "DPanel" )
		panel_admin_base:Dock( FILL )
		panel_admin_base:DockPadding( 8, 8, 8, 8 )
		
		local panel_admin_settings = panel_admin_base:Add( "DPanelList" )
		panel_admin_settings:EnableVerticalScrollbar( true )
		panel_admin_settings:Dock( FILL )
		panel_admin_settings:DockPadding( 8, 8, 8, 8 )
		
		convar_cooprespawn = GetConVar( "sv_vdm_coop_respawn" )
		
		local admin_gravity = vgui.Create( "DNumSlider" )
		admin_gravity:Dock( TOP )
		admin_gravity:SetText( "Gravity" )
		admin_gravity:SetTall( 50 )
		admin_gravity:SetDecimals( 0 )
		admin_gravity:SetMinMax( 0, 800 )
		admin_gravity:SetValue( convar_gravity:GetInt() )
		admin_gravity.TextArea:SetFont( "DermaVRDefault" )
		admin_gravity.Label:SetFont( "DermaVRDefault" )
		admin_gravity.OnValueChanged = function(pnl, v)
			RunConsoleCommand( "fa_gravity", math.Round(v) )
		end
		
		panel_admin_settings:AddItem( admin_gravity )
		
		if ( convar_cooprespawn ~= nil ) then
			local admin_coop = vgui.Create( "DNumSlider" )
			admin_coop:Dock( TOP )
			admin_coop:SetText( "Coop Respawn" )
			admin_coop:SetTall( 50 )
			admin_coop:SetDecimals( 0 )
			admin_coop:SetMinMax( 0, 1 )
			--admin_coop:SetConVar( "vdm_coop_respawn" )
			admin_coop:SetValue( convar_cooprespawn:GetInt() )
			admin_coop.TextArea:SetFont( "DermaVRDefault" )
			admin_coop.Label:SetFont( "DermaVRDefault" )
			admin_coop.OnValueChanged = function(pnl, v)
				RunConsoleCommand( "vdm_coop_respawn", Format("%d", v) )
			end
			
			panel_admin_settings:AddItem( admin_coop )
		end
		
		sheet:AddSheet( "Admin", panel_admin_base, "icon16/cog.png", false, false )
		
		-- Modules!
		local panel_modules_selection = window:Add( "DPanel" )
		panel_modules_selection:DockPadding( 8, 8, 8, 8 )
		
		local panel_modules_icons = panel_modules_selection:Add( "DIconLayout" )
		panel_modules_icons:Dock( FILL )
		panel_modules_icons:SetSpaceY( 3 )
		panel_modules_icons:SetSpaceX( 3 )
		
		local b_module = panel_modules_icons:Add( "DButton" )
		b_module:SetText( "Leg Day" )
		b_module.DoClick = function()
			include( "vr/vr_module_legday.lua" )
			
			GAMEMODE:VR_InitModule()
		end
		b_module:SetFont( "DermaVRDefault" )
		b_module:SetSize( bsize, bsize )
		
		-- SMAK
		local b_smoke = panel_modules_icons:Add( "DButton" )
		b_smoke:SetText( "Smoke" )
		b_smoke.DoClick = function()
			include( "vr/vr_module_smoke.lua" )
			
			GAMEMODE:VR_InitModule()
		end
		b_smoke:SetFont( "DermaVRDefault" )
		b_smoke:SetSize( bsize, bsize )
		
		sheet:AddSheet( "Modules", panel_modules_selection, "icon16/bricks.png", false, false )
		
		local panel_modules = window:Add( "DPanel" )
		panel_modules:DockPadding( 8, 8, 8, 8 )
		
		local panel_module_settings = sheet:AddSheet( "Mod. Settings", panel_modules, "icon16/brick.png", false, false )
		
		GAMEMODE:VR_SetupPanel( panel_modules )
		
		-- VDM Gamemodes
		if ( g_VdmGameTypes ) then
			local panel_gm_selection = window:Add( "DPanel" )
			panel_gm_selection:DockPadding( 8, 8, 8, 8 )
			
			local panel_gm_icons = panel_gm_selection:Add( "DIconLayout" )
			panel_gm_icons:Dock( FILL )
			panel_gm_icons:SetSpaceY( 3 )
			panel_gm_icons:SetSpaceX( 3 )
			
			for gm_name,gm_tbl in pairs( g_VdmGameTypes ) do
				
				local button = panel_gm_icons:Add( "DButton" )
				button:SetText( gm_tbl.PrintName )
				button.DoClick = function()
					print( gm_name )
					RunConsoleCommand( "vdm_changegametype", gm_name )
				end
				button:SetFont( "DermaVRDefault" )
				button:SetSize( bsize, bsize * 0.5 )
				
			end
			
			sheet:AddSheet( "Gamemodes", panel_gm_selection, "icon16/cd.png", false, false )
		end
		
	end
})

local ignore_patterns = {
	"^background",
	"^devtest",
	"^ep1_background",
	"^ep2_background",
	"styleguide"
}

local ignore_prefex = {
	[ "sdk_" ] = true,
	[ "test_" ] = true,
	[ "vst_" ] = true
}

local ignore_maps = {
	[ "c4a1y" ] = true,
	[ "credits" ] = true,
	[ "d2_coast_02" ] = true,
	[ "d3_c17_02_camera" ] = true,
	[ "ep1_citadel_00_demo" ] = true,
	[ "c5m1_waterfront_sndscape" ] = true,
	[ "intro" ] = true,
	[ "test" ] = true,
	[ "itemtest" ] = true
}

local map_categories = {
	["ab"] = {
		printname = "A B",
		list = {
			[1] = "a",
			[2] = "b"
		}
	},
	["c"] = {
		printname = "C",
		list = {
			[1] = "c"
		}
	},
	["d"] = {
		printname = "D",
		list = {
			[1] = "d"
		}
	},
	["ef"] = {
		printname = "E F",
		list = {
			[1] = "e",
			[2] = "f"
		}
	},
	["ghi"] = {
		printname = "G H I",
		list = {
			[1] = "g",
			[2] = "h",
			[3] = "i"
		}
	},
	["jkl"] = {
		printname = "J K L",
		list = {
			[1] = "j",
			[2] = "k",
			[3] = "l"
		}
	},
	["mno"] = {
		printname = "M N O",
		list = {
			[1] = "m",
			[2] = "n",
			[3] = "o"
		}
	},
	["pqr"] = {
		printname = "P Q R",
		list = {
			[1] = "p",
			[2] = "q",
			[3] = "r"
		}
	},
	["stu"] = {
		printname = "S T U",
		list = {
			[1] = "s",
			[2] = "t",
			[3] = "u"
		}
	},
	["vwx"] = {
		printname = "V W X",
		list = {
			[1] = "v",
			[2] = "w",
			[3] = "x"
		}
	},
	["yz"] = {
		printname = "Y Z",
		list = {
			[1] = "y",
			[2] = "z"
		}
	},
	["other"]= {
		printname = "Other",
		list = {
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "_"
		}
	}
}

local map_selected = ""
local map_maxplayers = 1

local function get_map_list( search_table, exclude )
	local finalMaps = {}
	
	if ( !search_table && !exclude ) then
		return finalMaps
	end
	
	local gameMaps = file.Find( "maps/*.bsp", "GAME" )
	
	for id, mapFile in ipairs( gameMaps ) do
		local mapFileLower = string.lower( mapFile )
		local name = string.gsub( mapFileLower, "%.bsp$", "" )
		--local prefix = string.match( name, "^(.-_)" )
		local prefix = string.match( name, "^(.)" )
		
		local Ignore = ignore_maps[ name ] || ignore_prefex[ prefix ]
		
		if ( Ignore ) then continue end
		
		for _, ignore in ipairs( ignore_patterns ) do
			if ( string.find( name, ignore ) ) then
				Ignore = true
				break
			end
		end
		
		if ( Ignore ) then continue end
		
		Ignore = true
		
		if ( exclude ) then
			
			for key, prefix_string in ipairs( search_table ) do
				if ( prefix_string == name || prefix_string == prefix ) then
					Ignore = false
					break
				end
			end
			
			-- Other are maps without prefix, if it has a prefix freaking sort it lol
			if ( !prefix ) then
				Ignore = false
			end
			
		else
			for key, prefix_string in ipairs( search_table ) do
				if ( prefix_string == name || prefix_string == prefix ) then
					Ignore = false
					break
				end
			end
		end
		
		if ( Ignore ) then continue end
		
		table.insert( finalMaps, name )
	end
	
	return finalMaps
end

local function rebuild_maps( panel_scroll, string_category_name, goto_mapselect_function )
	panel_scroll:Clear()
	
	local new_panel = panel_scroll:Add( "DIconLayout" )
	new_panel:Dock( FILL )
	new_panel:SetSpaceY( 3 )
	new_panel:SetSpaceX( 3 )
	
	local map_table = map_categories[ string_category_name ]
	
	local exclude_others = false
	
	if ( string_category_name == "other" ) then
		exclude_others = true
	end
	
	if ( map_table || exclude_others ) then
		map_list = get_map_list( map_table.list, exclude_others )
		
		if ( map_list && #map_list > 0 ) then
			
			for k, map_entry in ipairs( map_list ) do
				
				local image = "maps/thumb/noicon.png"
				
				local map_image = "maps/thumb/" .. map_entry .. ".png"
				
				if ( file.Exists( map_image, "GAME" ) ) then
					image = map_image
				end
				
				local button_map = new_panel:Add( "FacileMapButton" )
				button_map:SetText( map_entry )
				button_map.DoClick = function()
					goto_mapselect_function( map_entry )
				end
				button_map:SetFont( "DermaVRMedium" )
				button_map:SetSize( bsize, bsize )
				button_map:SetImage( image )
				
			end
			
			new_panel:Layout()
		end
	end
	
	panel_scroll:AddItem( new_panel )
	panel_scroll:Rebuild()
end

local function build_mapselected( map_panel, map_name )
	-- Setup variable for actually going to the map
	map_selected = map_name
	
	map_panel:Clear()
	
	local themap_image = map_panel:Add( "DImage" )
	
	local image = "maps/thumb/noicon.png"
	
	local map_image = "maps/thumb/" .. map_name .. ".png"
	
	if ( file.Exists( map_image, "GAME" ) ) then
		image = map_image
	end
	
	themap_image:SetImage( image )
	themap_image:SetSize( 128, 128 )
	
	local themap_label = map_panel:Add( "DLabel" )
	themap_label:SetFont( "DermaVRDefault" )
	themap_label:SetText( map_name )
	themap_label:SizeToContents()
	themap_label:Dock( TOP )
	themap_label:DockMargin( 128 + 16, 64 - (themap_label:GetTall() * 0.5), 0, 0 )
	
	--sv_lan
	--p2p_enabled
	--p2p_friendsonly
	--maxplayers num
	
	--[[local vr_option_one = map_panel:Add( "DCheckBoxLabel" )
	vr_option_one:SetConVar( "sv_lan" )
	vr_option_one:Dock( TOP )
	vr_option_one:SetText( "Singleplayer" )
	vr_option_one:SetFont( "DermaVRDefault" )
	vr_option_one.Button:SetSize( 32, 32 )
	local temp_x, temp_y = vr_option_one:GetPos()
	vr_option_one:DockMargin( 128 + 16, (64 - temp_y), 0, 0 )
	
	local vr_option_two = map_panel:Add( "DCheckBoxLabel" )
	vr_option_two:SetConVar( "p2p_enabled" )
	vr_option_two:Dock( TOP )
	vr_option_two:SetText( "Allow anyone to join" )
	vr_option_two:SetFont( "DermaVRDefault" )
	vr_option_two.Button:SetSize( 32, 32 )
	vr_option_two:DockMargin( 128 + 16, 0, 0, 0 )
	
	local vr_option_three = map_panel:Add( "DCheckBoxLabel" )
	vr_option_three:SetConVar( "p2p_friendsonly" )
	vr_option_three:Dock( TOP )
	vr_option_three:SetText( "Allow only friends to join" )
	vr_option_three:SetFont( "DermaVRDefault" )
	vr_option_three.Button:SetSize( 32, 32 )
	vr_option_three:DockMargin( 128 + 16, 0, 0, 0 )]]
	
	-- Can only change maxplayers when server isn't running
	-- So we have to timeout this change and disconnect before all of that
	local vr_option_four = map_panel:Add( "DNumSlider" )
	vr_option_four:Dock( TOP )
	vr_option_four:SetText( "Max Players" )
	vr_option_four:SetTall( 50 )
	vr_option_four:SetDecimals( 0 )
	vr_option_four:SetMinMax( 1, 32 )
	vr_option_four:SetConVar( "maxplayers" )
	vr_option_four.TextArea:SetFont( "DermaVRDefault" )
	vr_option_four.Label:SetFont( "DermaVRDefault" )
	vr_option_four:DockMargin( 128 + 16, 0, 0, 0 )
	vr_option_four.OnValueChanged = function( pnl, value )
		map_maxplayers = value
	end
	
	map_panel:Rebuild()
end

-- Need admin functions to CHANGELEVEL
local function run_mapselected(  )
	
	if ( game.SinglePlayer() ) then
		RunConsoleCommand( "disconnect" )
		RunConsoleCommand( "map", map_selected )
	else
		RunConsoleCommand( "fa_changelevel", map_selected )
	end
	
end

local function init_editor( icon, window )
	
	window:SetSkin( "VRDefault" )-- This changes all the panels below
	
	local sheet = window:Add( "DPropertySheet" )
	sheet:Dock( FILL )
	
	local panel_general = window:Add( "DPanel" )
	panel_general:DockPadding( 8, 8, 8, 8 )
	
	local panel_general_icons = panel_general:Add( "DIconLayout" )
	panel_general_icons:Dock( FILL )
	panel_general_icons:SetSpaceY( 3 )
	panel_general_icons:SetSpaceX( 3 )
	
	-- Add all VR settings here
	local button_maps = panel_general_icons:Add( "DButton" )
	button_maps:SetText( "Maps" )
	button_maps:SetFont( "DermaVRDefault" )
	button_maps:SetSize( bsize, bsize )
	
	local button_team = panel_general_icons:Add( "DButton" )
	button_team:SetText( "Select Team" )
	button_team.DoClick = function()
		local newv = list.Get( "FacileDesktopWindows" )["FacileSelectTeam"]
		
		fart = panel_general:Add( "DFrame" )
		fart:SetSize( 600, 528 )
		fart:SetTitle( newv.title )
		fart:Center()
		
		newv.init( icon, fart )
		
		fart:SetDraggable( false )
		fart:SetSizable( false )
	end
	button_team:SetFont( "DermaVRDefault" )
	button_team:SetSize( bsize, bsize )
	
	local button_class = panel_general_icons:Add( "DButton" )
	button_class:SetText( "Select Class" )
	button_class.DoClick = function()
		local newv = list.Get( "FacileDesktopWindows" )["FacileSelectClass"]
		
		fart = panel_general:Add( "DFrame" )
		fart:SetSize( newv.width, newv.height )
		fart:SetTitle( newv.title )
		fart:Center()
		
		newv.init( icon, fart )
		
		fart:SetDraggable( false )
		fart:SetSizable( false )
		fart:SetSize( 600, 528 )
		fart:Center()
	end
	button_class:SetFont( "DermaVRDefault" )
	button_class:SetSize( bsize, bsize )
	
	-- loadout
	local button_loadout = panel_general_icons:Add( "DButton" )
	button_loadout:SetText( "Loadout" )
	button_loadout.DoClick = function()
		local newv = list.Get( "FacileDesktopWindows" )["FacileLoadoutMenu"]
		
		fart = panel_general:Add( "DFrame" )
		fart:SetSize( newv.width, newv.height )
		fart:SetTitle( newv.title )
		fart:Center()
		
		newv.init( icon, fart )
		
		fart:SetDraggable( false )
		fart:SetSizable( false )
		fart:SetSize( 600, 528 )
		fart:Center()
	end
	button_loadout:SetFont( "DermaVRDefault" )
	button_loadout:SetSize( bsize, bsize )
	
	local sheet_main = sheet:AddSheet( "Windows", panel_general, "icon16/cog.png", false, false )
	
	-- // THE MAP
	local panel_themap = window:Add( "DPanel" )
	panel_themap:DockPadding( 8, 8, 8, 8 )
	
	local panel_themap_scroll = panel_themap:Add( "DScrollPanel" )
	panel_themap_scroll:Dock( FILL )
	panel_themap_scroll:DockPadding( 8, 8, 8, 8 )
	
	local panel_themap_footer = panel_themap:Add( "DPanel" )
	panel_themap_footer:Dock( BOTTOM )
	panel_themap_footer:DockPadding( 8, 8, 8, 8 )
	panel_themap_footer:SetTall( bsizeh )
	
	-- Fuck can't change to multiplayer without exiting the whole thing...
	local button_sp = panel_themap_footer:Add( "DButton" )
	button_sp:SetText( "Play" )
	button_sp.DoClick = function() run_mapselected() end
	button_sp:SetFont( "DermaVRDefault" )
	button_sp:SetSize( bsize, bsizeh )
	button_sp:Dock( LEFT )
	button_sp:DockMargin( 0, 0, 8, 0 )
	
	local vr_option_one = panel_themap_footer:Add( "DCheckBoxLabel" )
	vr_option_one:SetConVar( "cl_favr_autostart" )
	vr_option_one:Dock( LEFT )
	vr_option_one:SetText( "Start VR on load" )
	vr_option_one:SetFont( "DermaVRDefault" )
	vr_option_one.Button:SetSize( 32, 32 )
	-- ///
	
	local sheet_map_selected = sheet:AddSheet( "Map Selected", panel_themap, "icon16/cog.png", false, false )
	
	local function goto_mapselected( name )
		build_mapselected( panel_themap_scroll, name )
		
		sheet:SetActiveTab( sheet_map_selected.Tab )
	end
	
	-- // MAPS
	
	local panel_maps = window:Add( "DPanel" )
	panel_maps:DockPadding( 8, 8, 8, 8 )
	
	local panel_category = panel_maps:Add( "DScrollPanel" )
	panel_category:Dock( LEFT )
	panel_category:SetSize( 240, 0 )
	
	local panel_map_panel = panel_maps:Add( "DPanel" )
	panel_map_panel:Dock( FILL )
	panel_map_panel:DockPadding( 8, 8, 8, 8 )
	
	-- ScrollPanel is one big shit head, you have to clear, add, then REBUILD.
	local panel_map_list_scroll = panel_map_panel:Add( "DScrollPanel" )
	panel_map_list_scroll:Dock( FILL )
	
	for cate_key, cate_entry in pairs( map_categories ) do
		
		local button_g = panel_category:Add( "DButton" )
		button_g:SetText( cate_entry.printname )
		button_g.DoClick = function()
			rebuild_maps( panel_map_list_scroll, cate_key, goto_mapselected )
		end
		button_g:SetFont( "DermaVRDefault" )
		button_g:SetSize( 100, bsizeh )
		button_g:Dock( TOP )
		button_g:DockMargin( 0, 0, 4, 3 )
		
	end
	
	panel_category:Rebuild()
	
	local sheet_maps = sheet:AddSheet( "Maps", panel_maps, "icon16/cog.png", false, false )
	
	button_maps.DoClick = function()
		sheet:SetActiveTab( sheet_maps.Tab )
	end
	
	sheet:SetActiveTab( sheet_maps.Tab )
	
	-- MAYBE? Hopfully these work... Ummmmmm
	window.quick_show_team = function()
		sheet:SetActiveTab( sheet_main.Tab )
		button_team:DoClick()
	end
	
	window.quick_show_class = function()
		sheet:SetActiveTab( sheet_main.Tab )
		button_class:DoClick()
	end
	
end

list.Set( "FacileDesktopWindows", "vrmaps", {

	title		= "VR Map Menu",
	icon		= "icon64/facile.png",
	width		= 1280,
	height		= 720,
	onewindow	= true,
	vr          = true,
	init		= init_editor
} )