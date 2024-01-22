local function cast_to_plane( plane_forward, plane_right, plane_up, plane_position, cast_position, cast_forward )

	local thing_hurp = plane_position - cast_position

	local up_dot = thing_hurp:Dot( plane_up )
	local forward_dot = thing_hurp:Dot( plane_forward )
	local right_dot = thing_hurp:Dot( plane_right )

	local perpendicular_vector = ( up_dot * plane_up )
	local perpendicular_length = perpendicular_vector:Length()
	local perpendicular_normal = perpendicular_vector:GetNormalized()

	local perpendicular_dot = cast_forward:Dot( perpendicular_normal )

	local raycast_length = perpendicular_length / perpendicular_dot

	return ( raycast_length * cast_forward ) + cast_position
end

local GM = gmod.GetGamemode()

if ( !GM ) then
	ErrorNoHalt( "[VR]", "Could not redefine gamemode!" )
	return
end

local LocalPlayer, LocalToWorld, WorldToLocal = LocalPlayer, LocalToWorld, WorldToLocal

local p = LocalPlayer()

local current_weapon = nil

local game_max_ammo = GetConVar("gmod_maxammo"):GetInt()
local current_weapon_primary_ammo = -1

local hud_magazine_percent = 0.4
local hud_ammo_percent = 0.5
local hud_health_percent = 1.0
local hud_armor_percent = 0.0

local weapon_change_pos = Vector()
local weapon_change_angle = Angle()
local weapon_change_ui_angle = Angle()
local weapon_change_up = Vector(0,0,1)
local weapon_change_right = Vector()
local weapon_change_forward = Vector()
local weapon_change_x = 0
local weapon_change_y = 0
local weapon_selection_x_dec = 0
local weapon_selection_y_dec = 0
local weapon_selection_int_x = 0
local weapon_selection_int_y = 0
local weapon_selection_weapons = {}
local weapon_selection_the_weapon = nil

local mapmenu_pos = Vector()
local mapmenu_angle = Angle()
local mapmenu_right = Vector()
local mapmenu_up = Vector()
local mapmenu_forward = Vector()

local ui_showmaps_setup = false
local ui_panel_mapmenu = nil
local ui_override_showmaps = false

local ui_use_entity = nil
local ui_panel = nil
local ui_showinteraction = false
local ui_showmenu_setup = false

-- --------------------------
local ui_changeweapon = false
local ui_weaponvalid = false
local ui_showmaps = false
local ui_showmenu = false

local ui_weapon_changing = false

local hmd_angles = Angle()
local hmd_world_position = Vector()

local righthand_world_position = hmd_world_position
local mainhand_ang = hmd_angles
local mainhand_vec = hmd_world_position
local lefthand_world_position = hmd_world_position
local offhand_ang = hmd_angles
local offhand_ang_raw = hmd_angles
local offhand_ang_ui = hmd_angles
local offhand_vec = hmd_world_position
-- --------------------------

local sfx_ammoup = Sound( "VdmPickupGE.Grab" )

local old_magazine_percent = 1

function GM:VR_UpdateUI( data )
	
	local use_entity = p:GetUseEntity()
	
	if ( IsValid( use_entity ) ) then
		ui_showinteraction = true
		
		ui_use_entity = use_entity
	else
		ui_showinteraction = false
	end
	
	-- Index and localise!
	ui_changeweapon = data.changeweapon
	ui_showmaps = data.showmaps
	ui_showmenu = data.showmenu
	
	hmd_angles = p.hmd_angles
	hmd_world_position = p.hmd_world_position
	
	righthand_world_position = p.mainhand_pos
	mainhand_ang = p.mainhand_ang
	mainhand_vec = p.mainhand_vec
	
	if ( ui_override_showmaps ) then
		ui_showmaps = true
		data.showmaps = ui_showmaps
		
		ui_override_showmaps = false
	end
	
	-- // MAP MENU //
	if ( ui_showmaps && !ui_showmaps_setup ) then
		local new_angles = Angle( 30, hmd_angles.y, 0 )
		
		mapmenu_forward = new_angles:Forward()
		mapmenu_up = new_angles:Up()
		mapmenu_right = new_angles:Right()
		
		mapmenu_pos = hmd_world_position + (mapmenu_forward * 32) - (mapmenu_right * 640 * 0.04) + (mapmenu_up * 360 * 0.04)
		
		-- Localize the UI angles
		local butt_pos = Vector()
		butt_pos, mapmenu_angle = LocalToWorld( mapmenu_pos, Angle(0, -90, 90), Vector(), new_angles )
		
		local testvr_stuff = list.Get( "FacileDesktopWindows" )["vrmaps"]
		
		if ( testvr_stuff ) then
			ui_panel_mapmenu = vgui.Create( "DPanel" )
			
			ui_panel_mapmenu:SetPaintedManually( true )
			ui_panel_mapmenu:SetSize( testvr_stuff.width, testvr_stuff.height )
			
			testvr_stuff.init( nil, ui_panel_mapmenu )
			
			ui_panel_mapmenu:MakePopup()
			ui_panel_mapmenu:SetKeyboardInputEnabled( false )
			
			--[[if ( ui_showmaps_startmode == 2 ) then
				ui_panel_mapmenu:quick_show_team()
			elseif ( ui_showmaps_startmode == 3 ) then
				ui_panel_mapmenu:quick_show_class()
			end]]
		end
		
		-- Turn off the offhand menu
		ui_showmenu = false
		data.showmenu = ui_showmenu
		
		ui_showmaps_setup = true
	end
	
	if ( !ui_showmaps && ui_showmaps_setup ) then
		if ( IsValid( ui_panel_mapmenu ) ) then
			ui_panel_mapmenu:Remove()
		end
		
		ui_showmaps_setup = false
	end
	
	-- // OFFHAND MENU //
	if ( ui_showmenu && !ui_showmenu_setup ) then
		local testvr_stuff = list.Get( "FacileDesktopWindows" )["testvr"]
		
		if ( testvr_stuff ) then
			ui_panel = vgui.Create( "DPanel" )
			
			ui_panel:SetPaintedManually( true )
			ui_panel:SetSize( testvr_stuff.width, testvr_stuff.height )
			
			testvr_stuff.init( nil, ui_panel )
			
			ui_panel:MakePopup()
			ui_panel:SetKeyboardInputEnabled( false )
		end
		
		ui_showmenu_setup = true
	end
	
	if ( !ui_showmenu && ui_showmenu_setup ) then
		if ( IsValid( ui_panel ) ) then
			ui_panel:Remove()
		end
		
		ui_showmenu_setup = false
	end
	
	local active_weapon = p:GetActiveWeapon()
	
	if ( active_weapon != current_weapon ) then
		ui_weaponvalid = IsValid( active_weapon )
		
		if ( ui_weaponvalid ) then
			current_weapon = active_weapon
			
			current_weapon_primary_ammo = current_weapon:GetPrimaryAmmoType()
		end
	end
	
	if ( ui_weaponvalid ) then
		hud_magazine_percent = 0
		hud_ammo_percent = 0
		
		local magazine_primary_max = current_weapon:GetMaxClip1()
		local magazine_primary = current_weapon:Clip1()
		
		if ( current_weapon_primary_ammo > -1 ) then
			local max_ammo = game_max_ammo
			
			if ( max_ammo < 1 ) then
				max_ammo = game.GetAmmoMax( current_weapon_primary_ammo )
			end
			
			hud_ammo_percent = p:GetAmmoCount( current_weapon_primary_ammo ) / max_ammo
		end
		
		if ( magazine_primary_max > 0 ) then
			hud_magazine_percent = magazine_primary / magazine_primary_max
			
			if ( (hud_magazine_percent - old_magazine_percent) > 0 ) then
				p:EmitSound( sfx_ammoup )
			end
			
			old_magazine_percent = hud_magazine_percent
		end
	end
	
	-- WEAPON SELECTION
	if ( ui_changeweapon && !ui_weapon_changing ) then
		-- Setup the main hand selection
		
		weapon_change_angle = mainhand_ang * 1
		
		weapon_change_forward = mainhand_vec * 1
		
		weapon_change_pos = righthand_world_position + (weapon_change_forward * 16)
		
		weapon_change_right = weapon_change_angle:Right()
		weapon_change_up = weapon_change_angle:Up()
		
		weapon_change_forward = weapon_change_forward * -1
		
		local butt_pos = Vector()
		
		butt_pos, weapon_change_ui_angle = LocalToWorld( weapon_change_pos, Angle(0, -90, 90), Vector(), weapon_change_angle )
		
		-- GET WEAPONS
		local pre_selection_weapons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {}
		}
		
		weapon_selection_weapons = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {},
			[5] = {},
			[6] = {}
		}
		
		for k, w in ipairs( p:GetWeapons() ) do
			local w_slot = math.Clamp( w:GetSlot(), 0, 5 ) + 1
			local w_slotpos = w:GetSlotPos()
			
			table.insert( pre_selection_weapons[ w_slot ], w_slotpos, w )
		end
		
		for tk, t in ipairs( pre_selection_weapons ) do
			for k, w in pairs( t ) do
				table.insert( weapon_selection_weapons[ tk ], w )
			end
		end
		
		ui_weapon_changing = true
	elseif ( !ui_changeweapon && ui_weapon_changing ) then
		if ( IsValid( weapon_selection_the_weapon ) ) then
			input.SelectWeapon( weapon_selection_the_weapon )
		end
		
		ui_weapon_changing = false
	end
	
	-- TODO: CLEAN THIS SHIT UP LOL
	if ( ui_weapon_changing ) then
		local cast_pos = cast_to_plane( weapon_change_up, weapon_change_right, weapon_change_forward, weapon_change_pos, righthand_world_position, mainhand_vec )
		
		local cast_relative_pos = weapon_change_pos - cast_pos
		
		weapon_change_x = cast_relative_pos:Dot( weapon_change_right ) * -0.125
		weapon_change_y = cast_relative_pos:Dot( weapon_change_up ) * 0.25
		
		local selection_x_rounded = math.Clamp( math.Round( weapon_change_x ), -1, 4 )
		
		weapon_selection_x_dec = weapon_change_x - selection_x_rounded
		weapon_selection_x_dec = math.Clamp( weapon_selection_x_dec, -1, 1 )
		
		weapon_selection_int_x = math.Clamp( (selection_x_rounded - 2) + 4, 1, 6 )
		
		if ( #weapon_selection_weapons > 0 ) then
			local slot_items = #weapon_selection_weapons[weapon_selection_int_x]
			
			if ( slot_items > 0 ) then
				local selection_y_rounded = math.Clamp( math.Round( weapon_change_y + 1 ), 1, slot_items )
				
				weapon_selection_the_weapon = weapon_selection_weapons[weapon_selection_int_x][selection_y_rounded]
			else
				weapon_selection_the_weapon = nil
			end
		else
			weapon_selection_the_weapon = nil
		end
	end
	-- WEAPON SELECTION
	
	if ( p:Alive() ) then
		hud_health_percent = math.Clamp( p:Health() / p:GetMaxHealth(), 0, 1 )
		hud_armor_percent = math.Clamp( p:Armor() / p:GetMaxArmor(), 0, 1 )
	else
		hud_health_percent = 0.0
		hud_armor_percent = 0.0
	end
end

-- Bounds is below the position
local laser_color = Color(0, 255, 0, 255)
local blank_angle = Angle(0, 0, 0)
local wire_color = Color(  80,  80,  80, 100 )
local bg_color = Color(0, 0, 0, 255)
local hlhud_color = Color(255, 236, 12, 255)
local hlhud_color2 = Color(205, 186, 0, 40)-- Alpha 70
local hlhud_color3 = Color(205, 0, 0, 40)
local hlhud_color4 = Color(255, 236, 12, 80)

local pointer_color = Color(119, 197, 227, 192)
local pointer_color2 = Color(119, 197, 227, 80)-- Alpha 192
local pointer_color3 = Color(69, 147, 177, 40)

local weapon_select_icon_mins = Vector(-8, -4, -1)
local weapon_select_icon_maxs = Vector(8, 4, 1)

local weapon_select_icon_small_mins = Vector(-1, -2, -1)
local weapon_select_icon_small_maxs = Vector(1, 2, 1)

local material_helperhalo = Material( "effects/noz_ring" )
local material_grad = Material( "gui/center_gradient" )
local material_laser = Material( "effects/fadelaser_1_noz" )--Material( "effects/fadelaser_2_noz" )
local material_pointer = Material( "vdmvr/pointer" )

local dmin = Vector( -0.15, 0, -0.15 )
local dmax = Vector( 0.15, 0.15, 0.15 )

local color_right_hand = wire_color
local color_left_hand = wire_color

local function draw_indicator( position, up, right, height, draw_color )
	render.SetColorMaterial()
	
	--cam.IgnoreZ( true )
	
	local draw_y, draw_x = up * -1 * height, right * 0.5
	
	render.DrawQuad(
		position,
		position + draw_x,
		position + draw_y + draw_x,
		position + draw_y,
		draw_color
	)
	
	--cam.IgnoreZ( false )
end

function GM:VR_DrawUI( data )
	-- --------------------------------------
	ui_showmaps = data.showmaps
	ui_showmenu = data.showmenu
	
	hmd_angles = p.hmd_angles
	hmd_world_position = p.hmd_world_position
	
	righthand_world_position = p.mainhand_pos
	mainhand_ang = p.mainhand_ang
	mainhand_vec = p.mainhand_vec
	
	lefthand_world_position = p.offhand_pos
	offhand_ang = p.offhand_ang
	offhand_ang_raw = p.offhand_ang_raw
	offhand_ang_ui = p.offhand_ang_ui
	offhand_vec = p.offhand_vec
	
	if ( ui_override_showmaps ) then
		ui_showmaps = true
		data.showmaps = ui_showmaps
		
		ui_override_showmaps = false
	end
	-- --------------------------------------
	
	if ( ui_showinteraction ) then
		color_right_hand = pointer_color
	else
		color_right_hand = wire_color
	end
	
	local pos = p:GetPos()
	
	local lhand_up = offhand_ang_raw:Forward()
	local lhand_forward = offhand_ang_raw:Up()
	local lhand_right = offhand_ang_raw:Right()

	local rhand_forward = mainhand_ang:Forward()
	local rhand_right = mainhand_ang:Right()
	local rhand_up = mainhand_ang:Up()
	
	if ( ui_showmenu ) then
		local cast_pos = cast_to_plane( lhand_up, lhand_right, lhand_forward * -1, lefthand_world_position, righthand_world_position, rhand_forward )
		
		local cast_relative_pos = lefthand_world_position - cast_pos
		
		-- (1 / 0.02) = 50
		-- This is our scale for the UI and then we do the opposite for the cast
		local final_x = cast_relative_pos:Dot( lhand_right ) * -50
		local final_y = cast_relative_pos:Dot( lhand_up ) * 50
		--local doinker = Format( "%d %d", final_x, final_y )
		
		if ( IsValid( ui_panel ) ) then
			
			cam.Start3D2D( lefthand_world_position, offhand_ang_ui, 0.02 )
				ui_panel:PaintManual()
				
				--draw.SimpleText( doinker, "Trebuchet24", 1, 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			cam.End3D2D()
		end
		
		-- We popup the panel, so just set the mouse position
		input.SetCursorPos( final_x, final_y )
		
		--render.DrawLine( lefthand_world_position + (lhand_right * 10), lefthand_world_position + (lhand_right * 2), pointer_color, false )
		
		render.SetMaterial( material_laser )
		render.DrawBeam( righthand_world_position, cast_pos, 0.15, 0, 0.5, pointer_color )
		
		render.SetMaterial( material_pointer )
		render.DrawQuadEasy( cast_pos, lhand_forward * -1, 0.5, 0.5, color_white, offhand_ang.z * -1 )
	end
	
	if ( !ui_showmenu && ui_showinteraction ) then
		render.SetMaterial( material_laser )
		render.DrawBeam( righthand_world_position + ( rhand_up * -3 ), ui_use_entity:WorldSpaceCenter(), 0.15, 0, 1, pointer_color )
	end
	
	if ( ui_showmaps ) then
		local cast_pos = cast_to_plane( mapmenu_up, mapmenu_right, mapmenu_forward * -1, mapmenu_pos, righthand_world_position, rhand_forward )
		
		local cast_relative_pos = mapmenu_pos - cast_pos
		
		-- (1 / 0.02) = 50
		-- This is our scale for the UI and then we do the opposite for the cast
		local final_x = cast_relative_pos:Dot( mapmenu_right ) * -25
		local final_y = cast_relative_pos:Dot( mapmenu_up ) * 25
		
		if ( IsValid( ui_panel_mapmenu ) ) then
			cam.Start3D2D( mapmenu_pos, mapmenu_angle, 0.04 )
				ui_panel_mapmenu:PaintManual()
			cam.End3D2D()
		end
		
		input.SetCursorPos( final_x, final_y )
		
		render.SetMaterial( material_laser )
		render.DrawBeam( righthand_world_position, cast_pos, 0.15, 0, 0.5, pointer_color )
		
		render.SetMaterial( material_pointer )
		render.DrawQuadEasy( cast_pos, mapmenu_forward * -1, 0.5, 0.5, color_white, 0 )
	end
	
	-- Draw selection boxs
	if ( ui_weapon_changing ) then
		cam.Start3D2D( weapon_change_pos, weapon_change_ui_angle, 0.05 )
			local txt = "No Weapon"
			
			if ( IsValid( weapon_selection_the_weapon ) ) then
				txt = weapon_selection_the_weapon:GetPrintName()
				
				if ( weapon_selection_the_weapon.DrawWeaponSelection != nil ) then
					weapon_selection_the_weapon:DrawWeaponSelection( -64, -48, 128, 64, 255 )
				end
			end
			
			draw.SimpleText( txt, "DermaVRDefault", 0, 32, hlhud_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
		
		-- primary box
		render.DrawWireframeBox( weapon_change_pos, weapon_change_ui_angle, weapon_select_icon_mins, weapon_select_icon_maxs, hlhud_color, true )
		
		-- left most
		for i = 1, (weapon_selection_int_x - 1) do
			render.DrawWireframeBox(
				weapon_change_pos + (i * -3 * weapon_change_right) + (weapon_change_right * (-7 + weapon_selection_x_dec)),
				weapon_change_ui_angle,
				weapon_select_icon_small_mins,
				weapon_select_icon_small_maxs,
				hlhud_color,
				true
			)
		end
		
		-- right most
		for i = weapon_selection_int_x, 5 do
			render.DrawWireframeBox(
				weapon_change_pos + ((6 - i) * 3 * weapon_change_right) + (weapon_change_right * (7 + weapon_selection_x_dec)),
				weapon_change_ui_angle,
				weapon_select_icon_small_mins,
				weapon_select_icon_small_maxs,
				hlhud_color,
				true
			)
		end
	end
	
	local magazine_color = hlhud_color2
	
	if ( hud_magazine_percent <= 0 ) then
		magazine_color = hlhud_color3
	end
	
	local hp_color = hlhud_color2
	
	if ( hud_health_percent <= 0.33 ) then
		hp_color = hlhud_color3
	end
	
	-- AMMO
	draw_indicator( righthand_world_position + (rhand_right * 2), rhand_up, rhand_right, 2, magazine_color )
	draw_indicator( righthand_world_position + ((1 - hud_magazine_percent) * rhand_up * -2) + (rhand_right * 2), rhand_up, rhand_right, 2 * hud_magazine_percent, hlhud_color4 )
	
	draw_indicator( righthand_world_position + (rhand_up * -2.1) + (rhand_right * 2), rhand_up, rhand_right, 2, pointer_color3 )
	draw_indicator( righthand_world_position + (rhand_up * -2.1) + (rhand_right * 2), rhand_up, rhand_right, 2 * hud_ammo_percent, pointer_color2 )
	
	-- HEALTH ARMOR
	draw_indicator( lefthand_world_position + (lhand_right * -2), lhand_up, lhand_right, 2, hp_color )
	draw_indicator( lefthand_world_position + ((1 - hud_health_percent) * lhand_up * -2) + (lhand_right * -2), lhand_up, lhand_right, 2 * hud_health_percent, hlhud_color4 )
	
	draw_indicator( lefthand_world_position + (lhand_up * -2.1) + (lhand_right * -2), lhand_up, lhand_right, 2, pointer_color3 )
	draw_indicator( lefthand_world_position + (lhand_up * -2.1) + (lhand_right * -2), lhand_up, lhand_right, 2 * hud_armor_percent, pointer_color2 )
	
	--[[if ( !hands_free ) then
		render.DrawLine( righthand_world_position + (rhand_right * -1), righthand_world_position + (rhand_right * 1), laser_color, true )
		render.DrawLine( righthand_world_position + (rhand_up * -1), righthand_world_position, laser_color, true )

		render.SetMaterial( material_helperhalo )
		render.DrawSprite( righthand_world_position + (rhand_forward * 16), 1, 1, laser_color )
	end]]
end

-- Callbacks from the menus to the VR menus
function GM:VRShowMapMenu( value )
	-- Called from offhand MAPS button
	--[[ui_showmaps_startmode = value
	
	if ( IsValid( ui_panel_mapmenu ) && ui_showmaps ) then
		
		if ( ui_showmaps_startmode == 2 ) then
			ui_panel_mapmenu:quick_show_team()
		elseif ( ui_showmaps_startmode == 3 ) then
			ui_panel_mapmenu:quick_show_class()
		end
		
	end]]
	
	if ( value > 0 ) then
		ui_override_showmaps = true
	end
end