AddCSLuaFile()

AddCSLuaFile( "facilehud.lua" )
AddCSLuaFile( "spectatehud.lua" )
AddCSLuaFile( "contenticon.lua" )
AddCSLuaFile( "dliststats.lua" )
AddCSLuaFile( "votemapbutton.lua" )
AddCSLuaFile( "voting.lua" )
AddCSLuaFile( "deathnotices.lua" )
AddCSLuaFile( "mapbutton.lua" )

if CLIENT then
	include( "facilehud.lua" )
	include( "spectatehud.lua" )
	include( "contenticon.lua" )
	include( "dliststats.lua" )
	include( "votemapbutton.lua" )
	include( "voting.lua" )
	include( "deathnotices.lua" )
	
	include( "mapbutton.lua" )
end