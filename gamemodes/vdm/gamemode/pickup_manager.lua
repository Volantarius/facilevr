-- Keeping functions local to avoid other stuff trying to fiddle with this

local vdmLoadoutNextCV = CreateConVar( "sv_vdm_loadoutnext", "randomall", {FCVAR_ARCHIVE}, "Do not change directly!! Use vdm_changeloadout" )
local vdmLoadoutCV = CreateConVar( "sv_vdm_loadout", "randomall", {FCVAR_ARCHIVE}, "Do not change directly!! Use vdm_changeloadout" )

local VDM_Pickups_Weapons = {}
local VDM_Pickups_Weapons_Names = {}--key is className, value is the index for the weapon
local VDM_Pickups_Weapons_Keys = {}--Key to key table

-- ONLY SCRIPTED WEAPONS
local function AddWeapon( weapon, color, clip1_amount, clip2_amount, rotateoffset )
	rotateoffset = rotateoffset or Angle(0, 0, 0)
	clip1_amount = clip1_amount or 0
	clip2_amount = clip2_amount or 0
	
	-- DO NOT USE baseclass.get! Causes a fuck ton of problems!
	local baseweapon = weapons.Get( weapon )
	
	if ( baseweapon == nil ) then
		ErrorNoHalt("(VDM) Could not add: ", weapon, " to the pickup manager.")
		return
	end
	
	-- Weapons can still use ammo but without a clip
	if ( baseweapon.Primary.ClipSize > 0 ) then
		clip1_amount = clip1_amount * baseweapon.Primary.ClipSize
	end
	
	if ( baseweapon.Secondary.ClipSize > 0 ) then
		clip2_amount = clip2_amount * baseweapon.Secondary.ClipSize
	end
	
	-- Adding this way does create a indexed table!
	local key = table.insert(VDM_Pickups_Weapons, {
			weapon = weapon,
			color = color,
			
			clip1_amount = clip1_amount,
			clip1_type = baseweapon.Primary.Ammo,
			
			clip2_amount = clip2_amount,
			clip2_type = baseweapon.Secondary.Ammo,
			
			rotateoffset = rotateoffset,
			worldmodel = baseweapon.WorldModel
		})
	
	-- Create a classname reference
	VDM_Pickups_Weapons_Names[weapon] = key
	table.insert( VDM_Pickups_Weapons_Keys, key )
end

-- Again avoiding anything screwing with my pickup system, copy stuff to the caller
function GM:VdmAllWeapons()
	return table.Copy( VDM_Pickups_Weapons )
end

function GM:VdmGetWeapon( name )
	if ( VDM_Pickups_Weapons_Names[ name ] ~= nil ) then
		return table.Copy( VDM_Pickups_Weapons[ VDM_Pickups_Weapons_Names[ name ] ] )
	end
	
	return false
end

function GM:VdmGetWeaponByKey( key )
	if ( VDM_Pickups_Weapons[ key ] ~= nil ) then
		return table.Copy( VDM_Pickups_Weapons[ key ] )
	end
	
	return false
end

function GM:VdmGetRandomWeapon()
	return table.Copy( VDM_Pickups_Weapons[ math.random(1, #VDM_Pickups_Weapons) ] )
end

--[[-------------------------------------------------------------------------
	LOADOUTS BABY
---------------------------------------------------------------------------]]
-- So for powerups, we will hard code this since it will be a pain
-- for the sandbox tools to sync with this list itself. Unless this is made into a module

local VDM_Loadouts = { ["randomall"] = VDM_Pickups_Weapons_Keys }

local function CreateLoadout( name, weaponTable )
	if ( name == "randomall" ) then
		-- Don't replace the main loadout lol
		return
	end
	
	local tbl = {}
	
	for k,v in ipairs( weaponTable ) do
		if ( VDM_Pickups_Weapons_Names[v] == nil ) then
			continue
		end
		
		table.insert( tbl, VDM_Pickups_Weapons_Names[v] )
	end
	
	VDM_Loadouts[ name ] = tbl
end

-- Call this before creating map pickups and before spawning players for a new round
function GM:VdmPickupsUpdateLoadout()
	vdmLoadoutCV:SetString( vdmLoadoutNextCV:GetString() )
end

-- TODO: Make a get all weapons from current loadout
-- Get random weapon from X loadout
-- Get all weapons from X loadout

function GM:VdmGetRandomWeaponCurrentLoadout()
	local weaponTable = VDM_Loadouts[ vdmLoadoutCV:GetString() ]
	
	--local theKey = weaponTable[ math.random(1, #weaponTable) ]
	
	return table.Copy( VDM_Pickups_Weapons[ weaponTable[ math.random(1, #weaponTable) ] ] )
end

function GM:VdmGetAllFromLoadout( loadout )
	local weaponTable = VDM_Loadouts[ loadout ]
	
	if ( weaponTable == nil ) then return false end
	
	return table.Copy( weaponTable )
end

local pu_yellow  = Color(225, 225, 0) -- Smgs, and autopistols
local pu_orange  = Color(225, 98, 0) -- Grenades, Rockets
local pu_purple  = Color(225, 0, 225) -- Powerful guns
local pu_white   = Color(192, 192, 192) -- Items low teir items
local pu_green   = Color(0, 225, 32) -- Non armor green items
local pu_cyan    = Color(0, 192, 225) -- Pistols and stuff

--local melon = Color(225, 64, 64)
--local armor = Color(0, 225, 128)

local function VdmBuildTables()
	VDM_Pickups_Weapons = {}
	VDM_Pickups_Weapons_Names = {}
	VDM_Pickups_Weapons_Keys = {}
	
	AddWeapon( "weapon_vdm_shovel", pu_white, 0 )
	
	AddWeapon( "weapon_vdm_goldengun", pu_cyan, 3, -1, Angle(90,0,0) )
	AddWeapon( "weapon_vdm_deagle", pu_cyan, 3 )
	AddWeapon( "weapon_vdm_slowmo", pu_cyan, 3 )
	AddWeapon( "weapon_vdm_fartgun", pu_cyan, 3 )
	
	AddWeapon( "weapon_vdm_kf7", pu_yellow, 2, -1, Angle(90,0,0) )
	AddWeapon( "weapon_vdm_garand", pu_yellow, 2 )
	AddWeapon( "weapon_p90", pu_yellow, 2 )
	
	AddWeapon( "weapon_vdm_lazer", pu_green, 2 )
	AddWeapon( "weapon_vdm_displacer", pu_green, 50 )
	
	AddWeapon( "weapon_vdm_shotty", pu_purple, 3 )
	AddWeapon( "weapon_vdm_minigun", pu_purple, 0 )
	AddWeapon( "weapon_vdm_grenadelauncher", pu_purple, 1 )
	
	AddWeapon( "weapon_vdm_proxmine", pu_orange, 4, -1, Angle(90,0,0) )
	AddWeapon( "weapon_vdm_turtles", pu_orange, 4 )
	
	-- Make sure that all loadouts are created after weapons are added!
	
	VDM_Loadouts = { ["randomall"] = VDM_Pickups_Weapons_Keys }--Literally all of the existing weapons
	
	CreateLoadout( "random", {--No instagib weapons in here!
		"weapon_vdm_shovel",
		"weapon_vdm_kf7",
		"weapon_vdm_garand",
		"weapon_vdm_displacer",
		"weapon_vdm_minigun",
		"weapon_vdm_grenadelauncher",
		"weapon_vdm_proxmine",
		"weapon_vdm_turtles",
		"weapon_vdm_lazer",
		"weapon_p90"
	} )
	
	CreateLoadout( "instagib", {--Only instagib
		"weapon_vdm_goldengun",
		"weapon_vdm_shovel"
	} )
	
	CreateLoadout( "proximitys", {
		"weapon_vdm_proxmine",
		"weapon_vdm_proxmine",
		"weapon_vdm_lazer"
	} )
	
	CreateLoadout( "loadoutdefault", {--Loadout for player classes
		"weapon_vdm_garand",
		"weapon_vdm_shovel"
	} )
end

-- Make sure we use the current table on reloads
hook.Add( "OnReloaded", "VdmPUReloadBuild", function()
	VdmBuildTables()
end )

hook.Add( "InitPostEntity", "VdmPUInitBuild", function()
	VdmBuildTables()
end )

--[[-------------------------------------------------------------------------
	Con Commands for controlling loadouts!
---------------------------------------------------------------------------]]

local function LoadoutAutoComplete( cmd, stringargs )
	stringargs = string.Trim(stringargs)
	stringargs = string.lower(stringargs)
	
	local tbl = {}
	
	for k,v in pairs( VDM_Loadouts ) do
		if ( string.find( k, stringargs ) ) then
			table.insert(tbl, cmd .. " " .. k)
		end
	end
	
	return tbl
end

local function ChangePickupLoadout( ply, cmd, args, argStr, changeNow )
	if ( VDM_Loadouts[ argStr ] == nil ) then
		print("Loadout does not exist!")
		return
	end
	
	vdmLoadoutNextCV:SetString( argStr )
	
	if ( changeNow ) then
		vdmLoadoutCV:SetString( argStr )
	end
	
	net.Start("vdmn_loadoutchange")
		net.WriteString(argStr)
		net.WriteBool(changeNow)
	net.Broadcast()
end

concommand.Add( "vdm_changeloadout", function(ply, cmd, args, argStr) ChangePickupLoadout(ply, cmd, args, argStr, false) end, LoadoutAutoComplete, nil, {FCVAR_NONE} )

concommand.Add( "vdm_changeloadoutnow", function(ply, cmd, args, argStr) ChangePickupLoadout(ply, cmd, args, argStr, true) end, LoadoutAutoComplete, nil, {FCVAR_NONE} )