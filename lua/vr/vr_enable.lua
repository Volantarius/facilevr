module_loaded = pcall( function() require( "vrmod" ) end )

vr_module_version = vrmod.GetVersion()

local GM = gmod.GetGamemode()

if ( vr_module_version > 0 ) then
	print( "[VR]", "Running version: ", vr_module_version )
else
	ErrorNoHalt( "[VR]", "Failed to load VR Mod" )

	VR_MODE = false
	
	return false
end

if ( !GM ) then
	ErrorNoHalt( "[VR]", "Could not redefine gamemode!" )
	return
end

local LocalPlayer, LocalToWorld, WorldToLocal, util_TraceLine = LocalPlayer, LocalToWorld, WorldToLocal, util.TraceLine

local p = LocalPlayer()

-- Make the player skinny lol
p:SetHull( Vector(-12, -12, 0), Vector(12, 12, 72) )
p:SetHullDuck( Vector(-12, -12, 0), Vector(12, 12, 36) )

-- Have to shutdown before re-init
vrmod.Shutdown()

vrmod.Init()

RunConsoleCommand( "mat_hdr_manual_tonemap_rate", "0.2" )-- Slow down the rate! Makes it look more real
RunConsoleCommand( "mat_disable_bloom", "1" )-- Bloom is bad looking in VR
RunConsoleCommand( "gmod_mcore_test", "0" )
--RunConsoleCommand( "engine_no_focus_sleep", "0" )

-- First time initialize
-- Otherwise on reload this will stay enabled and we don't have to setup actions over again
if ( !VR_MODE ) then
	-- CLIENT GLOBAL
	VR_MODE = true

	vrmod.SetActionManifest( "vrmod/vrmod_action_manifest.txt" )
	vrmod.SetActiveActionSets( "/actions/base", "/actions/main" )
end

local vr_displayinfo = vrmod.GetDisplayInfo( 1, 10 )-- from vrmod

local function setup_sharedtexturecoords()
	-- From VRMod
	-- Not sure where this code came from but yea..
	local displayCalculations = { left = {}, right = {}}
	
	for k,v in pairs( displayCalculations ) do
		local mtx = (k=="left") and vr_displayinfo.ProjectionLeft or vr_displayinfo.ProjectionRight
		local xscale = mtx[1][1]
		local xoffset = mtx[1][3]
		local yscale = mtx[2][2]
		local yoffset = mtx[2][3]
		local tan_px = math.abs((1.0 - xoffset) / xscale)
		local tan_nx = math.abs((-1.0 - xoffset) / xscale)
		local tan_py = math.abs((1.0 - yoffset) / yscale)
		local tan_ny = math.abs((-1.0 - yoffset) / yscale)
		local w = tan_px + tan_nx
		local h = tan_py + tan_ny
		v.HorizontalFOV = math.atan(w / 2.0) * 180 / math.pi * 2
		v.AspectRatio = w / h
		v.HorizontalOffset = xoffset
		v.VerticalOffset = yoffset
	end

	local vMin = system.IsWindows() and 0 or 1
	local vMax = system.IsWindows() and 1 or 0
	local uMinLeft = 0.0 + displayCalculations.left.HorizontalOffset * 0.25
	local uMaxLeft = 0.5 + displayCalculations.left.HorizontalOffset * 0.25
	local vMinLeft = vMin - displayCalculations.left.VerticalOffset * 0.5
	local vMaxLeft = vMax - displayCalculations.left.VerticalOffset * 0.5
	local uMinRight = 0.5 + displayCalculations.right.HorizontalOffset * 0.25
	local uMaxRight = 1.0 + displayCalculations.right.HorizontalOffset * 0.25
	local vMinRight = vMin - displayCalculations.right.VerticalOffset * 0.5
	local vMaxRight = vMax - displayCalculations.right.VerticalOffset * 0.5

	vrmod.SetSubmitTextureBounds(uMinLeft, vMinLeft, uMaxLeft, vMaxLeft, uMinRight, vMinRight, uMaxRight, vMaxRight)

	local hfovLeft = displayCalculations.left.HorizontalFOV
	local hfovRight = displayCalculations.right.HorizontalFOV
	local aspectLeft = displayCalculations.left.AspectRatio
	local aspectRight = displayCalculations.right.AspectRatio
	local ipd = vr_displayinfo.TransformRight[1][4]*2
	local eyez = vr_displayinfo.TransformRight[3][4]

	return hfovLeft, hfovRight, aspectLeft, aspectRight, ipd, eyez
end

local vr_scrw, vr_scrh = vr_displayinfo.RecommendedWidth * 2, vr_displayinfo.RecommendedHeight
local vr_scale = 38.7

print(vr_scrw, vr_scrh)

-- Note: Using RT_SIZE_LITERAL improved the shit out of the performance, also the depth probably helps
vrmod.ShareTextureBegin()
local vr_shared_rt = GetRenderTargetEx(
	"vrmod_rt"..tostring(SysTime()),
	vr_scrw,
	vr_scrh,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SHARED,
	bit.bor(2, 256),
	0,
	IMAGE_FORMAT_BGRA8888
)
vrmod.ShareTextureFinish()

local VRFlashlight = ProjectedTexture()
--VRFlashlight:SetTexture( "volantarius/flashlight001" )
VRFlashlight:SetTexture( "effects/flashlight001" )
VRFlashlight:SetFarZ( 1300 )
VRFlashlight:SetQuadraticAttenuation( 100 )
VRFlashlight:SetLinearAttenuation( 0 )
VRFlashlight:SetConstantAttenuation( 0 )
VRFlashlight:SetFOV( 40 )-- or 50
VRFlashlight:SetBrightness( 0 )
VRFlashlight:SetColor( Color(255, 255, 255, 255) )
VRFlashlight:Update()
-- This kind of flashlight, don't set the brightness over 100, and Quad 100 is peerrrfect

local flashlight_toggle = false

-- Setup shared texture UV coords, and get HMD info
local l_hfov, r_hfov, l_aspect, r_aspect, ipd, eyez = setup_sharedtexturecoords()

local base_forward = Vector(0, 1, 0)
local base_right = Vector(1, 0, 0)

local origin_pos = Vector(0, 0, 0)
local origin_ang = Angle(0, 0, 0)
local origin_ang_rotated = Angle(0, 0, 0)
local changed_flick_angle = 0
local flick_angle = 0

local origin_eye_offset = Vector(0, 0, 4)-- 4

local loco_player_move = Vector(0, 0, 0)
local loco_player_offset = Vector(0, 0, 0)

local hmd_position = origin_pos
local hmd_angles = Angle(0, 0, 0)
local hmd_preworld_position = hmd_position
local hmd_world_position = hmd_position
local hmd_noeyez_position = hmd_position

-- Shared offsets
local controller_angle_offset = Angle(50, 0, 0)
local controller_pos_offset = Vector(0, 0, 0)
local controller_ui_offset = Angle(0, -90, 0)

local controller_left_pad = Vector()
local controller_right_pad = Vector()

local controller_left_thumb = Vector()
local controller_right_thumb = Vector()
local controller_left_trigger = 0
local controller_right_trigger = 0

local lefthand_position = origin_pos
local lefthand_angles = Angle(0, 0, 0)
local lefthand_angles_raw = Angle(0, 0, 0)
local lefthand_angles_ui = Angle(0, 0, 0)
local lefthand_world_position = lefthand_position

local righthand_position = origin_pos
local righthand_angles = Angle(0, 0, 0)
local righthand_angles_flashlight = Angle(0, 0, 0)
local righthand_angles_ui = Angle(0, 0, 0)
local righthand_world_position = righthand_position
local righthand_velocity = origin_pos
local righthand_angvel = Angle(0, 0, 0)

local eye_pos_l = hmd_position
local eye_pos_r = hmd_position

local turnleft_pressed = false
local turnright_pressed = false
local flashlight_pressed = false
local changeweapon_pressed = false
local spawnmenu_pressed = false
local otheruse_pressed = false
local sprint_pressed = false
local sprint_toggle = false
local crouch_pressed = false
local crouch_toggle = false
local crouch_fix = false
local left_pickup_pressed = false
local right_pickup_pressed = false
local use_offhand = false
local use_primary = false
local reload_pressed = false
local jump_pressed = false

local ui_data = {
	changeweapon = false,
	showmaps = false,
	showmenu = false,
	showmaps_startmode = 0,
	hands_free = false
}

local module_data = {
	actions = {
		use_offhand = false,
		use_mainhand = false
	}
}

local sfx_flashlight = Sound( "HL2Player.FlashLightOn" )
local sfx_reload = Sound( "VdmPickupGE.Reload" )

local favr_fire_pos = GetConVar( "favr_fire_pos" )
local favr_fire_ang = GetConVar( "favr_fire_ang" )
local favr_fire_vec = GetConVar( "favr_fire_vec" )

local favr_laser = GetConVar( "cl_vrlaser" )

local vr_actions, vr_actions_diff = {}, {}

function GM:CreateMove( cmd )
	vr_actions, vr_actions_diff = vrmod.GetActions()
	
	local alive = p:Alive()
	
	if ( vr_actions.boolean_flashlight && !flashlight_pressed ) then
		
		--flashlight_toggle = not flashlight_toggle
		
		if ( !flashlight_toggle ) then
			VRFlashlight:SetBrightness( 0 )
			VRFlashlight:Update()
		else
			VRFlashlight:SetBrightness( 100 )
		end
		
		p:EmitSound( sfx_flashlight )
		
		hands_free = !hands_free
		ui_data.hands_free = hands_free
		
		flashlight_pressed = true
	elseif ( !vr_actions.boolean_flashlight && flashlight_pressed ) then
		flashlight_pressed = false
	end
	
	-- RELOAD
	if ( vr_actions.boolean_reload && !reload_pressed ) then
		p:EmitSound( sfx_reload )
		
		if ( hands_free ) then
			eye_test = eye_test + 1
			
			eye_cross_test = 0
			eye_options = Vector()
			
			if ( eye_test > 13 ) then
				eye_test = 0
			end
		end
		
		reload_pressed = true
	elseif ( !vr_actions.boolean_reload && reload_pressed ) then
		reload_pressed = false
	end
	
	-- VR MENU
	if ( vr_actions.boolean_chat && !spawnmenu_pressed ) then
		
		if ( ui_data.showmaps ) then
			ui_data.showmaps = false
		else
			ui_data.showmenu = not ui_data.showmenu
		end
		
		spawnmenu_pressed = true
	elseif ( !vr_actions.boolean_chat && spawnmenu_pressed ) then
		spawnmenu_pressed = false
	end
	
	if ( vr_actions.boolean_use_offhand && !use_offhand ) then
		
		if ( ui_data.showmenu || ui_data.showmaps ) then
			gui.InternalMousePressed( MOUSE_LEFT )
		end
		
		module_data.actions.use_offhand = true
		
		if ( !ui_data.showmenu && !ui_data.showmaps ) then
			crouch_toggle = not crouch_toggle
		end
		
		use_offhand = true
	elseif ( !vr_actions.boolean_use_offhand && use_offhand ) then
		use_offhand = false
		
		gui.InternalMouseReleased( MOUSE_LEFT )
	end
	
	--[[if ( vr_actions.boolean_otheruse && !otheruse_pressed ) then
		otheruse_pressed = true
	elseif ( !vr_actions.boolean_otheruse && otheruse_pressed ) then
		otheruse_pressed = false
	end]]
	
	-- PICKUP
	if ( vr_actions.boolean_left_pickup && !left_pickup_pressed ) then
		left_pickup_pressed = true
	elseif ( !vr_actions.boolean_left_pickup && left_pickup_pressed ) then
		left_pickup_pressed = false
	end
	
	if ( vr_actions.boolean_sprint && !sprint_pressed ) then
		sprint_toggle = not sprint_toggle
		
		sprint_pressed = true
	elseif ( !vr_actions.boolean_sprint && sprint_pressed ) then
		sprint_pressed = false
	end

	-- IN PLACE OF CROUCH TOGGLE
	--boolean_undo
	if ( vr_actions.boolean_undo && !crouch_pressed ) then
		
		--crouch_toggle = not crouch_toggle
		
		crouch_pressed = true
	elseif ( !vr_actions.boolean_undo && crouch_pressed ) then
		crouch_pressed = false
	end
	
	if ( vr_actions.boolean_turnleft && !turnleft_pressed ) then
		changed_flick_angle = changed_flick_angle + 45
		
		if ( !alive ) then
			net.Start("facile_requeststate", true)
				net.WriteUInt( 52, 32 )
			net.SendToServer()
		end
		
		turnleft_pressed = true
	elseif ( !vr_actions.boolean_turnleft && turnleft_pressed ) then
		turnleft_pressed = false
	end

	if ( vr_actions.boolean_turnright && !turnright_pressed ) then
		changed_flick_angle = changed_flick_angle - 45
		
		if ( !alive ) then
			net.Start("facile_requeststate", true)
				net.WriteUInt( 51, 32 )
			net.SendToServer()
		end
		
		turnright_pressed = true
	elseif ( !vr_actions.boolean_turnright && turnright_pressed ) then
		turnright_pressed = false
	end
	
	local left_track = vr_actions.vector2_left_track
	local right_track = vr_actions.vector2_right_track
	
	if ( left_track ) then
		controller_left_pad.x = left_track.x
		controller_left_pad.y = left_track.y
	end
	
	if ( right_track ) then
		controller_right_pad.x = right_track.x
		controller_right_pad.y = right_track.y
	end
	
	-- We do a fako analog stick because a gesture is annoying
	if ( (ui_data.showmaps || ui_data.showmenu) && left_track ) then
		
		gui.InternalMouseWheeled( math.floor( left_track.y * 2.0 ) )-- -_- FFFF
	end
	
	if ( sprint_toggle ) then
		cmd:AddKey( IN_SPEED )
	end

	if ( vr_actions.boolean_reload ) then
		cmd:AddKey( IN_RELOAD )
	end
	
	if ( vr_actions.boolean_use ) then
		cmd:AddKey( IN_USE )
	end

	if ( vr_actions.boolean_jump ) then
		cmd:AddKey( IN_JUMP )
	end
	
	-- JUMP pressed
	if ( vr_actions.boolean_jump && !jump_pressed ) then
		if ( !alive ) then
			net.Start("facile_requeststate", true)
				net.WriteUInt( 50, 32 )
			net.SendToServer()
		end
		
		jump_pressed = true
	elseif ( !vr_actions.boolean_jump && jump_pressed ) then
		jump_pressed = false
	end
	
	-- Primary trigger
	if ( !hands_free && vr_actions.boolean_primaryfire ) then
		
		if ( !ui_data.showmenu && !ui_data.showmaps ) then
			cmd:AddKey( IN_ATTACK )
		end
	end
	
	-- Primary use
	if ( vr_actions.boolean_primaryfire && !use_primary ) then
		
		if ( ui_data.showmenu || ui_data.showmaps ) then
			gui.InternalMousePressed( MOUSE_LEFT )
		end
		
		module_data.actions.use_mainhand = true
		
		use_primary = true
	elseif ( !vr_actions.boolean_primaryfire && use_primary ) then
		use_primary = false
		
		gui.InternalMouseReleased( MOUSE_LEFT )
	end

	
	if ( !hands_free && vr_actions.boolean_secondaryfire ) then
		cmd:AddKey( IN_ATTACK2 )
	end
	
	if ( !hands_free ) then
		ui_data.changeweapon = vr_actions.boolean_changeweapon
	end
	
	--changeweapon_pressed
	--[[if ( vr_actions.boolean_changeweapon && !changeweapon_pressed ) then
		
		changeweapon_pressed = true
	elseif ( !vr_actions.boolean_changeweapon && changeweapon_pressed ) then
		changeweapon_pressed = false
	end]]

	-- DUCKING!!
	if ( hmd_preworld_position.z <= 50 && !crouch_toggle ) then

		--cmd:AddKey( IN_DUCK )
		crouch_fix = true

	elseif ( hmd_preworld_position.z > 50 && crouch_toggle ) then

		-- I don't about the standing and allowing to crouch... We can clip into the world this way
		--cmd:AddKey( IN_DUCK )
		crouch_fix = true
	else
		
		crouch_fix = false

	end
	
	if ( crouch_fix && alive ) then
		cmd:AddKey( IN_DUCK )
	end
	
	-- Use HMD, this fixs all of the ladder and digital inputs
	-- Also makes the player's model look in the same direction we are
	local in_vehicle = p:InVehicle()
	
	if ( in_vehicle ) then
		local veh = p:GetVehicle()
		local veh_ang = veh:GetAngles()
		
		-- Vehicles need a simple fix up
		cmd:SetViewAngles( hmd_angles - veh_ang )
	else
		cmd:SetViewAngles( hmd_angles )
	end
	
	local walk_vector = Vector( vr_actions.vector2_walkdirection.x, vr_actions.vector2_walkdirection.y, 0 )
	local walk_x = walk_vector.x
	local walk_y = walk_vector.y
	
	if ( vr_actions.vector2_walkdirection.x ) then
		controller_left_thumb = walk_vector
		controller_right_thumb = Vector( vr_actions.vector2_smoothturn.x, vr_actions.vector2_smoothturn.y, 0 )
	end
	
	if ( vr_actions.vector1_secondaryfire ) then
		controller_left_trigger = vr_actions.vector1_secondaryfire
	end
	
	if ( vr_actions.vector1_primaryfire ) then
		controller_right_trigger = vr_actions.vector1_primaryfire
	end
	
	local speed_max = p:GetMaxSpeed()
	
	local digital_dot_forward = base_forward:Dot( walk_vector )
	local digital_dot_right = base_right:Dot( walk_vector )
	
	local digital_vector = Vector(0, 0, 0)
	local digital_key = 0
	
	if ( digital_dot_forward > 0.5 ) then
		digital_key = IN_FORWARD
		digital_vector.y = 1
	elseif ( digital_dot_forward < -0.5 ) then
		digital_key = IN_BACK
		digital_vector.y = -1
	elseif ( digital_dot_right > 0.5 ) then
		digital_key = IN_MOVERIGHT
		digital_vector.x = 1
	elseif ( digital_dot_right < -0.5 ) then
		digital_key = IN_MOVELEFT
		digital_vector.x = -1
	end
	
	if ( alive ) then
		
		if ( !in_vehicle ) then
			cmd:AddKey( digital_key )
			
			if ( p:GetMoveType() == MOVETYPE_WALK ) then
				
				local forward = speed_max * walk_y
				local side = speed_max * walk_x
				
				--[[if ( math.abs(walk_y) <= 0 ) then
					forward = forward + loco_relative_forward
				end
				
				if ( math.abs(walk_x) <= 0 ) then
					side = side + loco_relative_side
				end]]
				
				cmd:SetForwardMove( forward )
				cmd:SetSideMove( side )
				
			else
				cmd:SetForwardMove( speed_max * digital_vector.y )
				cmd:SetSideMove( speed_max * digital_vector.x )
			end
		else
			cmd:SetForwardMove( 400 * walk_y )
			cmd:SetSideMove( 400 * walk_x )
		end
		
	else
		cmd:SetForwardMove( speed_max * digital_vector.y )
		cmd:SetSideMove( speed_max * digital_vector.x )
	end
	
end

-- Setup below in PlayerUpdateVR
local cmPlayer = nil

local bone_pelvis, bone_righthand = -1, -1

local view_left = {
	origin = Vector(0, 0, 0),
	angles = Angle(0, 0, 0),
	aspect = l_aspect,
	x = 0,
	y = 0,
	w = vr_scrw * 0.5,
	h = vr_scrh,
	fov = l_hfov,
	znear = 0.4,
	--zfar = ,
	dopostprocess = true,-- @TEST: Disable Bloom all together and see if that works
	bloomtone = true,
	
	drawmonitors = false,-- Call once on left
	drawviewmodel = false,
	drawhud = false
}

local view_right = {
	origin = Vector(0, 0, 0),
	angles = Angle(0, 0, 0),
	aspect = r_aspect,
	x = vr_scrw * 0.5,
	y = 0,
	w = vr_scrw * 0.5,
	h = vr_scrh,
	fov = r_hfov,
	znear = 0.4,
	--zfar = ,
	dopostprocess = true,
	bloomtone = true,
	
	drawmonitors = false,-- Call once on left
	drawviewmodel = false,
	drawhud = false
}

-- Make this easier to use the modified origin angles
local function get_world_pose( raw_pose, raw_pose_angles )
	return LocalToWorld( raw_pose * vr_scale, raw_pose_angles, origin_pos, origin_ang_rotated )
end

local player_pos_render = p:GetPos()
local old_player_pos = player_pos_render

-- For rotating
local pre_hmd_rotation_position, pre_hmd_rotation_angles = hmd_position, hmd_angles

local cmWeapon = ents.CreateClientProp()
local current_weapon = nil
local sWorldModel = "error.mdl"
local cmWeaponValid = false
local cmWeaponOffset = Vector(0, 0, 0)
local cmWeaponAngles = Angle(0, 0, 0)
local cmWeaponInitialBoneOffset = Vector(0, 0, 0)
local cmWeaponInitialBoneAngles = Angle(0, 0, 0)
local cmWeapon_NoMuzzleOffset = Vector(0, 0, 0)

local cmEyeTest_l = ents.CreateClientProp()
local cmEyeTest_r = ents.CreateClientProp()

function GM:RenderScene( origin, angle, fov )
	--render.Clear( 0, 0, 0, 255 )-- maybe?

	vrmod.UpdatePosesAndActions()

	old_player_pos = player_pos_render

	local current_time = CurTime()

	-- @Note: Poses does need to be in here! Otherwise theres delay and latency
	local poses = vrmod.GetPoses()

	player_pos_render = p:GetPos()
	
	-- (2023) So in VRMOD ground_entity's velocity is used and then FrameTime is applied and finally added to the origin to make it do something lol
	-- Maybe we can fix the jitter???
	--[[local ground_entity = p:GetGroundEntity()
	
	local diff_velocity = Vector()
	
	if ( IsValid(ground_entity) && not ground_entity:IsWorld() ) then
		local ground_velocity = ground_entity:GetVelocity()
		
		diff_velocity = ground_velocity
	end
	
	loco_player_offset = loco_player_offset + (diff_velocity * FrameTime())]]
	
	local raw_hmd_pos = poses.hmd.pos * 1
	local raw_hmd_z = raw_hmd_pos.z * 1
	
	raw_hmd_pos.z = 0
	
	-- Catch rotation, to then setup difference in rotation
	if ( changed_flick_angle ) then
		flick_angle = flick_angle + changed_flick_angle
		
		pre_hmd_rotation_position, pre_hmd_rotation_angles = get_world_pose( raw_hmd_pos, poses.hmd.ang )
	end

	origin_ang_rotated = Angle(0, flick_angle, 0)
	
	local inVehicle = p:InVehicle()
	
	if ( inVehicle ) then
		local veh = p:GetVehicle()
		local veh_ang = veh:GetAngles()
		local not_needed = nil
		
		not_needed, origin_ang_rotated = LocalToWorld( Vector(), Angle(0, flick_angle, 0), Vector(), veh_ang )
	end
	
	-- Get currently rotated and fixed up positions
	hmd_position, hmd_angles = get_world_pose( raw_hmd_pos, poses.hmd.ang )
	
	local adjusted_hmd_height = hmd_position
	
	-- Later fix up so that we can rotate from the feet and not the head
	adjusted_hmd_height = get_world_pose( Vector(0, 0, raw_hmd_z), poses.hmd.ang )
	
	-- Finally get the difference and fix up the offsets
	if ( changed_flick_angle ) then
		loco_player_offset = loco_player_offset - ( hmd_position - pre_hmd_rotation_position )

		-- Clear this out
		changed_flick_angle = 0
	end

	-- // START OF LOCO
	local relative_hmd_position = player_pos_render - ( hmd_position + player_pos_render )
	relative_hmd_position.z = 0

	local diff_position = old_player_pos - player_pos_render
	diff_position.z = 0

	-- Loco offset HAS to be some value
	-- Used for offsetting the player position from the hmd
	loco_player_offset.z = 0

	-- We want this to be zero
	-- Used for moving the player to the hmd
	loco_player_move = relative_hmd_position - loco_player_offset
	loco_player_move.z = 0
	
	-- //
	-- Moving HMD offset to match player movement
	-- //
	local diff_position_length = diff_position:Length2DSqr()
	local loco_player_move_length = loco_player_move:Length2DSqr()
	
	local diff_position_normal = diff_position:GetNormalized()
	local loco_player_move_normal = loco_player_move:GetNormalized()
	
	if ( diff_position_length > 256 ) then
		-- If we moved really far, teleport
		
		loco_player_offset = loco_player_offset * 0
		
	elseif ( diff_position_length > 0 ) then
		
		local loco_dot = loco_player_move_normal:Dot( diff_position_normal )
		
		local allowed_to_move = 0
		
		if ( loco_dot <= 0 ) then
			allowed_to_move = 0
		else
			allowed_to_move = 1
		end
		
		local fixup_length = diff_position_length
		
		if ( diff_position_length > loco_player_move_length ) then
			fixup_length = loco_player_move_length
		end
		
		local final = (loco_player_move_normal * -1) * loco_dot * math.sqrt(fixup_length) * allowed_to_move
		
		loco_player_offset = loco_player_offset - final
		
	end
	-- //
	
	local hmd_forward = hmd_angles:Forward()
	local hmd_up = hmd_angles:Up()
	local hmd_right = hmd_angles:Right()
	
	hmd_preworld_position = hmd_position + adjusted_hmd_height - (hmd_forward * eyez * vr_scale)

	hmd_noeyez_position = hmd_position + adjusted_hmd_height + loco_player_offset

	hmd_world_position = hmd_preworld_position + player_pos_render + loco_player_offset

	eye_pos_l = hmd_world_position + ( hmd_right * (ipd * -0.5 * vr_scale) )
	eye_pos_r = hmd_world_position + ( hmd_right * (ipd * 0.5 * vr_scale) )
	
	-- //
	if ( poses.pose_lefthand && poses.pose_righthand ) then
		lefthand_position,   lefthand_angles = get_world_pose(  poses.pose_lefthand.pos,  poses.pose_lefthand.ang )
		righthand_position, righthand_angles = get_world_pose( poses.pose_righthand.pos, poses.pose_righthand.ang )

		lefthand_angles_raw = lefthand_angles
		
		local butt_pos, butt_ang = Vector(), Angle()
		
		butt_pos, butt_ang = LocalToWorld( controller_pos_offset, controller_angle_offset, righthand_position, righthand_angles )

		righthand_angles = butt_ang
		
		--butt_pos, righthand_angles_ui = LocalToWorld( butt_pos, Angle(-90, 0, 0), righthand_position, righthand_angles )
		
		butt_pos, lefthand_angles_ui = LocalToWorld( controller_pos_offset, controller_ui_offset, lefthand_position, lefthand_angles )
		
		butt_pos, butt_ang = LocalToWorld( controller_pos_offset, controller_angle_offset, lefthand_position, lefthand_angles )

		lefthand_angles = butt_ang

		butt_pos, righthand_angles_flashlight = LocalToWorld( controller_pos_offset, Angle(90, 0, 0), righthand_position, righthand_angles )

		lefthand_world_position =  player_pos_render + lefthand_position  + loco_player_offset
		righthand_world_position = player_pos_render + righthand_position + loco_player_offset

		-- VELOCITY

		--righthand_velocity, righthand_angvel = get_world_pose(  poses.pose_righthand.vel,  poses.pose_righthand.angvel )
	end
	-- //
	
	local rh_right = righthand_angles:Right()
	local rh_up = righthand_angles:Up()
	local rh_forward = righthand_angles:Forward()
	local lh_up = lefthand_angles:Up()
	local lh_right = lefthand_angles:Right()
	local lh_forward = lefthand_angles:Forward()
	
	if ( flashlight_toggle ) then
		VRFlashlight:SetPos( righthand_world_position + (rh_right * -4) + (rh_up * 1) )
		--VRFlashlight:SetPos( righthand_world_position + (righthand_angles:Right() * -4) + (righthand_angles:Up() * 1) )
		VRFlashlight:SetAngles( righthand_angles )
		--VRFlashlight:Update()
	end

	p.hmd_angles = hmd_angles
	p.hmd_position = hmd_preworld_position + loco_player_offset
	p.hmd_world_position = hmd_world_position
	
	local mainhand_pos_info = righthand_position + loco_player_offset
	local mainhand_ang_info = righthand_angles
	local mainhand_vec_info = mainhand_ang_info:Forward()
	
	p.mainhand_pos = righthand_world_position
	p.mainhand_ang = mainhand_ang_info
	p.mainhand_vec = mainhand_vec_info
	
	p.offhand_pos = lefthand_world_position
	p.offhand_ang = lefthand_angles
	p.offhand_ang_raw = lefthand_angles_raw
	p.offhand_ang_ui = lefthand_angles_ui
	--p.offhand_vec = lefthand_angles:Forward()
	p.offhand_vec = lh_forward
	
	-- Setup our networked firing hand
	favr_fire_pos:SetString( Format("%f %f %f", mainhand_pos_info.x, mainhand_pos_info.y, mainhand_pos_info.z) )
	favr_fire_ang:SetString( Format("%f %f %f", mainhand_ang_info.x, mainhand_ang_info.y, mainhand_ang_info.z) )
	favr_fire_vec:SetString( Format("%f %f %f", mainhand_vec_info.x, mainhand_vec_info.y, mainhand_vec_info.z) )
	
	-- Calls the callback to setup the bones
	p:SetupBones()
	-- Then manipulate bones afterwards

	-- Here until I figure something out with hiding the player model..
	local cack_pos, cack_ang = LocalToWorld( cmWeaponOffset, cmWeaponAngles, righthand_world_position, righthand_angles )

	local cack2_pos, cack2_ang = LocalToWorld(
		cmWeapon_NoMuzzleOffset,
		Angle(),
		cack_pos,
		cack_ang
	)
	
	if ( IsValid( cmWeapon ) ) then
		cmWeapon:SetPos( cack2_pos )
		cmWeapon:SetAngles( cack2_ang )
	end
	
	view_left.angles = hmd_angles
	view_left.origin = eye_pos_l

	view_right.angles = hmd_angles
	view_right.origin = eye_pos_r
	
	if ( system.HasFocus() ) then
		
		render.PushRenderTarget( vr_shared_rt )
		
		if ( flashlight_toggle ) then-- Test for fix weird offset for right eye
			VRFlashlight:Update()
		end
		
		render.RenderView( view_left )
		
		if ( flashlight_toggle ) then-- Test for fix weird offset for right eye
			VRFlashlight:Update()
		end
		
		render.RenderView( view_right )
		
		render.PopRenderTarget()
		
	else
		cam.Start2D()

		local text = "Please focus the game window"

		draw.DrawText( text, "DermaLarge", ScrW() * 0.5, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

		cam.End2D()
	end

	vrmod.SubmitSharedTexture()
	
	return true
end

-- NETWORK
-- 64 KiB is large, we should never run out. I just hope the server doesn't strugge
local function write_pose()
	net.Start( "favr_pose" )

	-- Include the locomotion offset! Everything is now relative to the player's position
	net.WriteVector( hmd_noeyez_position )-- hmd_preworld_position + loco_player_offset
	net.WriteAngle( hmd_angles )
	
	--[[net.WriteVector( lefthand_position + loco_player_offset )
	net.WriteAngle( lefthand_angles )
	net.WriteVector( righthand_position + loco_player_offset )
	net.WriteAngle( righthand_angles )]]

	net.SendToServer()
end

-- [[ VR Module Callbacks ]]
function GM:VR_UpdateModule()end
function GM:VR_DrawModule()end
function GM:VR_SetupPanel()end
function GM:VR_InitModule()end
function GM:VR_ShutdownModule()end

-- [[ VR User Interface ]]
include( "vr/vr_ui.lua" )
--include( "vr/vr_player.lua" )

local last_time = 0

local laser_enabled = false

function GM:UpdateVRNetwork( pl )
	local current_time = RealTime()
	local delta = current_time - last_time
	
	-- Make a variable for framerate??
	if ( delta >= 0.0333334 ) then
		--print("Frame", delta)
		
		write_pose()
		
		last_time = current_time
		
		laser_enabled = favr_laser:GetBool()
	end
	
	GAMEMODE:VR_UpdateUI( ui_data )
	
	GAMEMODE:VR_UpdateModule( module_data )
	
	--GAMEMODE:VR_UpdatePlayer( {} )
	
	local active_weapon = p:GetActiveWeapon()

	if ( active_weapon != current_weapon ) then

		cmWeaponValid = IsValid( active_weapon )
		
		if ( cmWeaponValid ) then
			sWorldModel = active_weapon:GetWeaponWorldModel()
			
			active_weapon:DrawShadow( false )
			
			if ( IsValid( cmWeapon ) ) then
				cmWeapon:Remove()
			end
			
			current_weapon = active_weapon
			
			cmWeapon = ents.CreateClientProp()
			
			cmWeapon:SetModel( sWorldModel )
			
			cmWeapon:SetSkin( active_weapon:GetSkin() )
			
			-- Set to origin to make sure bone data is relative to model origin
			cmWeapon:SetPos( Vector() )
			cmWeapon:SetAngles( Angle() )
			
			cmWeapon:Spawn()
			
			cmWeapon:SetOwner( p )
			
			cmWeapon:SetupBones()

			--cmWeapon:SetColor( Color(255, 0, 0, 255) )

			cmWeapon:SetNoDraw( false )
			
			cmWeapon:DrawShadow( false )

			--[[
			local cmWeaponOffset = Vector(0,0,0)
			local cmWeaponAngles = Angle(0,0,0)
			]]

			-- Fix up angles and offsets
			local iBone = cmWeapon:LookupBone( "ValveBiped.Bip01_R_Hand" )
			local iAttach = cmWeapon:LookupAttachment( "muzzle" )

			local tMuzzle = nil
			local muzzle_valid = iAttach > 0

			if ( muzzle_valid ) then
				tMuzzle = cmWeapon:GetAttachment( iAttach )
			end

			if ( iBone ) then
				local bone_matrix = cmWeapon:GetBoneMatrix( iBone )
				-- If no bone matrix the bone is wack

				local bone_pos = Vector(0,0,0)
				local bone_ang = Angle(0,0,0)
				local pre_angle = Angle(0,0,0)

				if ( bone_matrix ) then
					bone_pos = bone_matrix:GetTranslation()
					bone_ang = bone_matrix:GetAngles()

					cmWeaponInitialBoneAngles = bone_ang
					cmWeaponInitialBoneOffset = bone_pos

					-- This is before we rotate the angles by the bone again
					-- We add roll as well
					local clean_angle = bone_ang + Angle(0,0,180)

					-- Round!
					clean_angle.x = math.Round(clean_angle.x / 90) * 90
					clean_angle.y = math.Round(clean_angle.y / 90) * 90
					clean_angle.z = math.Round(clean_angle.z / 90) * 90

					local bone_reverse_pos, bone_reverse_ang = WorldToLocal( Vector(0,0,0), Angle(0,0,0), bone_pos, bone_ang + Angle(0,0,180) )

					cmWeaponOffset = bone_pos

					cmWeapon_NoMuzzleOffset = Vector(0, 0, 0)

					fixed_angle = Angle(0, 0, 0)

					-- Round up all angles
					fixed_angle.x = math.Round(bone_reverse_ang.x / 90) * 90
					fixed_angle.y = math.Round(bone_reverse_ang.y / 90) * 90
					fixed_angle.z = math.Round(bone_reverse_ang.z / 90) * 90

					if ( muzzle_valid ) then
						local fixed_pos, fixed_ang = WorldToLocal( Vector(0,0,0), Angle(0,0,0), tMuzzle.Pos, clean_angle )

						local com_vector = bone_reverse_pos - fixed_pos

						cmWeaponOffset = fixed_pos

						cmWeaponOffset.x = cmWeaponOffset.x + math.abs( com_vector.x * 0.85 )
					else
						fixed_angle.x = bone_ang.x * -1

						-- OKAY so this is the only thing thats off now lol
						cmWeapon_NoMuzzleOffset.y = cmWeaponOffset.y * -1
					end

					cmWeaponAngles = fixed_angle
				end
			end
		else
			if ( IsValid( cmWeapon ) ) then
				cmWeapon:SetNoDraw( true )
			end
		end
	end
end

local MAT_GLOW = Material("effects/vollaser")
local MAT_LASER = Material( "effects/playerlaser" )

local MASK_LASER = bit.bxor( MASK_SHOT, CONTENTS_WINDOW )

local laser_trace = {
	start = righthand_world_position,
	endpos = righthand_world_position,
	filter = p,
	mask = MASK_LASER
}

function GM:PreDrawEffects()
	GAMEMODE:VR_DrawModule( module_data )
	
	--render.DrawWireframeBox(  lefthand_world_position,  lefthand_angles, Vector( -1, -1, -6 ), Vector( 1, 1, -0.2 ), Color(  80,  80,  80, 100 ), true )

	--render.DrawWireframeBox( righthand_world_position, righthand_angles, Vector( -1, -1, -6 ), Vector( 1, 1, -0.2 ), Color(  80,  80,  80, 100 ), true )
	
	--local pos = p:GetPos()
	
	-- Draw collision hull
	--[[local mins, maxs = p:GetHull()
	
	maxs.z = 10
	
	if ( !hands_free ) then
		render.DrawWireframeBox( pos, Angle(0, 0, 0), mins, maxs, Color( 200, 200, 200, 100 ), true )
	end
	
	local aaa = hmd_position * 1
	aaa.z = 0
	
	if ( !hands_free ) then
		render.DrawWireframeBox( pos + aaa + loco_player_offset, Angle(0, 0, 0), mins, maxs, Color(255, 120, 0, 192), true )
	end]]
	-- Draw collision hull
	
	if ( hands_free ) then
		local doinker = Format( "%d\n%4.1f", eye_test, eye_cross_test )
		
		cam.Start3D2D( lefthand_world_position, lefthand_angles_ui, 0.02 )
			cam.IgnoreZ( true )
			draw.SimpleText( doinker, "Trebuchet24", 1, 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			cam.IgnoreZ( false )
		cam.End3D2D()
	end
	
	if ( !hands_free && laser_enabled ) then
		local rhand_forward = righthand_angles:Forward()
		
		local end_pos = righthand_world_position + (rhand_forward * 8192)
		local frac = 32
		
		laser_trace.start = righthand_world_position
		laser_trace.endpos = end_pos
		
		local t = util_TraceLine(laser_trace)
		
		if ( t.Hit ) then
			end_pos = t.HitPos
			
			local temp_frac = t.Fraction
			
			frac = temp_frac * 32
			
			render.SetMaterial( MAT_GLOW )
			
			render.DrawQuadEasy( end_pos + (rhand_forward * ((temp_frac + 0.1) * -4)), t.HitNormal, 5, 5, Color( 255, 255, 255, 255 ), 0 )
		end
		
		render.SetMaterial( MAT_LASER )
		
		local scrolltime = UnPredictedCurTime() * 0.07
		local scroll = math.ceil(scrolltime) - scrolltime
		
		render.DrawBeam( righthand_world_position, end_pos, 0.14, scroll, scroll + frac, Color( 255, 0, 0, 64 ) )
	end
	
	--GAMEMODE:VR_DrawPlayer( {} )
	
	GAMEMODE:VR_DrawUI( ui_data )
end

function GM:HUDPaint() end

function GM:HUDShouldDraw( name ) return false end

function GM:CalcView( pl, pos, ang, fov, znear, zfar )
	local view = {
		origin = hmd_noeyez_position + player_pos_render,
		angles = hmd_angles,
		fov = fov,
		znear = view_znear,
		zfar = zfar,
		drawviewer = false
	}

	return view
end

local function bonecallback( e, bone_count )

	-- This is where the flashlight is drawn from on models!
	--[[local rh_attach = e:LookupBone( "ValveBiped.Anim_Attachment_RH" )

	if ( rh_attach ) then
		local rh_attach_matrix = e:GetBoneMatrix( rh_attach )

		-- When the flashlight is turned off, we can not set the bone position
		-- Also best way of knowing if the bone is valid imo
		if ( rh_attach_matrix ) then

			e:SetBonePosition( rh_attach, righthand_world_position, righthand_angles_flashlight )

		end
	end]]
	
	--GAMEMODE:VR_BoneCallBack( e, bone_count )
	
	if ( bone_righthand == nil or bone_righthand < 0 ) then return end
	
	local bone_righthand_matrix = e:GetBoneMatrix( bone_righthand )
	
	if ( bone_righthand_matrix ) then
		
		local cack_pos, cack_ang = LocalToWorld( cmWeaponOffset, cmWeaponAngles, righthand_world_position, righthand_angles )
		
		local cack2_pos, cack2_ang = LocalToWorld(
			cmWeaponInitialBoneOffset + cmWeapon_NoMuzzleOffset,
			cmWeaponInitialBoneAngles,
			cack_pos,
			cack_ang
		)
		
		e:SetBonePosition( bone_righthand, cack2_pos, cack2_ang )
		
	end

end

local callback_id = nil

--[[local player_data = {
	state = -1,
	modelname = "models/player/alyx.mdl"
}]]

function GM:PlayerUpdateVR( player_state )
	-- player_state :
	-- 0 == the player has entered death state
	-- 1 == the player has just spawned alive
	
	if ( !VR_MODE ) then return end
	
	if ( player_state > 1 ) then return end
	
	if ( !IsValid( p ) ) then return end
	
	if ( IsValid( cmPlayer ) ) then
		cmPlayer:Remove()
	end
	
	cmPlayer = ents.CreateClientProp()
	
	local model = p:GetModel()
	local alive = p:Alive()
	
	if ( !alive ) then
		local cl_playermodel = p:GetInfo( "cl_facile_playermodel" )
		
		model = player_manager.TranslatePlayerModel( cl_playermodel )
	end
	
	cmPlayer:SetModel( model )
	
	cmPlayer:SetPos( Vector() )
	cmPlayer:SetAngles( Angle() )

	cmPlayer:SetupBones()

	cmPlayer:SetNoDraw( true )

	cmPlayer:Spawn()
	
	--player_data.state = player_state
	--player_data.modelname = model
	
	--GAMEMODE:VR_StateChangedPlayer( player_data )
	
	bone_pelvis = cmPlayer:LookupBone( "ValveBiped.Bip01_Pelvis" )
	
	bone_righthand = cmPlayer:LookupBone( "ValveBiped.Bip01_R_Hand" )
	
	-- This counts up over time... So add once and constantly try and update the Bone ID
	if ( (player_state == 1 || alive) and callback_id == nil ) then
		-- NOTE: Appears this can only be applied when the player is alive >_< `why`
		callback_id = p:AddCallback( "BuildBonePositions", bonecallback )
	end
	
end

GM:PlayerUpdateVR( 0 )

function GM:PrePlayerDraw( pl )
	if ( pl == p ) then
		return true
	end
end

local vrmod_TriggerHaptic = vrmod.TriggerHaptic
local haptic_mode_right = "vibration_right"
local haptic_mode_left = "vibration_left"

function GM:TriggerHaptic( mode, delay, duration, frequency, amplitude )
	local action = haptic_mode_right
	
	if ( mode == 1 ) then
		action = haptic_mode_left
	end
	
	vrmod_TriggerHaptic( action, delay, duration, frequency, amplitude )
end

local function disable_vr()
	VR_MODE = nil
	
	if ( IsValid( cmWeapon ) ) then cmWeapon:Remove() end
	
	if ( IsValid( cmPlayer ) ) then cmPlayer:Remove() end
	
	function GM:RenderScene() end
	function GM:CreateMove() end
	function GM:CalcView() end
	--function GM:CalcViewModelView() end
	function GM:PreDrawEffects() end
	function GM:PrePlayerDraw() end
	function GM:UpdateVRNetwork() end
	function GM:TriggerHaptic() end
	function GM:VRShowMapMenu() end
	
	if ( callback_id ~= nil ) then
		p:RemoveCallback( "BuildBonePositions", callback_id )
	end
	
	VRFlashlight:Remove()

	vrmod.Shutdown()

	RunConsoleCommand( "mat_hdr_manual_tonemap_rate", "1" )
	RunConsoleCommand( "mat_disable_bloom", "0" )
	RunConsoleCommand( "fa_disablevr" )
	
	hook.Remove( "ShutDown", "VRShutdown" )
	hook.Remove( "ShouldDrawLocalPlayer", "favr_drawlocal" )
	
	-- Tell the server we are shutting off VR
	net.Start("facile_requeststate")
		net.WriteUInt( 101, 32 )
	net.SendToServer()
	
	-- Return to normal
	function GM:PlayerUpdateVR( player_state )
		if ( player_state == 256 ) then
			GAMEMODE:PlayerAttemptVR()
		end
	end
end

-- We can't reload the VR script BUT we can shutdown just in case
hook.Add( "OnReloaded", "TestReload", function()
	disable_vr()
end )

-- Uuh yeah make sure everything is closed...
hook.Add( "ShutDown", "VRShutdown", function()
	disable_vr()
end )

concommand.Add( "vr_disable", disable_vr )
