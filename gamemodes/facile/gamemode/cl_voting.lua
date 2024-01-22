-- Gamemode and map sorting
--https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/menu/getmaps.lua

local IgnorePatterns = {
	"^background",
	"^devtest",
	"^ep1_background",
	"^ep2_background",
	"styleguide"
}

local IgnoreMaps = {
	[ "sdk_" ] = true,
	[ "test_" ] = true,
	[ "vst_" ] = true,
	[ "c4a1y" ] = true,
	[ "credits" ] = true,
	[ "d2_coast_02" ] = true,
	[ "d3_c17_02_camera" ] = true,
	[ "ep1_citadel_00_demo" ] = true,
	[ "c5m1_waterfront_sndscape" ] = true,
	[ "intro" ] = true,
	[ "test" ] = true
}

-- `path` in console will list all path search strings
local gamemodeGames = {
	{"cstrike", false},
	{"hl2mp", false},
	{"hl1mp", false},
	{"thirdparty", true},
	{"DOWNLOAD", true}

	-- {game, skipPattern}
	-- Some games want to skip pattern check if you want all of their maps
	-- hl1mp for example

	-- Or for hl2 a pattern can be map names
	-- and this can be each chapter

	-- cstrike
	-- hl2mp
	-- hl1mp
	-- thirdparty (workshop, addons)
	-- DOWNLOAD (legacy addons)
	-- tf

	-- csgo
	-- garrysmod (construct, flatgrass specifically)

	-- GAME is everything (don't use with game list)
	-- workshop (don't use, doesn't include local addons)
}

local gamemodeMaps = {
	[ "cs_" ] = true,
	[ "de_" ] = true,
	[ "aim_" ] = true,
	[ "gg_" ] = true,
	[ "ttt_" ] = true,
	[ "vdm_" ] = true,
	[ "dm_" ] = true
}

local function placeholderMapList()
	local finalMaps = {}

	for _, v in ipairs( gamemodeGames ) do
		local game = v[1]
		local skipPattern = v[2]

		local gameMaps = file.Find( "maps/*.bsp", game )

		for id, mapFile in ipairs( gameMaps ) do
			local mapFileLower = string.lower( mapFile )
			local name = string.gsub( mapFileLower, "%.bsp$", "" )
			local prefix = string.match( name, "^(.-_)" )

			local Ignore = IgnoreMaps[ name ] || IgnoreMaps[ prefix ]

			if ( Ignore ) then continue end

			for _, ignore in ipairs( IgnorePatterns ) do
				if ( string.find( name, ignore ) ) then
					Ignore = true
					break
				end
			end

			if ( Ignore ) then continue end

			Ignore = skipPattern

			if ( skipPattern ) then
				Ignore = ! (gamemodeMaps[ name ] || gamemodeMaps[ prefix ])
			end

			if ( Ignore ) then continue end

			local gameIcon = game

			if ( game == "thirdparty" && file.Exists( "maps/"..mapFileLower, "workshop" ) ) then
				gameIcon = "workshop"
			end

			table.insert( finalMaps, {mapFileLower, gameIcon} )
		end
	end

	return finalMaps
end

-- This should only be created from netRecieve
-- it will have a big ass table for the maps that are on the server
-- Map list should only be created once gamemode is voted for.
local function CreateVoteMenu()

	if ( IsValid(g_VoteMenu) ) then -- ALSO PLEASE STOP MAKING GLOBALS LOL
		g_VoteMenu:Remove()
		g_VoteMenu = nil
	end

	g_VoteMenu = vgui.Create( "FacileVote" )

	local maps = placeholderMapList()

	for id, v in ipairs( maps ) do

		local mapFile = v[1]
		local game = v[2]

		local name = string.gsub( mapFile, "%.bsp$", "" )

		local image = "maps/thumb/noicon.png"

		if ( file.Exists( "maps/thumb/"..name..".png", "GAME" ) ) then
			image = "maps/thumb/"..name..".png"
		end

		local icon = "icon16/error.png"

		-- Also needs to check if client has map and show error.png MAYBE since they can download it
		-- game content is different, could miss materials and stuff

		if ( IsMounted( game ) || game == "garrysmod" ) then
			icon = "games/16/"..game..".png"
		end

		if ( game == "workshop" || game == "DOWNLOAD" ) then
			icon = "games/16/all.png"
		elseif ( game == "thirdparty" ) then
			icon = "icon16/folder.png"
		end

		local voteItem = vgui.Create( "FacileVoteMapButton" )

		voteItem.mapName = name

		voteItem:Setup( name, image, icon )

		g_VoteMenu:AddItem( voteItem )
	end

	g_VoteMenu:MakePopup()

end

concommand.Add( "fa_vote_reload", CreateVoteMenu )

concommand.Add( "fa_vote_close", function() if ( IsValid(g_VoteMenu) ) then g_VoteMenu:Remove() g_VoteMenu = nil end end )