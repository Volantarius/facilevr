DeriveGamemode( "base" )

include( "vgui/vgui.lua" )

include( "sh_player.lua" )

include( "obj_player_extend.lua" )

include( "editor_player.lua" )
include( "editor_vr.lua" )
include( "editor_general.lua" )
include( "editor_player_vol.lua" )

include( "player_class/player_facile.lua" )
include( "player_class/player_fa_example.lua" )
include( "player_class/player_fa_vrtesting.lua" )
include( "player_class/player_fa_tptest.lua" )

GM.Name 	= "Facile"
GM.Author 	= "Volantarius"
GM.Email 	= "volantarius@gmail.com"
GM.Website 	= ""

GM.RealisticFallDamage = true

-- Only disable if you don't want spectating or any other team to be accounted for
-- This really breaks everything else in the base gamemode if you want to do anything else
GM.TeamBased = true

GM.TakeFragOnSuicide = false
GM.AddFragsToTeamScore = false

GM.NoPlayerSuicide = false
GM.NoPlayerDamage = false			-- Set to true if players should not be able to damage each other.
GM.NoPlayerSelfDamage = false		-- Allow players to hurt themselves?
GM.NoPlayerTeamDamage = true		-- Allow team-members to hurt each other?
GM.NoPlayerPlayerDamage = false 	-- Allow players to hurt each other?
GM.NoNonPlayerPlayerDamage = false	-- Allow damage from non players (physics, fire etc)

GM.EnableFreezeCam = false

GM.MinimumDeathLength = 2
GM.MaximumDeathLength = 10

GM.PlayerCanNoClip = false

GM.AllowAutoTeam = false-- Need autoteam function written
GM.NoAutomaticSpawning = false-- IMPLIMENT

-- (2021) Fuck this for now
--GM.ValidSpectatorEntities = { "point_viewcontrol" }
GM.CanOnlySpectateOwnTeam = false

GM.SuicideString = "couldn't take it anymore"
GM.DeathNoticeDefaultColor = Color( 255, 192, 0 )
GM.DeathNoticeTextColor = Color( 255, 255, 255 )

TEAM_BLUE = 1
TEAM_ORANGE = 2

local translatePM = player_manager.TranslatePlayerModel

-- What model, animation to use in the team select menu, and model color (vector)
GM.TeamSelectModels = {
	[TEAM_BLUE] = {
		model = translatePM("alyx"),
		pose = "pose_standing_04",
		color = Color( 0, 186, 255 ):ToVector()
	},
	[TEAM_ORANGE] = {
		model = translatePM("chell"),
		pose = "pose_standing_01",
		color = Color( 255, 150, 0 ):ToVector()
	}
}

function GM:CreateTeams()
	if ( !GAMEMODE.TeamBased ) then return end

	team.SetUp( TEAM_BLUE, "Blue Team", Color( 0, 186, 255 ) )
	team.SetSpawnPoint( TEAM_BLUE, {"info_player_counterterrorist", "info_player_rebel", "info_player_allies"} )
	team.SetClass( TEAM_BLUE, {"player_facile", "player_fa_example", "player_fa_vr", "player_fa_tptest"} )

	team.SetUp( TEAM_ORANGE, "Orange Team", Color( 255, 150, 0 ) )
	team.SetSpawnPoint( TEAM_ORANGE, {"info_player_terrorist", "info_player_combine", "info_player_axis"} )
	team.SetClass( TEAM_ORANGE, {"player_facile", "player_fa_example", "player_fa_vr", "player_fa_tptest"} )

	team.SetSpawnPoint( TEAM_SPECTATOR, "point_viewcontrol" )
end

-- Disable jump for OBS_MODE_ROAMING, so the camera doesn't gain height
function GM:StartCommand( pl, cmd )
	if ( pl:IsBot() ) then
		-- Run code for path shiz
		
		cmd:ClearButtons()
		cmd:ClearMovement()
		
		--if ( SERVER ) then
		--	GAMEMODE:AssBot( pl, cmd )
		--end
		
		return
	end
	
	-- Auto BHOP
	if ( pl:GetInfoNum("cl_bhopauto", 0) == 1 ) then
		if ( cmd:KeyDown( IN_JUMP ) ) then
			if ( pl:OnGround() ) then
				cmd:AddKey( IN_JUMP )
			else
				cmd:RemoveKey( IN_JUMP )
			end
		end
	end
	
	if ( pl:GetInfoNum("cl_bhoptraining", 0) == 1 ) then
		if ( !pl:OnGround() ) then
			cmd:RemoveKey( IN_FORWARD )
			cmd:SetForwardMove( math.Clamp(cmd:GetForwardMove(), -1000, 0) )
		end
	end
	
	if ( pl:GetInfoNum("cl_bhopvr", 0) == 1 ) then
		cmd:RemoveKey( IN_FORWARD )
		cmd:SetForwardMove( math.Clamp(cmd:GetForwardMove(), -1000, 0) )
	end
	
	if ( pl:Alive() ) then return end
	
	if ( pl:GetObserverMode() > 0 ) then
		cmd:RemoveKey( IN_JUMP )
	end
end

local team_BestAutoJoinTeam = team.BestAutoJoinTeam

function GM:BestAutoTeam()
	return team_BestAutoJoinTeam()
end

function GM:CanProperty( pl, property, ent )
	return false
end

function GM:CanInteract( pl, property, ent )
	if ( !pl:Alive() ) then return false end

	if ( !IsValid( ent ) ) then return false end

	if ( ent:IsWeapon() and IsValid( ent:GetOwner() ) ) then
		return false
	end

	if ( ent.CanInteract ) then
		return ent:CanInteract( pl, property )
	end

	return true
end

--GM.WeaponLoadoutCategories = { VCSS = true, VDM = true, ["Half-Life 2"] = true }
GM.WeaponLoadoutCategories = { VDM = true, ["Half-Life 2"] = true }

local finalWeapons = {}
local finalKeyWeapons = {}--Key is classname

-- Weapons must have their category set shared!
-- Or manually set the list by hand
local function SetupWeaponLoadouts()
	local weapons = list.Get( "Weapon" )
	local Categorised = {}

	for k, wep in pairs( weapons ) do
		if ( not wep.Spawnable ) then continue end

		if ( GAMEMODE.WeaponLoadoutCategories[wep.Category] ) then
			Categorised[wep.Category] = Categorised[wep.Category] or {}
			table.insert( Categorised[wep.Category], wep )
		end
	end

	weapons = nil

	if ( Categorised["Half-Life 2"] && not Categorised["Other"] ) then
		table.insert( Categorised["Half-Life 2"], {
			ClassName = "weapon_physgun",
			PrintName = "Physgun",
			Category = "Half-Life 2"
		} )
	end

	for CategoryName, v in SortedPairs( Categorised ) do
		for k, wep in SortedPairsByMemberValue( v, "PrintName" ) do
			table.insert( finalWeapons, {
				ClassName = wep.ClassName,
				PrintName = wep.PrintName
			} )

			finalKeyWeapons[wep.ClassName] = true
		end
	end

	list.Set( "FacileLoadoutWeapons", "defaultSet", finalWeapons )
	list.Set( "FacileLoadoutWeapons", "defaultSetValid", finalKeyWeapons )

	finalWeapons = nil
	finalKeyWeapons = nil
end

-- Well atleast list doesn't get screwed from reload
-- Shared so that on server we can check if the classname is in the list so theres no hackery
hook.Add( "InitPostEntity", "CreateFacileLoadouts", function()
	SetupWeaponLoadouts()
end )

local color_client = Color(255, 241, 122, 200)
local color_server = Color(156, 241, 255, 200)

--[[hook.Add( "Think", "TestBedThink", function()

	for k, ply in ipairs( player.GetAll() ) do

		local view_entity = ply:GetViewEntity()

		local valid_view_entity = view_entity != ply

		if ( IsValid(view_entity) && valid_view_entity ) then

			local player_pos = ply:GetPos()
			local player_ang = ply:EyeAngles()

			view_entity:SetPos( player_pos + Vector(0, 200, 60) )

			view_entity:SetAngles( Angle(0, player_ang.y, 0) )

			if ( SERVER ) then
				debugoverlay.Box( view_entity:GetPos(), Vector(-4,-1,-1), Vector(4,1,1), 0.03, color_server )
			else
				debugoverlay.Box( view_entity:GetPos(), Vector(-4,-1,-1), Vector(4,1,1), 0.03, color_client )
			end
		end

	end

end )]]

function GM:Tick()
	-- Don't hook for gamemode stuff
	-- We should really replace hooks....

	-- player tables and what not can be shared from here as well

	GAMEMODE:FacileTick()
end